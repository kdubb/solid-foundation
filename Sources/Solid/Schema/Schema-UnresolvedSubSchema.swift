//
//  Schema-Reference.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/11/25.
//

import SolidData
import SolidURI
import Atomics


extension Schema {

  // A placeholder for a schema reference that could not be resolved.
  public final class UnresolvedSubSchema: SubSchema {

    public let id: URI
    public let keywordLocation: Pointer
    public let anchor: String?
    public let dynamicAnchor: String?

    public var instance: Value { .null }

    public init(schemaId: URI) {
      self.id = schemaId
      self.keywordLocation = .root
      self.anchor = nil
      self.dynamicAnchor = nil
    }

    public func behavior<K>(_ type: K.Type) -> K? where K: KeywordBehavior & BuildableKeywordBehavior {
      return nil
    }

    public func validate(instance: Value, context: inout Validator.Context) -> Validation {
      return .invalid("Unresolved schema reference: \(id)")
    }
  }

}
