//
//  PathQuery-Result.swift
//  Codex
//
//  Created by Kevin Wooten on 1/30/25.
//

extension PathQuery {

  public enum Result {

    case nothing
    case value(value: Value, path: Path)
    case nodelist([(value: Value, path: Path)])

    public static func value(_ value: Value?, path: Path) -> Self {
      guard let value = value else {
        return .nothing
      }
      return .value(value: value, path: path)
    }

    public static var empty: Result { .nodelist([]) }

    public var values: [(value: Value, path: Path)] {
      switch self {
      case .value(let value, let path):
        return [(value, path)]
      case .nodelist(let list):
        return list
      default:
        return []
      }
    }
  }

}

extension PathQuery.Result: Sendable {}

extension PathQuery.Result: Hashable {

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .nothing:
      hasher.combine(0)
    case .value(value: let value, path: let path):
      hasher.combine(value)
      hasher.combine(path)
    case .nodelist(let list):
      for (value, path) in list {
        hasher.combine(value)
        hasher.combine(path)
      }
    }
  }

}

extension PathQuery.Result: Equatable {

  public static func == (lhs: PathQuery.Result, rhs: PathQuery.Result) -> Bool {
    switch (lhs, rhs) {
    case (.nothing, .nothing):
      true
    case (.value(value: let lvalue, path: let lpath), .value(value: let rvalue, path: let rpath)):
      lvalue == rvalue && lpath == rpath
    case (.nodelist(let llist), .nodelist(let rlist)):
      llist.count == rlist.count
        && llist.enumerated()
          .allSatisfy { (i, r) in
            guard i < rlist.count else { return false }
            let l = rlist[i]
            return l.value == r.value && l.path == r.path
          }
    default:
      false
    }
  }

}

extension PathQuery.Result: CustomStringConvertible {

  public var description: String {
    switch self {
    case .nothing:
      return "<nothing>"
    case .value(let value, let path):
      return "\(value) @ \(path.description)"
    case .nodelist(let list):
      return "[\(list.map { (value, path) in "\(value) @ \(path.description)" }.joined(separator: ", "))]"
    }
  }

}
