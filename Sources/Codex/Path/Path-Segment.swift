//
//  Path-Segment.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

extension Path {

  public enum Segment {
    case root
    case current
    case child([Selector])
    case descendant([Selector])
  }

}

extension Path.Segment : Sendable {}

extension Path.Segment : Hashable {}
extension Path.Segment : Equatable {}

extension Path.Segment : CustomStringConvertible {

  public var description: String {
    switch self {
    case .root:
      "$"
    case .current:
      "@"
    case .child(let selectors):
      ".\(selectors.codexDescription)"
    case .descendant(let selectors):
      "..\(selectors.codexDescription)"
    }
  }
}

extension Array where Element == Path.Segment {

  internal var codexDescription: String {
    map(\.description).joined(separator: "")
  }

}
