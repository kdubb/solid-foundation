//
//  URI-PathItem.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

extension URI {

  public struct PathItem {
    public var value: String

    public init(value: String) {
      self.value = value
    }

    public static let root = PathItem(value: "")
    public static let current = PathItem(value: ".")
    public static let parent = PathItem(value: "..")
  }

}

extension URI.PathItem: Sendable {}
extension URI.PathItem: Hashable {}
extension URI.PathItem: Equatable {}

extension URI.PathItem {

  public var encoded: String {
    value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
  }

}

extension Array where Element == URI.PathItem {

  public static func from(encoded path: String, absolute: Bool) -> Self {
    let segmentStrings = path.split(separator: "/", omittingEmptySubsequences: false)
    let prefix: [URI.PathItem] = absolute && segmentStrings.first != "" ? [.root] : []
    guard !segmentStrings.isEmpty && segmentStrings != [""] else {
      return prefix
    }
    return prefix + segmentStrings.map { URI.PathItem(value: String($0)) }
  }

  public func encoded(relative: Bool) -> String {
    if relative && first?.value.contains(":") == true {
      ([.current] + self).map(\.encoded).joined(separator: "/")
    } else {
      map(\.encoded).joined(separator: "/")
    }
  }

  public var isNormalized: Bool {
    self == normalized
  }

  public var normalized: Self {
    var segments: [URI.PathItem] = []
    for (idx, segment) in enumerated() {
      switch segment {
      case .root:
        if idx == 0 || idx == self.endIndex - 1 {
          segments.append(.root)
        }
      case .current:
        if idx == 0 {
          segments.append(segment)
        }
        break
      case .parent:
        if !segments.isEmpty {
          segments.removeLast()
        }
      default:
        segments.append(segment)
      }
    }
    return segments == [.root] ? [.root] : segments
  }

  public var absolute: Self {
    if first != .root {
      return [.root] + self
    }
    return self
  }

  public var relative: Self {
    if first == .root {
      return dropFirst().asArray()
    }
    return self
  }

  public var directoryRelative: Self {
    [.current] + relative
  }

}
