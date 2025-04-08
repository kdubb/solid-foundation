//
//  Path-Query-Node.swift
//  Codex
//
//  Created by Kevin Wooten on 1/30/25.
//

extension Path.Query {

  /// ``Value`` and ``Path`` pair representing a node in a JSON-Value like tree.
  ///
  /// Nodes are returned from query evaluations in a ``NodeList``. They contain
  /// the value of the node and the path to that node in the tree. The path is always
  /// ``Path/`` starting at the root (aka
  /// the query argument).
  ///
  public struct Node {

    /// Vue of the node.
    public var value: Value
    /// Normal path to the node in the tree.
    public var path: Path

    /// Initializes a node with the specified value and path.
    ///
    /// - Parameters:
    ///   - value: The value of the node.
    ///   - path: The normal path to ``value`` in the ``Value`` tree.
    ///
    public init(value: Value, path: Path) {
      self.value = value
      self.path = path
    }

    public static func node(_ value: Value, _ path: Path) -> Node {
      .init(value: value, path: path)
    }
  }

}

extension Path.Query.Node: Sendable {}

extension Path.Query.Node: Hashable {}
extension Path.Query.Node: Equatable {}

extension Path.Query.Node: CustomStringConvertible {

  public var description: String {
    "\(value) @ \(path)"
  }

}
