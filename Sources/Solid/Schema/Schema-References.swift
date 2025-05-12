//
//  Schema-References.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/19/25.
//

import SolidData
import SolidURI
import Foundation
import Atomics


extension Schema {

  public enum References {

    public final class Ref$: ReferenceBehavior, BuildableKeywordBehavior, @unchecked Sendable {

      public static let keyword: Keyword = .ref$

      public let schemaId: URI
      private var resolvedSubSchema: SubSchema?
      private let resolveLock = NSLock()

      public init(schemaId: URI) {
        self.schemaId = schemaId
      }

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Ref$? {

        guard let stringInstance = keywordInstance.string else {
          try context.invalidType(requiredType: .string)
        }

        guard let uriReference = URI(encoded: stringInstance) else {
          try context.invalidValue("Must be a valid absolute or relative URI")
        }

        let schemaId = uriReference.resolved(against: context.baseId)

        return Ref$(schemaId: schemaId)
      }

      public func resolve(context: inout Validator.Context) -> SubSchema {
        return resolveLock.withLock {

          if let resolvedSubSchema {
            return resolvedSubSchema
          }

          do {
            if let subSchema = try context.locate(schemaId: schemaId, allowing: .standardAndDynamic) {

              self.resolvedSubSchema = subSchema

            } else if let fragmentSubSchema = try Builder.buildDynamicFragment(from: schemaId, context: &context) {

              self.resolvedSubSchema = fragmentSubSchema

            } else {

              self.resolvedSubSchema = UnresolvedSubSchema(schemaId: schemaId)
            }
          } catch {
            self.resolvedSubSchema = UnresolvedSubSchema(schemaId: schemaId)
          }

          return self.resolvedSubSchema.neverNil()
        }
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {
        let subSchema = resolve(context: &context)
        return context.validate(instance: instance, using: subSchema, at: schemaId)
      }

      public static func hasLocalDynamicAnchor(schemaId: URI, context: Builder.Context) throws -> Bool {
        return try context.locate(schemaId: schemaId.removing(.fragment))?
          .locate(fragment: schemaId.fragment ?? "", allowing: .dynamicOnly) != nil
      }
    }

    public final class DynamicRef$: ReferenceBehavior, BuildableKeywordBehavior, @unchecked Sendable {

      public static let keyword: Keyword = .dynamicRef$

      /// URI to the dynamic anchor in the local schema resource.
      public let schemaId: URI

      /// Is the fragment a valid JSON Schema anchor, as opposed to a JSON pointer fragment.
      public let isAnchorFragment: Bool

      /// Is the fragment referring to a `$dynamicAnchor` defined in the local schema resource?
      public var hasLocalDynamicAnchor = false

      /// The resolved lexical schema reference, used if dynamic resolution fails.
      private nonisolated(unsafe) var lexicalSubSchema: Schema.SubSchema?

      private var resolved = false
      private let resolveLock = NSLock()

      public init(schemaId: URI, isAnchorFragment: Bool) {
        self.schemaId = schemaId
        self.isAnchorFragment = isAnchorFragment
      }

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> DynamicRef$? {

        guard let stringInstance = keywordInstance.string else {
          try context.invalidType(requiredType: .string)
        }

        guard let uriReference = URI(encoded: stringInstance) else {
          try context.invalidValue("Must be a valid absolute or relative URI")
        }

        let schemaId = uriReference.resolved(against: context.baseId)
        let isAnchorFragment = Self.isAnchorFragment(for: schemaId)

        return DynamicRef$(schemaId: schemaId, isAnchorFragment: isAnchorFragment)
      }

      public func resolve(context: inout Validator.Context) -> (
        hasLocalDynamicAnchor: Bool, subSchema: Schema.SubSchema
      ) {
        resolveLock.withLock {
          guard !resolved else {
            return (self.hasLocalDynamicAnchor, self.lexicalSubSchema.neverNil())
          }

          // Check if a `$dynamicAnchor` exists in the local resource schema.
          do {
            self.hasLocalDynamicAnchor = try Self.hasLocalDynamicAnchor(schemaId: schemaId, context: &context)
          } catch {
            self.hasLocalDynamicAnchor = false
          }

          // Resolve as `$ref`, if possible, for fallback behavior.
          do {
            if let subSchema = try context.locate(schemaId: schemaId) {
              self.lexicalSubSchema = subSchema
            } else {
              self.lexicalSubSchema = UnresolvedSubSchema(schemaId: schemaId)
            }
          } catch {
            self.lexicalSubSchema = UnresolvedSubSchema(schemaId: schemaId)
          }

          resolved = true

          return (self.hasLocalDynamicAnchor, self.lexicalSubSchema.neverNil())
        }
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {

        let (hasLocalDynamicAnchor, lexicalSubSchema) = resolve(context: &context)

        // The fragment must be a valid anchor (i.e., it's not a JSON pointer), and a matching dynamic
        // anchor must be defined in the local schema resource, to perform dynamic resolution.
        if isAnchorFragment && hasLocalDynamicAnchor {

          // Resolve the anchor dynamically.
          //
          // For each scope in the validation path, starting with the outermost scope, attempt
          // to locate a schema with the anchor (only searching for dynamic anchors). The first
          // schema found is used to validate the instance.

          let uriReference = schemaId.relative().removing(.path)
          let dynamicAnchor = schemaId.fragment ?? ""

          for scopeId in context.scopeIds {

            let scopeSchemaResourceId = uriReference.resolved(against: scopeId)

            do {

              // Load the root schema resource for this scope.

              let scopeRootSchemaResourceId = scopeSchemaResourceId.removing(.fragment)

              guard let scopeRootSchema = try context.locate(schemaId: scopeRootSchemaResourceId) else {
                continue
              }

              // Attempt to locate a sub-schema, in the scope's schema resource, with the dynamic anchor.

              guard let subSchema = scopeRootSchema.locate(fragment: dynamicAnchor, allowing: .dynamicOnly) else {
                continue
              }

              return context.validate(instance: instance, using: subSchema, at: schemaId)

            } catch {

              return .invalid(
                "Error resolving dynamic schema reference '\(uriReference)': \(error.localizedDescription)"
              )
            }
          }
        }

        // When no dynamic anchor can be located or dynamic resolution
        // isn't allowed, attempt standard `$ref` behavior.

        return context.validate(instance: instance, using: lexicalSubSchema, at: schemaId)
      }

      /// Check if a `$dynamicAnchor` exists in the local resource schema.
      ///
      /// - Parameters:
      ///  - schemaId: The schema URI reference to the local dynamic anchor.
      ///  - context: The current schema builder context.
      /// - Throws: If an error occurs loading the schema.
      private static func hasLocalDynamicAnchor(schemaId: URI, context: inout Validator.Context) throws -> Bool {
        return try context.locate(schemaId: schemaId, allowing: .dynamicOnly) != nil
      }

      /// Check if the URI reference is a valid JSON Schema anchor.
      private static func isAnchorFragment(for uriReference: URI) -> Bool {
        guard let fragment = uriReference.fragment, Identifiers.anchorRegex.matches(fragment) else {
          return false
        }
        return true
      }

    }
  }
}
