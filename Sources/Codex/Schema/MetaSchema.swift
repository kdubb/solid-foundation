//
//  MetaSchema.swift
//  Codex
//
//  Created by Kevin Wooten on 2/8/25.
//

import Foundation
import OrderedCollections

public final class MetaSchema {

  public typealias Keyword = Schema.Keyword

  public let id: URI
  public let vocabularies: [Vocabulary]
  public let types: OrderedSet<Schema.InstanceType>
  public let keywordBehaviors: OrderedDictionary<Schema.Keyword, any Schema.KeywordBehaviorBuilder.Type>
  public let schemaLocator: SchemaLocator
  public let keywords: OrderedSet<Keyword>
  public let identifierKeywords: OrderedSet<Keyword>
  public let applicatorKeywords: OrderedSet<Keyword>

  public init(id: URI, vocabularies: [Vocabulary], schemaLocator: SchemaLocator) {
    self.id = id
    self.vocabularies = vocabularies
    self.types = OrderedSet(vocabularies.flatMap { Array($0.types) })
    self.keywords = OrderedSet(vocabularies.flatMap(\.keywordBehaviors.keys))
    self.keywordBehaviors = vocabularies.reduce(into: [:]) { result, vocabulary in
      for (keyword, behavior) in vocabulary.keywordBehaviors {
        result[keyword] = behavior
      }
    }
    self.schemaLocator = schemaLocator
    self.identifierKeywords = OrderedSet(
      keywordBehaviors.filter { $0.value is Schema.IdentifierBehavior.Type }.map { $0.key }
    )
    self.applicatorKeywords = OrderedSet(
      keywordBehaviors.filter { $0.value is Schema.ApplicatorBehavior.Type }.map { $0.key }
    )
  }

  public func keywordBehavior(for keyword: Keyword) -> (any Schema.KeywordBehaviorBuilder.Type)? {
    return keywordBehaviors[keyword]
  }

}

extension MetaSchema: Sendable {}

extension MetaSchema: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

}

extension MetaSchema: Equatable {

  public static func ==(lhs: MetaSchema, rhs: MetaSchema) -> Bool {
    return lhs.id == rhs.id
  }

}
