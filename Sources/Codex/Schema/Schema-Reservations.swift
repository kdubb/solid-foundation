//
//  Schema-Reservations.swift
//  Codex
//
//  Created by Kevin Wooten on 2/8/25.
//

import OrderedCollections

extension Schema {

  public enum Reservations {

    public struct Defs$: ReservedBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .defs$

      public let schemas: OrderedDictionary<String, Schema.SubSchema>

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard let definitionInstances = keywordInstance.object else {
          try context.invalidType(requiredType: .object)
        }

        var schemas: OrderedDictionary<String, SubSchema> = [:]

        for (definitionNameInstance, definitionInstance) in definitionInstances {

          guard let definitionName = definitionNameInstance.string else {
            try context.invalidValue("Must be a string")
          }

          schemas[definitionName] = try context.subSchema(for: definitionInstance, at: [definitionName])
        }

        return Self(schemas: schemas)
      }

    }

    public struct Comment$: ReservedBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .comment$

      public let comment: String

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .string(let comment) = keywordInstance else {
          try context.invalidType(requiredType: .string)
        }

        return Self(comment: comment)
      }
    }

  }

}
