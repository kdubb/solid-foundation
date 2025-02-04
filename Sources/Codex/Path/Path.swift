//
//  Path.swift
//  Codex
//
//  Created by Kevin Wooten on 1/25/25.
//

public struct Path {

  public let segments: [Segment]

  private init(explicit segments: [Segment] = []) {
    self.segments = segments
  }

  public init(segments: [Segment]) {
    if case .root = segments.first {
      self.segments = segments
    } else {
      self.segments = [.root] + segments
    }
  }

  public init(_ segments: Segment...) {
    self.init(segments: segments)
  }

  public func appending(name: String) -> Path {
    appending(segment: .child([.name(name)]))
  }

  public func appending(index: Int) -> Path {
    appending(segment: .child([.index(index)]))
  }

  public func appending(segment: Segment) -> Path {
    return Path(segments: segments + [segment])
  }

  public var parent: Path {
    return Path(segments: Array(segments.dropLast()))
  }

  public static func parse(_ path: String) throws -> Path {
    try Path.Builder.parse(path)
  }

  public static let root = Path(explicit: [.root])
  public static let current = Path(explicit: [.current])
  public static let empty = Path(explicit: [])

  public static func root(_ segments: [Path.Segment]) -> Path { Path(segments: segments) }

}

extension Path: Sendable {}

extension Path: Hashable {}
extension Path: Equatable {}

extension Path: CustomStringConvertible {

  public var description: String {
    if segments.isEmpty {
      "none"
    } else {
      segments.map(\.description).joined(separator: "")
    }
  }

}
