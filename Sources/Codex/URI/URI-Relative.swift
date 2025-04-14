//
//  URI-Relative.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

import Foundation

extension URI {

  /// A relative URI reference.
  ///
  /// - SeeAlso: `URI.relative(authority:path:query:fragment:)`
  ///
  public struct RelativeReference {

    /// The authority of the URI.
    public var authority: Authority?

    /// The path of the URI.
    public var path: [PathItem]

    /// The query of the URI.
    public var query: [QueryItem]?

    /// The fragment of the URI.
    public var fragment: String?

    /// Creates a new relative URI reference.
    ///
    /// - Parameters:
    ///   - authority: The authority of the URI.
    ///   - path: The path of the URI.
    ///   - query: The query of the URI.
    ///   - fragment: The fragment of the URI.
    ///   - normalized: Whether the path should be normalized.
    public init(
      authority: Authority?,
      path: [PathItem],
      query: [QueryItem]?,
      fragment: String?,
      normalized: Bool = true
    ) {
      self.authority = authority
      self.path = normalized ? path.normalized : path
      self.query = query
      self.fragment = fragment
    }

    /// Whether the path is normalized.
    public var isNormalized: Bool {
      path.isNormalized
    }

    /// Returns a new normalized relative reference.
    public func normalized() -> Self {
      Self(
        authority: authority,
        path: path,
        query: query,
        fragment: fragment,
        normalized: true
      )
    }
  }

}

extension URI.RelativeReference: Sendable {}
extension URI.RelativeReference: Hashable {}
extension URI.RelativeReference: Equatable {}

extension URI.RelativeReference {

  /// Returns a new relative URI reference with the specified components updated.
  ///
  /// - Parameters:
  ///   - authority: The authority of the URI.
  ///   - path: The path of the URI.
  ///   - query: The query of the URI.
  ///   - fragment: The fragment of the URI.
  /// - Returns: A new relative URI reference with the specified components updated.
  ///
  public func copy(
    authority: URI.Authority? = nil,
    path: [URI.PathItem]? = nil,
    query: [URI.QueryItem]? = nil,
    fragment: String?? = nil
  ) -> Self {
    Self(
      authority: authority ?? self.authority,
      path: path ?? self.path,
      query: query ?? self.query,
      fragment: fragment ?? self.fragment
    )
  }

  /// Retrieves a specific query item by name, if present.
  ///
  /// - Parameter name: The name of the query item to retrieve
  /// - Returns: The query item if found, nil otherwise
  ///
  public func query(named name: String) -> URI.QueryItem? {
    query?.first { $0.name == name }
  }

  /// Whether the path is absolute.
  public var isAbsolutePath: Bool {
    path.first == .empty
  }

  /// The encoded path of the URI.
  public var encodedPath: String? {
    path.encoded(relative: true)
  }

  /// The encoded query of the URI.
  public var encodedQuery: String? {
    query?.encoded
  }

  /// The encoded fragment of the URI.
  public var encodedFragment: String? {
    fragment?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
  }

  /// The encoded form of the URI.
  public var encoded: String {
    let path = encodedPath ?? ""
    let query = encodedQuery.map { "?\($0)" } ?? ""
    let fragment = encodedFragment.map { "#\($0)" } ?? ""
    return "\(path)\(query)\(fragment)"
  }

  /// Converts the relative reference to a `Foundation.URL`.
  public var url: URL {
    var components = URLComponents()
    components.percentEncodedPath = encodedPath ?? ""
    components.percentEncodedQuery = encodedQuery
    components.percentEncodedFragment = fragment
    return components.url.neverNil()
  }

  /// Updates the specified components of this URI.
  ///
  /// Creates a new URI with the specified components updated, leaving the
  /// other components unchanged.
  ///
  /// - Parameter components: The components to update
  /// - Returns: A new URI with the specified components updated
  ///
  public func updating(_ components: some Sequence<URI.Component>) -> URI {
    var copy = self
    for component in components {
      switch component {
      case .path(let path):
        copy = self.copy(path: path)
      case .query(let query):
        copy = self.copy(query: query)
      case .fragment(let fragment):
        copy = self.copy(fragment: fragment)
      default:
        break
      }
    }
    return .relativeReference(copy)
  }

  /// Updates the specified components of this URI.
  ///
  /// Creates a new URI with the specified components updated, leaving the
  /// other components unchanged.
  ///
  /// - Parameter components: The components to update
  /// - Returns: A new URI with the specified components updated
  ///
  public func updating(_ components: URI.Component...) -> URI {
    updating(components)
  }

  /// Updates the fragment of this URI with the specified ``Pointer``.
  ///
  /// Creates a new URI by updating the fragment with the specified ``Pointer`` leaving
  /// the other components unchanged.
  ///
  /// - Parameter pointer: The pointer to be used as the fragment
  /// - Returns: A new URI with the fragment updated
  ///
  public func updating(fragmentPointer pointer: Pointer) -> URI {
    updating([.fragment(pointer.encoded)])
  }

  /// Updates the fragment of this URI with a ``Pointer`` built from tokens.
  ///
  /// Creates a new URI by updating the fragment with a ``Pointer`` built form the
  /// specified tokens, leaving the other components unchanged.
  ///
  /// - Parameter tokens: The reference tokens to use as the fragment
  /// - Returns: A new URI with the updated fragment
  ///
  public func updating(fragmentPointer tokens: Pointer.ReferenceToken...) -> URI {
    updating(fragmentPointer: Pointer(tokens: tokens))
  }

  /// Appends the specified ``Pointer`` to this URI's existing fragment.
  ///
  /// If this URI has a fragment, that is a valid ``Pointer``, this method appends the
  /// specified pointer to the existing fragment pointer.
  ///
  /// - Parameter pointer: The pointer to append.
  /// - Returns: A new URI with the appended fragment, or `nil` if there is no
  /// fragment or the existing fragment is not a valid ``Pointer``.
  ///
  public func appending(fragmentPointer pointer: Pointer) -> URI? {
    guard let baseFragmentPointer = self.fragment.map(Pointer.init(encoded:)) ?? nil else {
      return nil
    }
    let fragmentPointer = baseFragmentPointer / pointer
    return .relativeReference(copy(fragment: fragmentPointer.encoded))
  }

  /// Appends the specified ``Pointer`` to this URI's existing fragment.
  ///
  /// If this URI has a fragment, that is a valid ``Pointer``, this method appends the
  /// specified pointer to the existing fragment pointer.
  ///
  /// - Parameter tokens: The pointer to append.
  /// - Returns: A new URI with the appended fragment, or `nil` if there is no
  /// fragment or the existing fragment is not a valid ``Pointer``.
  ///
  public func appending(fragmentPointer tokens: Pointer.ReferenceToken...) -> URI? {
    appending(fragmentPointer: Pointer(tokens: tokens))
  }

  /// Removes the specified parts from this absolute URI.
  ///
  /// Creates a new URI with the specified parts removed, leaving the
  /// other components unchanged.
  ///
  /// - Parameter components: The parts to remove
  /// - Returns: A new absolute URI with the specified parts removed
  ///
  public func removing(_ components: some Sequence<URI.Component.Kind>) -> URI {
    var copy = self
    for component in components {
      switch component {
      case .path:
        copy = self.copy(path: [])
      case .query:
        copy = self.copy(query: [])
      case .fragment:
        copy = self.copy(fragment: .some(nil))
      default:
        break
      }
    }
    return .relativeReference(copy)
  }

  /// Removes the specified parts from this absolute URI.
  ///
  /// Creates a new URI with the specified parts removed, leaving the
  /// other components unchanged.
  ///
  /// - Parameter components: The parts to remove
  /// - Returns: A new absolute URI with the specified parts removed
  ///
  public func removing(_ components: URI.Component.Kind...) -> URI {
    removing(Set(components))
  }

  /// Resolves this relative reference against a given base URI.
  ///
  /// If this URI is relative and the provided base URI is absolute, a new asolute URI is created
  /// by resolving this URI against the base URI. If this URI is asolute or the base URI is not
  /// absolute, this method returns this URI unchanged.
  ///
  /// - Parameter base: The base absolute URI.
  /// - Returns: A new absolute URI.
  ///
  public func resolved(against base: URI.Absolute) -> URI {
    let selfPath = path
    let basePath = base.path

    var absPath: [URI.PathItem]

    if selfPath.isEmpty {
      absPath = basePath
    } else if basePath.isEmpty || (selfPath.count > 1 && selfPath.first == .empty) {
      absPath = selfPath.first != .empty ? selfPath : [.empty] + selfPath
    } else {
      var resPath: [URI.PathItem] = selfPath.first == .current ? basePath : basePath.dropLast()
      for component in selfPath {
        switch component {
        case .current:
          if resPath.last == .empty {
            resPath.removeLast()
          }
          break
        case .parent:
          resPath = resPath.dropLast()
        default:
          resPath.append(component)
        }
      }
      absPath = resPath
    }

    let query = self.query ?? base.query
    let fragment = self.fragment ?? base.fragment

    return .absolute(
      base.copy(
        path: absPath,
        query: query,
        fragment: fragment
      )
    )
  }

  /// Indicates whether this URI reference is properly percent encoded.
  ///
  /// A properly percent encoded URI reference has:
  /// - All reserved characters percent encoded
  /// - All non-ASCII characters percent encoded
  /// - No invalid percent encoding sequences
  public var isPercentEncoded: Bool {
    // Check authority if present
    if let authority = authority {
      guard authority.isPercentEncoded else { return false }
    }

    // Check query
    guard query?.allSatisfy({ $0.isPercentEncoded }) ?? true else { return false }

    // Check fragment
    if let fragment = fragment {
      guard fragment.rangeOfCharacter(from: .urlFragmentAllowed.inverted) == nil else { return false }
    }

    return true
  }

}
