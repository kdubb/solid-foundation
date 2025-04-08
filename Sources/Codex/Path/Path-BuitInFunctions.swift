extension Path {

  /// Built-in functions for ``Path`` queries.
  ///
  /// Contains a collection of built-in functions that can be used in ``Path`` queries.
  ///
  /// ## JSONPath Functions
  /// The following functions are defined by JSONPath:
  /// - ``length``: Returns the length of a string, array, or object.
  /// - ``count``: Returns the number of nodes in a nodelist.
  /// - ``match``: Matches a regular expression pattern against a string.
  /// - ``search``: Searches for a regular expression pattern in a string.
  /// - ``value``: Converts a nodelist with a single element to a value.
  ///
  /// ## Codex Functions
  /// The following functions are defined by Codex:
  /// - ``key``: Returns the object key for a value, if available.
  ///
  public enum BuiltInFunctions {

    /// Length of a string, array, or object.
    ///
    /// Retrieves the length of the bytes, string, array, or object passed as an argument.
    ///
    /// - Parameter value: The string, array, or object to get the length of.
    /// - Returns: Length of the string, array, or object passed as an argument. If the argument
    ///   is not a string, array, or object, the result is ``Path/Query/Result/nothing``.
    ///
    /// - Note: Defined by RFC 6901.
    ///
    public static let length =
      function(name: "length", arguments: .value, result: .value) { arguments in
        guard case .value(let value, let path) = arguments[0] else {
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
      }

    /// Count of nodes in a nodelist.
    ///
    /// Retrieves the number of nodes in the nodelist passed as an argument.
    ///
    /// - Parameter nodes: The nodelist to count the nodes of.
    /// - Returns: The number of nodes in the provided nodelist. If the argument is not a nodelist,
    ///   the result is ``Path/Query/Result/nothing``.
    ///
    /// - Note: Defined by RFC 6901.
    ///
    public static let count =
      function(name: "count", arguments: .nodes, result: .value) { arguments in
        guard case .nodes(let nodes) = arguments[0] else {
          return .nothing
        }
        return .value(.number(nodes.count), path: nil)
      }

    /// Matches a regular expression pattern against a string.
    ///
    /// Performs a regular expression match against the entire provided string argument
    ///
    /// - Parameters:
    ///   - value: The string to match the pattern against.
    ///   - pattern: The regular expression pattern to match against the string.
    /// - Returns: `true` if the pattern matches the string, otherwise `false`. If either
    ///   argument is not a string, the result is ``Path/Query/Result/nothing``.
    ///
    /// - Note: Defined by RFC 6901.
    ///
    public static let match =
      function(name: "match", arguments: .value, .value, result: .logical) { arguments in
        guard
          arguments.count == 2,
          case .value(.string(let value), _) = arguments[0],
          case .value(.string(let pattern), _) = arguments[1]
        else {
          return .nothing
        }
        let matches = try? Regex(pattern).wholeMatch(in: value) != nil
        return .logical(matches ?? false)
      }

    /// Search for a regular expression pattern in a string.
    ///
    /// Performs a regular expression search for the provided pattern in the provided string.
    ///
    /// - Parameters:
    ///   - value: The string to search for the pattern in.
    ///   - pattern: The regular expression pattern to search for in the string.
    /// - Returns: `true` if the pattern is found in the string, otherwise `false`. If either
    ///   argument is not a string, the result is ``Path/Query/Result/nothing``.
    ///
    /// - Note: Defined by RFC 6901.
    ///
    public static let search =
      function(name: "search", arguments: .value, .value, result: .logical) { arguments in
        guard
          arguments.count == 2,
          case .value(.string(let value), _) = arguments[0],
          case .value(.string(let pattern), _) = arguments[1]
        else {
          return .nothing
        }
        let matches = try? Regex(pattern).firstMatch(in: value) != nil
        return .logical(matches ?? false)
      }

    /// Converts a nodelist with a single element to a value.
    ///
    /// If the provided nodelist has a single element, this function will return the value of that
    /// element. If the nodelist has more than one element, the result is ``Path/Query/Result/nothing``.
    ///
    /// - Parameter nodes: The nodelist to convert to a value.
    /// - Returns: The value of the first node in the nodelist. If the value is not a nodelist, or
    ///   if the nodelist has more than one element, the result is ``Path/Query/Result/nothing``.
    ///
    /// - Note: Defined by RFC 6901.
    ///
    public static let value =
      function(name: "value", arguments: .nodes, result: .logical) { arguments in
        guard case .nodes(let nodes) = arguments[0], nodes.count == 1 else {
          return .nothing
        }
        let node = nodes[0]
        return .value(node.value, path: node.path)
      }

    /// Returns the object key for a value, if available.
    ///
    /// If the provided value is contained in an object, the value's key in its containing object
    /// is returned. If the value is not contained in an object, the result is
    /// ``Path/Function/Argument/nothing``.
    ///
    /// - Parameter value: The value to return the key of.
    /// - Returns: The key of the value, or ``Path/Query/Result/nothing`` if the value is not
    ///   contained in an object.
    ///
    /// - Note: Defined by Codex.
    ///
    public static let key =
      function(name: "key", arguments: .value, result: .value) { arguments in
        guard
          case .value(let value, let path) = arguments[0],
          let path,
          case .child(let selectors, _) = path.segments.last,
          selectors.count == 1,
          case .name(let key, _) = selectors.first
        else {
          return .nothing
        }
        return .value(.string(key))
      }

  }

}
