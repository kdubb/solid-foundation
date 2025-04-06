//
//  Schema-Subschema.swift
//  Codex
//
//  Created by Kevin Wooten on 2/2/25.
//

import Atomics

extension Schema {

  /// A validatable piece of schema, which can be a simple schema object, a boolean schema, or a root schema object.
  ///
  public protocol SubSchema: AnyObject, SubSchemaLocator, Sendable {

    /// Canonical identifier of the schema.
    ///
    /// All sub-schemas have an identifier that is formed by it's base identifier (from the nearest root
    /// resource schema) and either a JSON Pointer from the root resource schema or an anchor
    /// reference explicitly specified in the schema.
    ///
    /// - Note: The fragment of the identifier will be equal to the ``anchor``, if provided,
    /// or the ``pointer`` when no ``anchor`` is provided.
    var id: URI { get }

    /// Keyword location path of this sub-schema as a JSON Pointer.
    ///
    /// The path is relative to the nearest root resource schema and is
    /// automatically determined by the schema builder.
    var keywordLocation: Pointer { get }

    /// Anchor reference as specified in the schema.
    var anchor: String? { get }

    /// Dynamic anchor reference as specified in the schema.
    var dynamicAnchor: String? { get }

    /// The schema instance.
    var instance: Value { get }

    /// Locates a keyword behavior of the sub-schema by it's type and the ``Schema/Keyword`` associated with it.
    ///
    /// - Note: This only looks for keywords in the current schem and does not traverse any applicators to consider
    /// adjacent keywords in sub-schemas.
    ///
    /// - Parameter type: The type of behavior to locate.
    func behavior<K: KeywordBehavior & BuildableKeywordBehavior>(_ type: K.Type) -> K?

    /// Validates an instance against the schema.
    ///
    /// - Warning: This method should not be called directly. Use ``Schema/Validator``, or the
    /// ``Schema/validate(instance:outputFormat:options:)`` convenience method, to validate
    ///  an instance.
    ///
    /// - Parameters:
    ///  - instance: The instance to validate.
    ///  - context: The validation context.
    func validate(instance: Value, context: inout Validator.Context) -> Validation
  }

}

extension Schema.SubSchema {

  /// Check if the given fragment is referencing this schema, only considering the provided reference types.
  ///
  /// - Parameters:
  ///  - fragment: The fragment identifier to check.
  ///  - refTypes: The reference types to consider.
  ///  - Returns: `true` if the fragment is referencing this schema, otherwise `false`.
  public func isReferencingFragment(_ fragment: String, allowing refTypes: Schema.RefTypes) -> Bool {
    (refTypes.contains(.canonical) && fragment == (self.id.fragment ?? ""))
      || (refTypes.contains(.keywordLocation) && fragment == self.keywordLocation.encoded)
      || (refTypes.contains(.anchor) && fragment == self.anchor)
      || (refTypes.contains(.dynamicAnchor) && fragment == self.dynamicAnchor)
  }

  /// Check if the given fragment is referencing this schema, considering the standard reference types.
  ///
  /// - Parameters:
  ///  - fragment: The fragment identifier to check.
  ///  - Returns: `true` if the fragment is referencing this schema, otherwise `false`.
  public func isReferencingFragment(_ fragment: String) -> Bool {
    isReferencingFragment(fragment, allowing: .standard)
  }

  public func locate(fragment: String, allowing refTypes: Schema.RefTypes) -> Schema.SubSchema? {

    if isReferencingFragment(fragment, allowing: refTypes) {
      return self
    }

    return nil
  }

}

extension Schema.SubSchema {

  public func behavior<K: Schema.KeywordBehavior & Schema.BuildableKeywordBehavior>(_ type: K.Type) -> K? { nil }

}
