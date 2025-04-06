//
//  Schema-Applicators.swift
//  Codex
//
//  Created by Kevin Wooten on 2/5/25.
//

import OrderedCollections

extension Schema {

  public enum Applicators {

    public struct AllOf: CompositeApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .allOf

      public let subSchemas: [Schema.SubSchema]

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {
        guard let subSchemaInstances = keywordInstance.array else {
          try context.invalidType(requiredType: .array)
        }
        return Self(subSchemas: try context.subSchemas(for: subSchemaInstances))
      }

      public func combine(validations: [Validation], context: inout Validator.Context) -> Validation {
        return validations.allSatisfy(\.isValid)
          ? .valid
          : .invalid("Must match all of the subschemas, \(validations.count { !$0.isValid }) did not match")
      }
    }

    public struct AnyOf: CompositeApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .anyOf

      public let subSchemas: [Schema.SubSchema]

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {
        guard let subSchemaInstances = keywordInstance.array else {
          try context.invalidType(requiredType: .array)
        }
        return Self(subSchemas: try context.subSchemas(for: subSchemaInstances))
      }

      public func combine(validations: [Validation], context: inout Validator.Context) -> Validation {
        return validations.anySatisfy(\.isValid)
          ? .valid
          : .invalid("Must match at least one of the subschemas, none matched")
      }
    }

    public struct OneOf: CompositeApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .oneOf

      public let subSchemas: [Schema.SubSchema]

      public static func build(from schemaInstance: Value, context: inout Builder.Context) throws -> Self? {
        guard let subSchemaInstances = schemaInstance.array else {
          try context.invalidType(requiredType: .array)
        }
        return Self(subSchemas: try context.subSchemas(for: subSchemaInstances))
      }

      public func combine(validations: [Validation], context: inout Validator.Context) -> Validation {
        return validations.count(where: \.isValid) == 1
          ? .valid
          : .invalid("Must match exactly one of the subschemas, \(validations.count(where: \.isValid)) matched")
      }
    }

    public struct Not: ApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .not

      public let order: KeywordBehaviorOrder = .composites

      public let subSchema: Schema.SubSchema

      public static func build(from schemaInstance: Value, context: inout Builder.Context) throws -> Self? {
        return Self(subSchema: try context.subSchema(for: schemaInstance))
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {
        subSchema.validate(instance: instance, context: &context).isValid
          ? .invalid("Must not match the subschema")
          : .valid
      }
    }

    public struct If: ApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .if

      public let order: KeywordBehaviorOrder = .composites

      public let subSchema: SubSchema

      public static func build(from schemaInstance: Value, context: inout Builder.Context) throws -> Self? {
        let subSchema = try context.subSchema(for: schemaInstance)
        return Self(subSchema: subSchema)
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {

        let result = context.validate(instance: .inPlace(instance), using: subSchema)

        return .annotation(.bool(result.isValid))
      }
    }

    public struct Then: ApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .then

      public let order: KeywordBehaviorOrder = .composites

      public let dependencies: Set<Schema.Keyword> = [.if]

      public let subSchema: SubSchema

      public static func build(from schemaInstance: Value, context: inout Builder.Context) throws -> Self? {
        return Self(subSchema: try context.subSchema(for: schemaInstance))
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {

        guard let ifAnn = context.siblingAnnotation(for: If.self), ifAnn.bool() else {
          return .valid
        }

        return context.validate(instance: .inPlace(instance), using: subSchema)
      }
    }

    public struct Else: ApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .else

      public let order: KeywordBehaviorOrder = .composites

      public let dependencies: Set<Schema.Keyword> = [.if]

      public let subSchema: SubSchema

      public static func build(from schemaInstance: Value, context: inout Builder.Context) throws -> Self? {
        return Self(subSchema: try context.subSchema(for: schemaInstance))
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {

        guard let ifAnn = context.siblingAnnotation(for: If.self), !ifAnn.bool() else {
          return .valid
        }

        return context.validate(instance: .inPlace(instance), using: subSchema)
      }
    }

    public struct DependentSchemas: ApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .dependentSchemas

      public let subSchemas: OrderedDictionary<String, SubSchema>

      public static func build(from schemaInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard let subSchemaInstances = schemaInstance.object else {
          try context.invalidType(requiredType: .object)
        }

        let subSchemas = try context.subSchemas(for: subSchemaInstances) { propertyKeyInstance, context in
          guard let propertyKey = propertyKeyInstance.string else {
            try context.invalidType(requiredType: .string)
          }
          return propertyKey
        }

        return Self(subSchemas: subSchemas)
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {
        guard let objectInstanceKeys = instance.object?.compactMap(\.key.string) else {
          return .valid
        }
        var invalidKeys: [String] = []
        for (subSchemaKey, subSchema) in subSchemas where objectInstanceKeys.contains(subSchemaKey) {
          if !context.validate(instance: .inPlace(instance), using: subSchema, at: subSchemaKey).isValid {
            invalidKeys.append(subSchemaKey)
          }
        }
        return invalidKeys.isEmpty
          ? .valid
          : .invalid("Failed to validate dependent schemas for keys: \(invalidKeys.joined(separator: ", "))")
      }
    }
  }
}
