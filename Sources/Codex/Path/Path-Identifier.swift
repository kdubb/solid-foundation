//
//  Path-Identifier.swift
//  Codex
//
//  Created by Kevin Wooten on 4/9/25.
//

extension Path {

  /// Predefined node identifiers.
  ///
  public enum Identifier: String, Hashable, Equatable, Sendable {

    /// Root node identifier.
    ///
    /// Identifies the root node of the query argument, which is the
    /// query argument itself.
    ///
    case root = "$"

    /// Current node identifier.
    ///
    /// Referes to the current node in the evaluation context when
    /// evaluating a filter expression.
    ///
    case current = "@"
  }
}
