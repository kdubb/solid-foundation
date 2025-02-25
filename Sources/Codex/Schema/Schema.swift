//
//  Schema.swift
//  Codex
//
//  Created by Kevin Wooten on 1/25/25.
//

import Foundation
import OrderedCollections

public final class Schema {

  public let id: URI
  public let keywordLocation: Pointer
  public let anchor: String?
  public let dynamicAnchor: String?
  public let schema: MetaSchema
  public let instance: Value
  public let subSchema: SubSchema
  public let resources: [Schema]

  internal init(
    id: URI,
    keywordLocation: Pointer,
    anchor: String?,
    dynamicAnchor: String?,
    schema: MetaSchema,
    instance: Value,
    subSchema: SubSchema,
    resources: [Schema]
  ) {
    self.id = id
    self.keywordLocation = keywordLocation
    self.anchor = anchor
    self.dynamicAnchor = dynamicAnchor
    self.schema = schema
    self.instance = instance
    self.subSchema = subSchema
    self.resources = resources
  }

  public func validate(
    instance: Value,
    outputFormat: Schema.Validator.OutputFormat = .basic,
    options: Schema.Options = .default
  ) throws -> Validator.Result {

    let schemaLocator = CompositeSchemaLocator.from(locators: [
      schema.schemaLocator,
      options.schemaLocator
    ].compactMap(\.self))

    let metaSchemaLocator = CompositeMetaSchemaLocator(locators: [
      options.metaSchemaLocator,
      MetaSchemaContainer(schemaLocator: schemaLocator)
    ])

    let validatorOptions = options
      .schemaLocator(schemaLocator)
      .metaSchemaLocator(metaSchemaLocator)

    var context = Validator.Context.root(
      instance: instance,
      schema: self,
      outputFormat: outputFormat,
      options: validatorOptions
    )

    let validation = validate(instance: instance, context: &context)

    return context.result(validation: validation)
  }

}

extension Schema: Sendable {}

extension Schema: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

}

extension Schema: Equatable {

  public static func == (lhs: Schema, rhs: Schema) -> Bool {
    lhs.id == rhs.id
  }

}

extension Schema: Schema.SubSchema {

  public func behavior<K>(_ type: K.Type) -> K? where K : KeywordBehavior & BuildableKeywordBehavior {
    subSchema.behavior(type)
  }

  public func validate(instance: Value, context: inout Validator.Context) -> Validation {
    subSchema.validate(instance: instance, context: &context)
  }

}

extension Schema: SchemaLocator {

  public func isRootSchemaReference(schemaId: URI) -> Bool {
    self.id == schemaId || self.id.removing(.fragment) == schemaId.removing(.fragment)
  }

  public func locate(schemaId: URI, options: Schema.Options) -> Schema? {

    if isRootSchemaReference(schemaId: schemaId) {

      return self

    }

    for resource in resources {
      if let schema = resource.locate(schemaId: schemaId, options: options) {
        return schema
      }
    }

    return nil
  }


  public func locate(fragment: String, allowing refTypes: RefTypes) -> SubSchema? {

    if isReferencingFragment(fragment, allowing: refTypes) {
      return self
    }

    return subSchema.locate(fragment: fragment, allowing: refTypes)
  }

}
