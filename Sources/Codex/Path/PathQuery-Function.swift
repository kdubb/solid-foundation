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
      case value(Value)
      case logical(Bool)
      case nodes([Value])
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
      guard case .value(let value) = arguments[0] else {
        return .nothing
      }
      switch value {
      case .bytes(let bytes):
        return .value(.number(bytes.count))
      case .string(let string):
        return .value(.number(string.unicodeScalars.count))
      case .array(let array):
        return .value(.number(array.count))
      case .object(let object):
        return .value(.number(object.count))
      default:
        return .nothing
      }
    },
    /// Length of a string, array, or object
    function(name: "count", arguments: .nodes) { arguments in
      guard case .nodes(let nodes) = arguments[0] else {
        return .nothing
      }
      return .value(.number(nodes.count))
    },
    /// Match a regular expression pattern against a string
    function(name: "match", arguments: .value, .value) { arguments in
      guard
        arguments.count == 2,
        case .value(.string(let value)) = arguments[0],
        case .value(.string(let pattern)) = arguments[1]
      else {
        return .nothing
      }
      let matches = try? Regex(pattern).wholeMatch(in: value) != nil
      return .value(.bool(matches ?? false))
    },
    /// Search for a regular exression pattern in a string
    function(name: "search", arguments: .value, .value) { arguments in
      guard
        arguments.count == 2,
        case .value(.string(let value)) = arguments[0],
        case .value(.string(let pattern)) = arguments[1]
      else {
        return .nothing
      }
      let matches = try? Regex(pattern).firstMatch(in: value) != nil
      return .value(.bool(matches ?? false))
    },
    /// Converts nodes with a single element to a value
    function(name: "value", arguments: .nodes) { arguments in
      guard case .nodes(let nodes) = arguments[0], nodes.count == 1 else {
        return .nothing
      }
      return .value(nodes[0])
    },
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

extension PathQuery.Function.Argument: Hashable {}
extension PathQuery.Function.Argument: Equatable {}


extension PathQuery.Function.ArgumentType: Sendable {}

extension PathQuery.Function.ArgumentType: Hashable {}
extension PathQuery.Function.ArgumentType: Equatable {}
