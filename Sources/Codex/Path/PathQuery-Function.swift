//
//  PathQuery-Function.swift
//  Codex
//
//  Created by Kevin Wooten on 1/30/25.
//

extension PathQuery {

  public struct Function {

    public enum ArgumentType {
      case value
      case logical
      case nodes
    }

    public enum Argument {

      case nothing
      case value(Value, path: Path)
      case logical(Bool)
      case nodes([(value: Value, path: Path)])
    }

    let name: String
    let arguments: [ArgumentType]
    let execute: @Sendable ([Argument]) -> Argument

    public init(name: String, arguments: [ArgumentType], execute: @Sendable @escaping ([Argument]) -> Argument) {
      self.name = name
      self.arguments = arguments
      self.execute = execute
    }

  }

  public static func function(
    name: String,
    arguments: Function.ArgumentType...,
    execute: @Sendable @escaping ([Function.Argument]) -> Function.Argument
  ) -> Function {
    function(name: name, arguments: arguments, execute: execute)
  }

  public static func function(
    name: String,
    arguments: [Function.ArgumentType],
    execute: @Sendable @escaping ([Function.Argument]) -> Function.Argument
  ) -> Function {
    return Function(name: name, arguments: arguments, execute: execute)
  }

  public static let standardFunctions = [
    /// Length of a string, array, or object
    function(name: "length", arguments: .value) { arguments in
      guard case .value(let value, _) = arguments[0] else {
        return .nothing
      }
      switch value {
      case .bytes(let bytes):
        return .value(.number(bytes.count), path: .empty)
      case .string(let string):
        return .value(.number(string.unicodeScalars.count), path: .empty)
      case .array(let array):
        return .value(.number(array.count), path: .empty)
      case .object(let object):
        return .value(.number(object.count), path: .empty)
      default:
        return .nothing
      }
    },
    /// Length of a string, array, or object
    function(name: "count", arguments: .nodes) { arguments in
      guard case .nodes(let nodes) = arguments[0] else {
        return .nothing
      }
      return .value(.number(nodes.count), path: .empty)
    },
    /// Match a regular expression pattern against a string
    function(name: "match", arguments: .value, .value) { arguments in
      guard
        arguments.count == 2,
        case .value(.string(let value), let valuePath) = arguments[0],
        case .value(.string(let pattern), let patternPath) = arguments[1]
      else {
        return .nothing
      }
      let matches = try? Regex(pattern).wholeMatch(in: value) != nil
      return .value(.bool(matches ?? false), path: .empty)
    },
    /// Search for a regular exression pattern in a string
    function(name: "search", arguments: .value, .value) { arguments in
      guard
        arguments.count == 2,
        case .value(.string(let value), let path) = arguments[0],
        case .value(.string(let pattern), let path) = arguments[1]
      else {
        return .nothing
      }
      let matches = try? Regex(pattern).firstMatch(in: value) != nil
      return .value(.bool(matches ?? false), path: .empty)
    },
    /// Converts nodes with a single element to a value
    function(name: "value", arguments: .nodes) { arguments in
      guard case .nodes(let nodes) = arguments[0], nodes.count == 1 else {
        return .nothing
      }
      return .value(nodes[0].value, path: nodes[0].path)
    },
    /// Returns the object key for the argument, if available, else nothing
    function(name: "key", arguments: .value) { arguments in
      guard
        case .value(let value, let path) = arguments[0],
        case .child(let selectors) = path.segments.last,
        selectors.count == 1,
        case .name(let key) = selectors.first
      else {
        return .nothing
      }
      return .value(.string(key), path: .empty)
    }
  ]

}

extension PathQuery.Function: Sendable {}

extension PathQuery.Function: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(arguments)
  }

}

extension PathQuery.Function: Equatable {

  public static func ==(lhs: PathQuery.Function, rhs: PathQuery.Function) -> Bool {
    lhs.name == rhs.name && lhs.arguments == rhs.arguments
  }

}


extension PathQuery.Function.Argument: Sendable {}

extension PathQuery.Function.Argument: Hashable {

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .nothing:
      hasher.combine(Int.max)
    case .logical(let bool):
      hasher.combine(bool)
    case .value(let value, path: let path):
      hasher.combine(value)
      hasher.combine(path)
    case .nodes(let list):
      for (value, path) in list {
        hasher.combine(value)
        hasher.combine(path)
      }
    }
  }

}

extension PathQuery.Function.Argument: Equatable {

  public static func ==(lhs: PathQuery.Function.Argument, rhs: PathQuery.Function.Argument) -> Bool {
    switch (lhs, rhs) {
    case (.nothing, .nothing): true
    case (.logical(let lbool), .logical(let rbool)): lbool == rbool
    case (.value(let lval, _), .value(let rval, _)): lval == rval
    case (.nodes(let lnodes), .nodes(let rnodes)): lnodes.map(\.value) == rnodes.map(\.value)
    default: false
    }
  }

}


extension PathQuery.Function.ArgumentType: Sendable {}

extension PathQuery.Function.ArgumentType: Hashable {}
extension PathQuery.Function.ArgumentType: Equatable {}
