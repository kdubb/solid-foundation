//
//  URI-PathItem.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/25/25.
//

extension URI {

  /// A segment of a URI path.
  ///
  /// Path items represent individual segments of a URI path,
  /// such as "users", "profile", or "settings" in "/users/profile/settings".
  public enum PathItem {
    /// Empty path segment.
    ///
    /// An empty path segment, such as in "/users//profile". The empty segment is
    /// encoded as an empty string. Empty segments can appear anywhere in a path
    /// but when it is the first segment, it represents the root, making it an absolute path.
    ///
    /// When normalized, empty segments are removed from the path, unless they are
    /// the first segment (root) or the last segment. URI parsing *always* normalizes paths,
    /// thereby removing empty segments.
    ///
    case empty

    /// Current directory segment.
    ///
    /// Represents the current directory in a path. It is encoded as a single dot ("."). For
    /// example, in the path "/users/profile/.", the "." represents the current directory
    /// (i.e., "profile").
    ///
    /// Currrent directory segments are primarily useful as the first segment in relative paths.
    /// In this case, it ensures that a resolved absolute path is relative to the base path's last
    /// segment. For example, if the relative path is "./profile/settings" and the base path is
    /// "/root/users", the resolved path would be "/root/users/profile/settings". Without the
    /// current directory segment (e.g.  "profile/settings"), the relative path becomes a sibling
    /// of the base path, resulting in "/root/profile/settings".
    ///
    /// When normalized, current directory segments are removed from the path, unless they are
    /// the first segment. URI parsing *always* normalizes paths, thereby removing current segments
    /// not at the root of the path.
    ///
    case current

    /// Parent directory segment.
    ///
    /// Represents the parent directory in a path. It is encoded as two dots (".."). For example,
    /// in the path "/users/profile/..", the ".." represents the parent directory (i.e., "users").
    ///
    /// When normalized, parent directory segments are removed from the path, unless they are
    /// the first segment. URI parsing *always* normalizes paths, thereby removing parent segments
    /// not at the root of the path.
    ///
    case parent

    /// Decoded path segment.
    ///
    /// Token segments are any valid segment of in the path that is not ``empty``, ``parent``, or
    /// ``current``. Tokens are encoded using percent-encoding, which means that reserved characters
    /// are replaced with their percent-encoded representation. For example, in the path "/users/profile/settings",
    /// the "users", "profile", and "settings" segments are all token segments.
    ///
    /// Using separate case for token segments ensures that you cannot create a segment that gets encoded
    /// as a special segment. For example, the token segment with ".." gets encoded as "%2E%2E", ensuring
    /// that it is not interpreted as a parent directory segment.
    ///
    case decoded(String)

    /// Name path segment.
    ///
    /// Represents a name segment that is not percent-encoded.
    ///
    /// > Note! This is a special case for URN style URIs where the path is not percent-encoded. For example,
    /// > the path "urn:example:12345" would have a single path name segment of "example:12345".
    ///
    case name(String)
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
    switch self {
    case .empty:
      ""
    case .current:
      "."
    case .parent:
      ".."
    case .decoded(let value):
      if value == "." || value == ".." {
        value.addingPercentEncoding(withAllowedCharacters: []) ?? ""
      } else {
        // Encode the token value using percent-encoding
        value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
      }
    case .name(let value):
      value
    }
  }

  /// The decoded string representation of this path item.
  ///
  /// - Returns: The decoded string representation of this path item
  /// or nil if this is a special segment (empty, current, or parent).
  public var decoded: String? {
    switch self {
    case .decoded(let value):
      return value
    case .name(let value):
      return value
    case .empty, .current, .parent:
      return nil
    }
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
    let prefix: [URI.PathItem] = absolute && segmentStrings.first != "" ? [.empty] : []
    guard !segmentStrings.isEmpty && segmentStrings != [""] else {
      return prefix
    }
    return prefix
      + segmentStrings.map { segmentString in
        if segmentString == "." {
          return .current
        } else if segmentString == ".." {
          return .parent
        } else if segmentString.isEmpty {
          return .empty
        } else if let decoded = segmentString.removingPercentEncoding {
          return .decoded(decoded)
        } else {
          return .decoded(String(segmentString))
        }
      }
  }

  /// Returns the encoded string representation of this path.
  ///
  /// - Parameter relative: Whether the path should be treated as relative
  /// - Returns: The encoded path string
  public func encoded(relative: Bool) -> String {
    if relative && first?.encoded.contains(":") == true {
      ([.current] + self).map(\.encoded).joined(separator: "/")
    } else if count == 1 && first == .empty {
      "/"
    } else {
      map(\.encoded).joined(separator: "/")
    }
  }

  /// Whether all path items are normalized.
  public var isNormalized: Bool {
    self == normalized()
  }

  /// Returns a new normalized path from this path.
  ///
  /// - Returns: A new normalized path
  public func normalized(retainLeadingRelativeSegments: Bool = true, retainTrailingEmptySegment: Bool = true) -> Self {
    var segments: [URI.PathItem] = []
    for (idx, segment) in enumerated() {
      switch segment {
      case .empty where idx == 0:
        segments.append(.empty)
      case .empty where idx == endIndex - 1 && retainTrailingEmptySegment:
        segments.append(.empty)
      case .empty:
        // skip empty segments not at the start or end
        break
      case .current where idx == 0 && retainLeadingRelativeSegments:
        segments.append(segment)
      case .current:
        // skip current segments not at the start
        break
      case .parent where idx == 0 && retainLeadingRelativeSegments:
        segments.append(segment)
      case .parent:
        // remove the last segment if it is not the root
        if !segments.isEmpty {
          segments.removeLast()
        } else {
          segments.append(segment)
        }
      default:
        // add all other segments
        segments.append(segment)
      }
    }
    return segments
  }

  /// Returns a new absolute path from this path.
  ///
  /// - Returns: A new absolute path
  ///
  public var absolute: Self {
    if first != .empty {
      return [.empty] + self
    }
    return self
  }

  /// Returns a new relative path from this path.
  ///
  /// - Returns: A new relative path
  ///
  public var relative: Self {
    if first == .empty {
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
