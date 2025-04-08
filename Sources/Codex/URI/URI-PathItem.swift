//
//  URI-PathItem.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

extension URI {

  /// A segment of a URI path.
  ///
  /// Path items represent individual segments of a URI path,
  /// such as "users", "profile", or "settings" in "/users/profile/settings".
  public struct PathItem {

    /// The raw value of the path segment.
    public var value: String

    /// Creates a new path item with the given value.
    ///
    /// - Parameter value: The raw value of the path segment
    public init(value: String) {
      self.value = value
    }

    /// A path item representing the root path.
    public static let root = PathItem(value: "")
    /// A path item representing the current directory.
    public static let current = PathItem(value: ".")
    /// A path item representing the parent directory.
    public static let parent = PathItem(value: "..")
  }

}

extension URI.PathItem: Sendable {}
extension URI.PathItem: Hashable {}
extension URI.PathItem: Equatable {}

extension URI.PathItem {

  /// The percent-encoded string representation of this path item.
  ///
  /// Characters that are not allowed in URI paths are percent-encoded.
  public var encoded: String {
    value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
  }

}

extension Array where Element == URI.PathItem {

  /// Creates an array of path items from an encoded path string.
  ///
  /// - Parameters:
  ///   - path: The encoded path string
  ///   - absolute: Whether the path is absolute (starts with "/")
  /// - Returns: An array of path items
  public static func from(encoded path: String, absolute: Bool) -> Self {
    let segmentStrings = path.split(separator: "/", omittingEmptySubsequences: false)
    let prefix: [URI.PathItem] = absolute && segmentStrings.first != "" ? [.root] : []
    guard !segmentStrings.isEmpty && segmentStrings != [""] else {
      return prefix
    }
    return prefix + segmentStrings.map { URI.PathItem(value: String($0)) }
  }

  /// Returns the encoded string representation of this path.
  ///
  /// - Parameter relative: Whether the path should be treated as relative
  /// - Returns: The encoded path string
  public func encoded(relative: Bool) -> String {
    if relative && first?.value.contains(":") == true {
      ([.current] + self).map(\.encoded).joined(separator: "/")
    } else {
      map(\.encoded).joined(separator: "/")
    }
  }

  /// Whether all path items are normalized.
  public var isNormalized: Bool {
    self == normalized
  }

  /// Returns a new normalized path from this path.
  ///
  /// - Returns: A new normalized path
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

  /// Returns a new absolute path from this path.
  ///
  /// - Returns: A new absolute path
  ///
  public var absolute: Self {
    if first != .root {
      return [.root] + self
    }
    return self
  }

  /// Returns a new relative path from this path.
  ///
  /// - Returns: A new relative path
  ///
  public var relative: Self {
    if first == .root {
      return dropFirst().asArray()
    }
    return self
  }

  /// Returns a new current directory relative path from this path.
  ///
  /// - Returns: A new current directory relative path
  ///
  public var directoryRelative: Self {
    [.current] + relative
  }

}
