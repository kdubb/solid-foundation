//
//  Path-Segment.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

extension Path {

  public enum Segment {
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
    case .child(let selectors):
      return selectors.map(\.description).joined(separator: ".")
    case .descendant(let selectors):
      return selectors.map(\.description).joined(separator: "..")
    }
  }
}
