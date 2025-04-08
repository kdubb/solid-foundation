//
//  URI.swift
//  Codex
//
//  Created by Kevin Wooten on 2/8/25.
//

import Foundation

/// A Uniform Resource Identifier (URI) that can be either absolute or a relative reference.
///
/// URIs are used to identify resources on the internet and follow the syntax defined in RFC 3986.
/// This implementation supports both absolute URIs and relative references, with comprehensive
/// support for URI manipulation and normalization.
public enum URI {

  /// An absolute URI.
  case absolute(Absolute)

  /// A relative reference.
  case relativeReference(RelativeReference)

  /// Creates a new URI from an encoded string, optionally applying validation requirements.
  ///
  /// This initializer parses the string and checks if it satisfies the specified requirements. If the string
  /// is invalid or does not meet the requirements, it returns nil.
  ///
  /// - Parameters:
  ///   - string: The encoded URI string to parse
  ///   - requirements: A set of requirements that the URI must satisfy
  ///
  public init?(encoded string: String, requirements: Set<Requirement> = []) {
    guard let components = URLComponents(string: string) else {
      return nil
    }
    let uri = components.lexicalUri
    if !requirements.allSatisfy({ $0.isSatisfied(by: uri) }) {
      return nil
    }
    // Normalize in case there is no normaliation requirement
    self = uri.normalized()
  }

  /// Creates a new URI from an encoded string, optionally applying validation requirements.
  ///
  /// - Parameters:
  ///   - string: The encoded URI string to parse
  ///   - requirements: A variadic list of requirements that the URI must satisfy
  ///
  public init?(encoded string: String, requirements: Requirement...) {
    self.init(encoded: string, requirements: Set(requirements))
  }

  /// Creates a new URI from a string that is known to be valid.
  ///
  /// - Parameter valid: A string that is known to be a valid URI
  /// - Warning: This initializer will crash if the string is not a valid URI
  public init(valid: String) {
    guard let uri = URI(encoded: valid) else {
      fatalError("Invalid URI: \(valid)")
    }
    self = uri
  }

  /// Creates a new URI from a string that is known to be valid.
  ///
  /// - Parameter valid: A string that is known to be a valid URI
  /// - Returns: A new URI
  /// - Warning: This function will crash if the string is not a valid URI
  public static func valid(_ valid: String) -> URI {
    return URI(valid: valid)
  }

  /// Creates a new URI from a URL.
  ///
  /// - Parameter url: The URL to convert to a URI
  public init?(url: URL) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
      return nil
    }
    self = components.uri
  }

  /// The encoded string representation of the URI.
  ///
  /// This property returns the URI in its encoded form, ready for use in HTTP requests
  /// or other contexts where a string representation is needed.
  public var encoded: String {
    switch self {
    case .absolute(let absolute): absolute.encoded
    case .relativeReference(let relative): relative.encoded
    }
  }

  /// Indicates whether the URI is absolute (has a scheme).
  ///
  /// An absolute URI begins with a scheme followed by a colon.
  public var isAbsolute: Bool {
    switch self {
    case .absolute: true
    case .relativeReference: false
    }
  }

  /// Indicates whether the URI is a relative reference.
  ///
  /// A relative reference does not begin with a scheme and colon.
  public var isRelativeReference: Bool {
    guard case .relativeReference = self else {
      return false
    }
    return true
  }

  /// Indicates whether the URI is in its normalized form.
  ///
  /// A normalized URI has:
  /// - Lowercase scheme
  /// - Lowercase host
  /// - Percent-encoded components
  /// - No empty path segments
  /// - No trailing slash unless it's the root path
  public var isNormalized: Bool {
    switch self {
    case .absolute(let absolute): absolute.isNormalized
    case .relativeReference(let relative): relative.isNormalized
    }
  }

  /// Returns a normalized version of this URI.
  ///
  /// Normalization includes:
  /// - Converting scheme to lowercase
  /// - Converting host to lowercase
  /// - Percent-encoding components
  /// - Removing empty path segments
  /// - Removing trailing slash unless it's the root path
  /// - Sorting query parameters
  public func normalized() -> URI {
    switch self {
    case .absolute(let absolute): .absolute(absolute.normalized())
    case .relativeReference(let relative): .relativeReference(relative.normalized())
    }
  }

  /// The scheme component of the URI, if present.
  ///
  /// The scheme identifies the protocol used to access the resource.
  /// For example: "http", "https", "ftp", etc.
  ///
  public var scheme: String? {
    switch self {
    case .absolute(let absolute): absolute.scheme
    case .relativeReference: nil
    }
  }

  /// The query items of the URI.
  ///
  /// Query items are name-value pairs that appear after the question mark in the URI.
  ///
  public var query: [QueryItem] {
    switch self {
    case .absolute(let absolute): absolute.query
    case .relativeReference(let relative): relative.query
    }
  }

  /// Retrieves a specific query item by name, if present.
  ///
  /// - Parameter named: The name of the query item to retrieve
  /// - Returns: The query item if found, nil otherwise
  ///
  public func query(named: String) -> QueryItem? {
    switch self {
    case .absolute(let absolute): absolute.query(named: named)
    case .relativeReference(let relative): relative.query(named: named)
    }
  }

  /// The fragment component of the URI, if present.
  ///
  /// The fragment appears after the hash (#) and typically identifies a specific part of the resource.
  public var fragment: String? {
    switch self {
    case .absolute(let absolute): absolute.fragment
    case .relativeReference(let relative): relative.fragment
    }
  }

  /// Converts the URI to a Foundation URL.
  ///
  /// - Returns: A URL representation of this URI
  public var url: URL {
    switch self {
    case .absolute(let absolute): absolute.url
    case .relativeReference(let relative): relative.url
    }
  }

  /// Updates the specified components of this URI.
  ///
  /// Creates a new URI with the specified components updated, leaving the
  /// other components unchanged.
  ///
  /// - Parameter components: The components to update
  /// - Returns: A new URI with the specified components updated
  ///
  public func updating(_ components: some Sequence<Component>) -> URI {
    switch self {
    case .absolute(let absolute): absolute.updating(Set(components))
    case .relativeReference(let relative): relative.updating(Set(components))
    }
  }

  /// Updates the specified components of this URI.
  ///
  /// Creates a new URI with the specified components updated, leaving the
  /// other components unchanged.
  ///
  /// - Parameter components: The components to update
  /// - Returns: A new URI with the specified components updated
  ///
  public func updating(_ components: Component...) -> URI {
    updating(Set(components))
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
    switch self {
    case .absolute(let absolute): absolute.appending(fragmentPointer: pointer)
    case .relativeReference(let relative): relative.appending(fragmentPointer: pointer)
    }
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
  public func removing(_ components: some Sequence<Component.Kind>) -> URI {
    switch self {
    case .absolute(let absolute): absolute.removing(components)
    case .relativeReference(let relative): relative.removing(components)
    }
  }

  /// Removes the specified parts from this absolute URI.
  ///
  /// Creates a new URI with the specified parts removed, leaving the
  /// other components unchanged.
  ///
  /// - Parameter components: The parts to remove
  /// - Returns: A new absolute URI with the specified parts removed
  ///
  public func removing(_ components: Component.Kind...) -> URI {
    removing(Set(components))
  }

  /// Resolves this URI against a base URI.
  ///
  /// - Parameter base: The base URI to resolve against
  /// - Returns: A new absolute URI
  public func resolved(against base: URI) -> URI {
    switch (self, base) {
    case (.absolute, .absolute): self
    case (.relativeReference(let rel), .absolute(let abs)): rel.resolved(against: abs)
    default: self
    }
  }

  /// Resolves this URI against a base URI string.
  ///
  /// - Parameter base: The base URI string to resolve against
  /// - Returns: A new absolute URI, or nil if the base string is invalid
  ///
  public func resolved(against base: String) -> URI? {
    guard let baseURI = URI(encoded: base) else {
      return nil
    }
    return resolved(against: baseURI)
  }

  /// Creates a relative URI from this absolute URI.
  ///
  /// This method computes the relative URI from this URI to the specified
  /// URI and returns the computed relative URI.
  ///
  /// - Parameter absolute: The absolute URI to make relative to
  /// - Returns: A new relative URI
  ///
  public func relative(to absolute: URI) -> URI {
    switch (self, absolute) {
    case (.absolute(let specific), .absolute(let base)): specific.relative(to: base)
    default: self
    }
  }

  /// Creates a relative URI from this absolute URI.
  ///
  /// This method computes the relative URI from this URI to the specified
  /// URI and returns the computed relative URI.
  ///
  /// - Parameter absolute: The absolute URI string to make relative to
  /// - Returns: A new relative URI, or nil if the absolute string is invalid
  ///
  public func relative(to absolute: String) -> URI? {
    guard let absoluteURI = URI(encoded: absolute) else {
      return nil
    }
    return relative(to: absoluteURI)
  }

  /// The transform to use when creating relative paths from absolute URIs.
  ///
  public enum RelativePathTransform {

    /// Return the path unaltered if it is already relative,
    /// or convert it to a path relative to the root directory.
    case relative

    /// Return the path unaltered if it is already absolute,
    /// or convert it to an absolute path relative to the root directory.
    case absolute

    /// If relative, return the path relative to the current directory,
    /// or convert the entire absolute path to a relative path from the
    /// current directory.
    case directory
  }

  /// Creates a relative URI from this URI, possible transforming it.
  ///
  /// If this URI is absolute, it will be converted to a relative URI using the specified
  /// path transoformation style. If this URI is already relative, it will be returned as-is.
  ///
  /// - SeeAlso: ``RelativePathTransform``
  /// - Parameter pathTransform: The transform to use when creating a relative path from absolute URIs.
  /// - Returns: A new URI with a relative path
  ///
  public func relative(pathTransform: RelativePathTransform = .directory) -> URI {
    switch self {
    case .relativeReference:
      return self
    case .absolute(let absolute):
      let path =
        switch pathTransform {
        case .absolute: absolute.path.absolute
        case .relative: absolute.path.relative
        case .directory: absolute.path.directoryRelative
        }
      return .relative(
        path: path,
        query: absolute.query,
        fragment: absolute.fragment
      )
    }
  }

}

extension URI: Sendable {}
extension URI: Hashable {}
extension URI: Equatable {}

extension URI {

  /// Creates an absolute URI.
  ///
  /// - Parameters:
  ///   - scheme: The scheme of the URI
  ///   - authority: The authority of the URI
  ///   - path: The path of the URI
  ///   - query: The query of the URI
  ///   - fragment: The fragment of the URI
  /// - Returns: An absolute URI with the specified components
  public static func absolute(
    scheme: String,
    authority: URI.Authority,
    path: [URI.PathItem] = [],
    query: [URI.QueryItem] = [],
    fragment: String? = nil
  ) -> Self {
    .absolute(.init(scheme: scheme, authority: authority, path: path, query: query, fragment: fragment))
  }

  /// Creates a relative reference.
  ///
  /// - Parameters:
  ///  - authority: The authority of the URI
  ///  - path: The path of the URI
  ///  - query: The query of the URI
  ///  - fragment: The fragment of the URI
  /// - Returns: A relative reference with the specified components
  public static func relative(
    authority: URI.Authority? = nil,
    path: [URI.PathItem] = [],
    query: [URI.QueryItem] = [],
    fragment: String? = nil
  ) -> Self {
    .relativeReference(.init(authority: authority, path: path, query: query, fragment: fragment))
  }

  /// Creates a relative reference from an encoded path.
  ///
  /// - Parameters:
  ///  - authority: The authority of the URI
  ///  - encodedPath: The encoded path of the URI
  ///  - query: The query of the URI
  ///  - fragment: The fragment of the URI
  public static func relative(
    authority: URI.Authority? = nil,
    encodedPath: String,
    query: [URI.QueryItem] = [],
    fragment: String? = nil
  ) -> Self {
    .relativeReference(
      .init(
        authority: authority,
        path: .from(encoded: encodedPath, absolute: false),
        query: query,
        fragment: fragment
      )
    )
  }

}

extension URI: CustomStringConvertible, CustomDebugStringConvertible {

  /// A textual representation of the URI.
  public var description: String { encoded }

  /// A textual representation of the URI, suitable for debugging.
  public var debugDescription: String { encoded }

}
