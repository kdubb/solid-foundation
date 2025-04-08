//
//  Path-NormalSegment.swift
//  Codex
//
//  Created by Kevin Wooten on 2/3/25.
//

extension Path {

  /// A "normal" segment of a path.
  ///
  /// A normal segment is a ``Segment/child(_:shorthand:)`` segment containers either:
  ///   1. A single ``Selector/name(_:quote:)`` selector, representing a child at a specific key in an object.
  ///   2. A single ``Selector/index(_:)`` selector, representing a child at a specific index in an array.
  ///
  /// ``NormalSegment`` is used to represent normal segments with a more convenient API but are not used
  ///  in the ``Path`` itself. Instead, normal segments are passed to ``Path/normal(_:)``  to initialize normal
  ///  ``Path`` instances and are returned from ``Path/normalized`` if the path is already "normal".
  ///
  /// - SeeAlso: ``Path/Selector``
  ///
  public enum NormalSegment {

    /// A named child.
    ///
    /// Represents a child at a specific key name in an object.
    ///
    /// - Parameter name: The name of the child or descendants.
    ///
    case name(String)

    /// An indexed child.
    ///
    /// Represents a child at a specific index in an array.
    ///
    /// - Parameter index: The index of the child.
    ///
    case index(Int)
  }

}

extension Path.NormalSegment: Sendable {}

extension Path.NormalSegment: Hashable {}
extension Path.NormalSegment: Equatable {}

extension Path.NormalSegment: CustomStringConvertible {

  /// A human-readable description of the normal segment.
  ///
  /// A description of the normal segment, showing the name or index.
  ///
  public var description: String {
    switch self {
    case .name(let name):
      return name
    case .index(let index):
      return index.description
    }
  }
}

extension Path.NormalSegment: ExpressibleByStringLiteral {

  /// Initialize a ``NormalSegment`` from a string literal.
  ///
  /// - Parameter value: The string literal to initialize the ``NormalSegment`` from.
  ///
  public init(stringLiteral value: String) {
    self = .name(value)
  }
}

extension Path.NormalSegment: ExpressibleByIntegerLiteral {

  /// Initialize a ``NormalSegment`` from an integer literal.
  ///
  /// - Parameter value: The integer literal to initialize the ``NormalSegment`` from.
  ///
  public init(integerLiteral value: Int) {
    self = .index(value)
  }
}

extension Path {

  /// Initialize a ``Path`` from an array of ``NormalSegment`` instances.
  ///
  /// - Parameter normalSegments: The array of ``NormalSegment`` instances to initialize the ``Path`` from.
  ///
  public init(normal normalSegments: [NormalSegment]) {
    self.init(
      segments: normalSegments.map { token in
        switch token {
        case .name(let name): .child([.name(name, quote: "'")])
        case .index(let index): .child([.index(index)])
        }
      }
    )
  }

  /// Normal ``Path`` factory.
  ///
  /// Factory initializer for creating a normal ``Path`` instances from a number of
  /// ``NormalSegment`` instances.
  ///
  /// - Parameter normalSegments: The ``NormalSegment`` instances to initialize the ``Path`` from.
  /// - Returns: A ``Path`` instance with the given normal segments.
  ///
  public static func normal(_ normalSegments: NormalSegment...) -> Path {
    Self(normal: normalSegments)
  }

  /// Normal ``Path`` factory.
  ///
  /// Factory initializer for creating a normal ``Path`` instances from an array of
  /// ``NormalSegment`` instances.
  ///
  /// - Parameter normalSegments: The ``NormalSegment`` instances to initialize the ``Path`` from.
  /// - Returns: A ``Path`` instance with the given normal segments.
  ///
  public static func normal(_ normalSegments: [NormalSegment]) -> Path {
    Self(normal: normalSegments)
  }

  /// Check if the path is a normal path.
  ///
  /// A normal path is a path that is composed of only ``NormalSegment`` instances.
  ///
  public var isNormal: Bool {
    segments.allSatisfy { segment in
      switch segment {
      case .child(let selectors, _) where selectors.count == 1:
        switch selectors.first {
        case .name, .index: true
        default: false
        }
      default:
        false
      }
    }
  }

  /// Normalize this path.
  ///
  /// Creates a new normalized ``Path``, if possible. Normalization will only succeed
  /// when all the segments of this path are ``NormalSegment`` instances.
  ///
  /// - Returns: A list of normal segments equivalent to _this_ path. If the path is not normal, `nil` is returned.
  ///
  public var normalized: [NormalSegment]? {
    let normalSegments: [NormalSegment] = segments.compactMap { segment in
      switch segment {
      case .child(let selectors, _) where selectors.count == 1:
        switch selectors.first {
        case .name(let name, _): return .name(name)
        case .index(let index): return .index(index)
        default: return nil
        }
      default:
        return nil
      }
    }
    return if normalSegments.count == segments.count {
      normalSegments
    } else {
      nil
    }
  }

}
