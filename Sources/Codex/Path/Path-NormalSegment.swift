//
//  Path-NormalSegment.swift
//  Codex
//
//  Created by Kevin Wooten on 2/3/25.
//

extension Path {

  public enum NormalSegment {
    case name(String)
    case index(Int)
  }

}

extension Path.NormalSegment: Sendable {}

extension Path.NormalSegment: Hashable {}
extension Path.NormalSegment: Equatable {}

extension Path.NormalSegment: CustomStringConvertible {

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

  public init(stringLiteral value: String) {
    self = .name(value)
  }
}

extension Path.NormalSegment: ExpressibleByIntegerLiteral {

  public init(integerLiteral value: Int) {
    self = .index(value)
  }
}

extension Path {

  public init(normal normalSegments: [NormalSegment]) {
    self.init(
      segments: normalSegments.map { token in
        switch token {
        case .name(let name): .child([.name(name)])
        case .index(let index): .child([.index(index)])
        }
      }
    )
  }

  public static func normal(_ normalSegments: NormalSegment...) -> Path {
    Self(normal: normalSegments)
  }

  public var isNormal: Bool {
    segments.allSatisfy { segment in
      switch segment {
      case .child(let selectors) where selectors.count == 1:
        switch selectors.first {
        case .name, .index: true
        default: false
        }
      default:
        false
      }
    }
  }

  public var normalized: [NormalSegment] {
    let normalSegments: [NormalSegment] = segments.compactMap { segment in
      switch segment {
      case .child(let selectors) where selectors.count == 1:
        switch selectors.first {
        case .name(let name): return .name(name)
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
      []
    }
  }

}
