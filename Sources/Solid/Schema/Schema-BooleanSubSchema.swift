//
//  Schema-BooleanSubSchema.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/10/25.
//

extension Schema {

  public final class BooleanSubSchema: SubSchema {

    public let id: URI
    public let keywordLocation: Pointer
    public let anchor: String?
    public let dynamicAnchor: String?
    public let allow: Bool

    public init(id: URI, keywordLocation: Pointer, anchor: String? = nil, dynamicAnchor: String? = nil, allow: Bool) {
      self.id = id
      self.keywordLocation = keywordLocation
      self.anchor = anchor
      self.dynamicAnchor = dynamicAnchor
      self.allow = allow
    }

    public var instance: Value { .bool(allow) }

    public static func build(from schemaInstance: Value, context: inout Builder.Context) throws -> Self {

      guard let allow = schemaInstance.bool else {
        try context.invalidType(requiredType: .boolean)
      }

      return Self(
        id: context.canonicalId,
        keywordLocation: context.instanceLocation,
        anchor: context.anchor,
        dynamicAnchor: context.dynamicAnchor,
        allow: allow
      )
    }

    public func prepare(context: inout Builder.Context) throws {}

    public func validate(instance: Value, context: inout Validator.Context) -> Validation {
      return allow ? .valid : .invalid("Value not allowed by schema")
    }

  }
}
