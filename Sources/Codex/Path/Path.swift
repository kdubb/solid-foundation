//
//  Path.swift
//  Codex
//
//  Created by Kevin Wooten on 1/25/25.
//

public struct Path {

  public let segments: [Segment]

  public init(segments: [Segment]) {
    self.segments = segments
  }

  public func extend(_ segment: Segment) throws -> Path {
    return Path(segments: segments + [segment])
  }

  public var parent: Path {
    return Path(segments: Array(segments.dropLast()))
  }

  public static func parse(_ path: String) throws -> Path {
    try Path.Builder.parse(path)
  }

}

extension Path: Sendable {}

extension Path: Hashable {}
extension Path: Equatable {}

extension Path: CustomStringConvertible {

  public var description: String {
    "$.\(segments.map(\.description).joined(separator: "."))"
  }

}

