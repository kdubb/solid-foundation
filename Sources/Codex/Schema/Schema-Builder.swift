//
//  Schema-Builder.swift
//  Codex
//
//  Created by Kevin Wooten on 2/5/25.
//

extension Schema {

  public enum Builder {

    public static let defaultId = URI(encoded: "local://schema").neverNil()

    public typealias Keyword = Schema.Keyword

    public static func build(
      constant schemaInstance: Value,
      resourceId: URI = defaultId,
      options: Schema.Options = .default
    ) -> Schema {
      do {
        return try build(from: schemaInstance, resourceId: resourceId, options: options)
      } catch {
        fatalError("Failed to build schema: \(error)")
      }
    }

    public static func build(
      from schemaInstance: Value,
      resourceId: URI = defaultId,
      options: Schema.Options = .default
    ) throws -> Schema {

      let schemaLocator = CompositeSchemaLocator.from(locators: [
        options.defaultSchema.schemaLocator,
        options.schemaLocator,
      ])

      let buildOptions = options.schemaLocator(schemaLocator)

      var buildContext = Context(
        instance: schemaInstance,
        baseId: resourceId,
        options: buildOptions
      )

      guard let schema = try build(from: schemaInstance, context: &buildContext) as? Schema else {
        fatalError("Invalid schema type")
      }

      return schema
    }

    internal static func build(from schemaInstance: Value, context: inout Context) throws -> SubSchema {

      let subSchema: SubSchema =
        switch schemaInstance {
        case .bool:
          try BooleanSubSchema.build(from: schemaInstance, context: &context)
        case .object:
          try ObjectSubSchema.build(from: schemaInstance, context: &context)
        default:
          try context.invalidValue(options: [Schema.InstanceType.object, Schema.InstanceType.boolean])
        }

      guard context.isResourceRoot || context.isRootScope else {
        return subSchema
      }
      // Schema defines an `id`, which implies it's a resource schema
      return Schema(
        id: context.canonicalId,
        keywordLocation: context.instanceLocation,
        anchor: context.anchor,
        dynamicAnchor: context.dynamicAnchor,
        schema: context.schema,
        instance: context.instance,
        subSchema: subSchema,
        resources: context.resources
      )

    }
  }
}
