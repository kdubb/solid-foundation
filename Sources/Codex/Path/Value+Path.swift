//
//  PathQuery+Value.swift
//  Codex
//
//  Created by Kevin Wooten on 1/30/25.
//

extension Value {

  /// Executes a ``Path`` query using this value as the query argument.
  ///
  /// - Parameters:
  ///   - path: The ``Path`` to evaluate.
  ///   - delegate: An optional ``Delegate`` for getting notified of runtime query errors.
  /// - Returns: The result of the query.
  ///
  public subscript(path: Path, delegate delegate: Path.Query.Delegate? = nil) -> Path.Query.NodeList {
    Path.Query.evaluate(path: path, against: self, delegate: delegate)
  }

}
