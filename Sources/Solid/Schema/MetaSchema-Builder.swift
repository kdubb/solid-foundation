//
//  MetaSchema-Builder.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/9/25.
//

import SolidData
import SolidURI
import Foundation
import OrderedCollections


extension MetaSchema {

  /// A builder for ``MetaSchema`` instances.
  ///
  /// - SeeAlso: ``MetaSchema/builder()``
  ///
  public struct Builder {

    private var id: URI?
    private var vocabularies: OrderedDictionary<Vocabulary, Bool> = [:]
    private var localTypes: OrderedSet<Schema.InstanceType> = []
    private var localKeywordBehaviors: OrderedDictionary<Schema.Keyword, any Schema.KeywordBehaviorBuilder.Type> = [:]
    private var schemaLocator: SchemaLocator?
    private var options: [URI: any Sendable] = [:]

    /// Creates a new ``Builder`` instance.
    ///
    public init() {
      self.id = URI(valid: "")
      self.vocabularies = [:]
      self.localTypes = []
      self.localKeywordBehaviors = [:]
      self.schemaLocator = LocalSchemaContainer.empty
      self.options = [:]
    }

    /// Creates a new ``Builder`` instance from an existing ``MetaSchema`` instance.
    ///
    /// - Parameter metaSchema: The ``MetaSchema`` instance to create the builder from.
    ///
    public init(from metaSchema: MetaSchema) {
      self.id = metaSchema.id
      self.vocabularies = metaSchema.vocabularies
      self.localTypes = metaSchema.localTypes
      self.localKeywordBehaviors = metaSchema.localKeywordBehaviors
      self.schemaLocator = metaSchema.schemaLocator
      self.options = metaSchema.options
    }

    /// Sets the ``MetaSchema/id`` property.
    ///
    /// - Parameter id: The ``MetaSchema/id`` to set.
    /// - Returns: A new ``Builder`` instance with the ``MetaSchema/id`` set.
    ///
    public func id(_ id: URI) -> Builder {
      var builder = self
      builder.id = id
      return builder
    }

    /// Sets the ``MetaSchema/vocabularies`` property.
    ///
    /// - Parameter vocabularies: The ``MetaSchema/vocabularies`` to set.
    /// - Returns: A new ``Builder`` instance with the ``MetaSchema/vocabularies`` set.
    ///
    public func vocabularies(_ vocabularies: OrderedDictionary<Vocabulary, Bool>) -> Builder {
      var builder = self
      builder.vocabularies = vocabularies
      return builder
    }

    /// Adds the given vocabularies to the ``MetaSchema/vocabularies`` property.
    ///
    /// - Parameter vocabularies: The vocabularies to add.
    /// - Returns: A new ``Builder`` instance with the vocabularies added.
    ///
    public func vocabularies(adding vocabularies: OrderedDictionary<Vocabulary, Bool> = [:]) -> Builder {
      var builder = self
      builder.vocabularies = self.vocabularies.merging(vocabularies, uniquingKeysWith: { $1 })
      return builder
    }

    /// Removes the vocabularies with the given IDs from the ``MetaSchema/vocabularies`` property.
    ///
    /// - Parameter ids: The IDs of the vocabularies to remove.
    /// - Returns: A new ``Builder`` instance with the vocabularies removed.
    ///
    public func vocabularies(removing ids: [URI]) -> Builder {
      var builder = self
      builder.vocabularies = self.vocabularies.filter { !ids.contains($0.key.id) }
      return builder
    }

    /// Sets the ``MetaSchema/localTypes`` property.
    ///
    /// - Parameter localTypes: The ``MetaSchema/localTypes`` to set.
    /// - Returns: A new ``Builder`` instance with the ``MetaSchema/localTypes`` set.
    ///
    public func localTypes(_ localTypes: OrderedSet<Schema.InstanceType>) -> Builder {
      var builder = self
      builder.localTypes = localTypes
      return builder
    }

    /// Sets the ``MetaSchema/localKeywordBehaviors`` property.
    ///
    /// - Parameter localKeywordBehaviors: The ``MetaSchema/localKeywordBehaviors`` to set.
    /// - Returns: A new ``Builder`` instance with the ``MetaSchema/localKeywordBehaviors`` set.
    ///
    public func localKeywordBehaviors(
      _ localKeywordBehaviors: OrderedDictionary<Schema.Keyword, any Schema.KeywordBehaviorBuilder.Type>
    ) -> Builder {
      var builder = self
      builder.localKeywordBehaviors = localKeywordBehaviors
      return builder
    }

    /// Sets the ``MetaSchema/schemaLocator`` property.
    ///
    /// - Parameter schemaLocator: The ``MetaSchema/schemaLocator`` to set.
    /// - Returns: A new ``Builder`` instance with the ``MetaSchema/schemaLocator`` set.
    ///
    public func schemaLocator(_ schemaLocator: SchemaLocator) -> Builder {
      var builder = self
      builder.schemaLocator = schemaLocator
      return builder
    }

    /// Sets the ``MetaSchema/options`` property.
    ///
    /// - Parameter options: The ``MetaSchema/options`` to set.
    /// - Returns: A new ``Builder`` instance with the ``MetaSchema/options`` set.
    ///
    public func options(_ options: [URI: any Sendable]) -> Builder {
      var builder = self
      builder.options = options
      return builder
    }

    /// Updates the ``MetaSchema/options`` with the value for the given ``MetaSchema/Option``.
    ///
    /// - Parameters:
    ///   - option: The option to set the value for.
    ///   - value: The value to set the option to.
    /// - Returns: A new ``Builder`` instance with the option set.
    ///
    public func option<Value: Sendable, O: Option<Value>>(_ option: O, value: Value) -> Builder {
      var builder = self
      builder.options[option.uri] = value
      return builder
    }

    /// Builds the ``MetaSchema`` instance from the builder.
    ///
    /// - Returns: A new ``MetaSchema`` instance.
    ///
    public func build() -> MetaSchema {

      guard let id = self.id else {
        fatalError("MetaSchema.id must be set")
      }

      return MetaSchema(
        id: id,
        vocabularies: vocabularies,
        localTypes: localTypes,
        localKeywordBehaviors: localKeywordBehaviors,
        schemaLocator: schemaLocator ?? LocalSchemaContainer.empty,
        options: options
      )
    }

    /// Builds a ``MetaSchema`` from the given schema instance.
    ///
    /// - Parameters:
    ///   - schemaInstance: The schema instance to build a ``MetaSchema`` from.
    ///   - resourceId: The resource ID to use for the ``MetaSchema``.
    ///   - options: The options to use for the ``MetaSchema``.
    /// - Returns: A new ``MetaSchema``.
    /// - Throws: An error if the schema instance is invalid.
    ///
    public static func build(
      from schemaInstance: Value,
      resourceId: URI = Schema.Builder.defaultId,
      options: Schema.Options = .default
    ) throws -> MetaSchema {

      let schema = try Schema.Builder.build(from: schemaInstance, resourceId: resourceId, options: options)

      return build(from: schema)
    }

    /// Builds a ``MetaSchema`` from the given ``Schema``.
    ///
    /// - Parameter schema: The schema to build a ``MetaSchema`` from.
    /// - Returns: A new ``MetaSchema``.
    ///
    public static func build(from schema: Schema) -> MetaSchema {

      let vocabularies = schema.behavior(Schema.Identifiers.Vocabulary$.self)?.vocabularies ?? [:]

      var builder = Builder()
        .id(schema.id)
        .vocabularies(vocabularies)
        .localTypes([])
        .localKeywordBehaviors([:])
        .schemaLocator(schema)

      if vocabularies[Draft2020_12.Vocabularies.formatAssertion] != nil {
        builder = builder.option(Draft2020_12.Options.formatMode, value: .assert)
      } else {
        builder = builder.option(Draft2020_12.Options.formatMode, value: .annotate)
      }

      return builder.build()
    }

  }

}

extension MetaSchema {

  /// ``MetaSchema/Builder`` factory function.
  ///
  /// - Returns: A new ``MetaSchema/Builder`` instance.
  ///
  public static func builder() -> Builder {
    return Builder()
  }

  /// Initializes a new ``MetaSchema/Builder`` from the this instance.
  ///
  /// - Returns: A new ``MetaSchema/Builder`` instance.
  ///
  public func builder() -> Builder {
    return Builder(from: self)
  }

}
