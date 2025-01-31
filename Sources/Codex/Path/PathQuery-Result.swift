//
//  PathQuery-Result.swift
//  Codex
//
//  Created by Kevin Wooten on 1/30/25.
//

extension PathQuery {

  public enum Result {

    case nothing
    case value(Value)
    case nodelist([Value])

    public static func value(_ value: Value?) -> Self {
      guard let value = value else {
        return .nothing
      }
      return .value(value)
    }

    public static var empty: Result { .nodelist([]) }

    public var values: [Value] {
      switch self {
      case .value(let value):
        return [value]
      case .nodelist(let list):
        return list
      default:
        return []
      }
    }
  }

}

extension PathQuery.Result : Sendable {}
extension PathQuery.Result : Hashable {}
extension PathQuery.Result : Equatable {}

extension PathQuery.Result : CustomStringConvertible {

  public var description: String {
    switch self {
    case .nothing:
      return "<nothing>"
    case .value(let value):
      return value.description
    case .nodelist(let list):
      return Value.array(list).description
    }
  }

}
