//
//  URI-Absolute.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

import Foundation

extension URI {

  /// An absolute URI.
  ///
  /// An absolute URI contains all components of a URI, including the scheme,
  /// authority, path, query, and fragment.
  public struct Absolute {

    /// The scheme component (e.g., "http", "https").
    public var scheme: String
    /// The authority component.
    public var authority: Authority
    /// The path component.
    public var path: [PathItem]
    /// The query component.
    public var query: [QueryItem]
    /// The fragment component.
    public var fragment: String?

    /// Creates a new absolute URI.
    ///
    /// - Parameters:
    ///   - scheme: The scheme component
    ///   - authority: The authority component
    ///   - path: The path component
    ///   - query: The query component
    ///   - fragment: The fragment component
    ///   - normalized: Whether to normalize the path
    public init(
      scheme: String,
      authority: Authority,
      path: [PathItem],
      query: [URI.QueryItem],
      fragment: String?,
      normalized: Bool = true
    ) {
      self.scheme = scheme
      self.authority = authority
      self.path = normalized ? path.normalized : path
      self.query = query
      self.fragment = fragment
    }

    /// Indicates whether this URI is in its normalized form.
    ///
    /// A normalized URI has:
    /// - No empty path segments
    /// - No trailing slash unless it's the root path
    public var isNormalized: Bool {
      path.isNormalized
    }

    /// Returns a normalized version of this URI.
    ///
    /// Normalization includes:
    /// - Removing empty path segments
    /// - Removing trailing slash unless it's the root path
    /// - Sorting query parameters
    public func normalized() -> Self {
      Self(
        scheme: scheme,
        authority: authority,
        path: path,
        query: query,
        fragment: fragment,
        normalized: true
      )
    }
  }

}

extension URI.Absolute: Sendable {}
extension URI.Absolute: Hashable {}
extension URI.Absolute: Equatable {}

extension URI.Absolute {

  /// Creates a copy of this absolute URI with one or more optional modifications.
  ///
  /// - Parameters:
  ///   - scheme: The new scheme, or `nil` to leave the scheme unchanged
  ///   - authority: The new authority, or `nil` to leave the authority unchanged
  ///   - path: The new path, or `nil` to leave the path unchanged
  ///   - query: The new query, or `nil` to leave the query unchanged
  ///   - fragment: The new fragment, or `nil` to leave the fragment unchanged
  /// - Returns: A new absolute URI with the specified modifications
  ///
  public func copy(
    scheme: String? = nil,
    authority: URI.Authority? = nil,
    path: [URI.PathItem]? = nil,
    query: [URI.QueryItem]? = nil,
    fragment: String?? = nil
  ) -> Self {
    Self(
      scheme: scheme ?? self.scheme,
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
    query.first { $0.name == name }
  }

  /// The encoded scheme.
  ///
  /// - Returns: The encoded scheme
  ///
  public var encodedScheme: String {
    scheme.lowercased()
  }

  /// The encoded authority.
  ///
  /// - Returns: The encoded authority
  ///
  public var encodedAuthority: String {
    authority.encoded
  }

  /// The encoded path.
  ///
  /// - Returns: The encoded path
  ///
  public var encodedPath: String {
    path.encoded(relative: false)
  }

  /// The encoded query.
  ///
  /// - Returns: The encoded query, or `nil` if the query is empty
  ///
  public var encodedQuery: String? {
    query.nilIfEmpty()?.encoded
  }

  /// The encoded fragment.
  ///
  /// - Returns: The encoded fragment, or `nil` if the fragment is empty
  ///
  public var encodedFragment: String? {
    fragment?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
  }

  /// The encoded absolute URI.
  ///
  /// - Returns: The encoded absolute URI
  ///
  public var encoded: String {
    let query = encodedQuery.map { "?\($0)" } ?? ""
    let fragment = encodedFragment.map { "#\($0)" } ?? ""
    return "\(scheme)://\(encodedAuthority)\(encodedPath)\(query)\(fragment)"
  }

  /// Converts this URI to a `Foundation.URL` representation of this absolute URI.
  ///
  /// - Returns: A new `Foundation.URL` instance
  ///
  public var url: URL {
    var components = URLComponents()
    components.scheme = scheme
    components.encodedHost = authority.encodedHost
    components.port = authority.port
    components.percentEncodedUser = authority.userInfo?.encodedUser
    components.percentEncodedPassword = authority.userInfo?.encodedPassword
    components.percentEncodedPath = encodedPath
    components.percentEncodedQuery = encodedQuery
    components.percentEncodedFragment = encodedFragment
    return components.url.neverNil()
  }

  /// The fragment component as a `Pointer`.
  ///
  /// If the URI has a fragment and it is a valid ``Pointer``, this property returns the
  /// pointer. Otherwise, it returns `nil`.
  ///
  public var fragmentPointer: Pointer? {
    guard let fragment = fragment else {
      return nil
    }
    return Pointer(encoded: fragment)
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
      case .scheme(let scheme):
        copy = self.copy(scheme: scheme)
      case .host(let host):
        copy = self.copy(authority: copy.authority.copy(host: host))
      case .port(let port):
        copy = self.copy(authority: copy.authority.copy(port: port))
      case .user(let user):
        copy = self.copy(authority: copy.authority.copy(userInfo: copy.authority.userInfo?.copy(user: user)))
      case .password(let password):
        copy = self.copy(authority: copy.authority.copy(userInfo: copy.authority.userInfo?.copy(password: password)))
      case .path(let path):
        copy = self.copy(path: path)
      case .query(let query):
        copy = self.copy(query: query)
      case .fragment(let fragment):
        copy = self.copy(fragment: fragment)
      }
    }
    return .absolute(copy)
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
    return updating(components)
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
    guard let fragment else {
      return updating(fragmentPointer: pointer)
    }
    guard let fragmentPointer = Pointer(encoded: fragment) else {
      return nil
    }
    return .absolute(copy(fragment: (fragmentPointer / pointer).encoded))
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
    var result = self
    for part in components {
      switch part {
      case .user:
        result = result.copy(authority: authority.copy(userInfo: .some(authority.userInfo?.copy(user: .some(nil)))))
      case .password:
        result = result.copy(authority: authority.copy(userInfo: .some(authority.userInfo?.copy(password: .some(nil)))))
      case .port:
        result = result.copy(authority: authority.copy(port: .some(nil)))
      case .path:
        result = result.copy(path: [])
      case .query:
        result = result.copy(query: [])
      case .fragment:
        result = result.copy(fragment: .some(nil))
      default:
        break
      }
    }
    return .absolute(result)
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

  /// Converts this URI to be relative to the specified URI.
  ///
  /// This method computes the relative URI from this URI to the specified
  /// URI and returns the computed relative URI.
  ///
  /// - Parameter other: The URI to which this URI should be made relative
  /// - Returns: A new URI that is relative to the specified URI
  ///
  public func relative(to other: URI.Absolute) -> URI {

    let selfPath = path
    let otherPath = other.path

    guard
      scheme == other.scheme,
      authority == other.authority,
      selfPath.count >= otherPath.count
    else {
      return .absolute(self)
    }

    var commonPrefixCount = 0
    while commonPrefixCount < min(selfPath.count, otherPath.count),
      selfPath[commonPrefixCount] == otherPath[commonPrefixCount]
    {
      commonPrefixCount += 1
    }

    let relPath = Array([.current] + selfPath.dropFirst(commonPrefixCount))
    let query = self.query.nilIfEmpty() ?? other.query
    let fragment = self.fragment ?? other.fragment

    return .relative(path: relPath, query: query, fragment: fragment)
  }

}
