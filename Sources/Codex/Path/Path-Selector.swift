//
//  Path-Selector.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

extension Path {

  public enum Selector {
    case name(String)
    case wildcard
    case slice(Slice)
    case index(Int)
    case filter(Expression)
  }

}

extension Path.Selector : Sendable {}

extension Path.Selector : Hashable {}
extension Path.Selector : Equatable {}

extension Path.Selector : CustomStringConvertible {

  public var description: String {
    switch self {
    case .name(let name):
      return name
    case .wildcard:
      return "*"
    case .slice(let slice):
      return slice.description
    case .index(let index):
      return index.description
    case .filter(let expression):
      return expression.description
    }
  }
}

extension Array where Element == Path.Selector {

  internal var codexDescription: String {
    switch count {
    case 0:
      "<invalid>"
    case 1:
      self[0].description
    default:
      "[\(self.map(\.description).joined(separator: ", "))]"
    }
  }

}
