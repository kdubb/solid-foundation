//
//  URI-Component.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

extension URI {

  /// A component of a URI.
  ///
  /// Components represent the individual parts that make up a URI,
  /// such as scheme, host, path, etc. They can be used to update
  /// URIs by replacing or removing specific components.
  ///
  /// Replacing a component can be done by using the ``URI/replacing(component:with:)``:
  /// ```swift
  /// let uri = URI("https://example.com/path/to/resource?query=value#fragment")
  ///
  /// let updated = uri.replacing(component: .path(["new", "path", "to", "resource"]))
  /// print(updated) // "https://example.com/new/path/to/resource?query=value#fragment"
  ///
  /// let updated = uri.replacing(component: .queryItem(name: "query", value: "newValue"))
  /// print(updated) // "https://example.com/path/to/resource?query=newValue#fragment"
  /// ```
  ///
  /// Removing a component can be done by using the ``URI/removing(component:)``:
  /// ```swift
  /// let uri = URI("https://example.com/path/to/resource?query=value#fragment")
  /// let updated = uri.removing(component: .path)
  /// print(updated) // "https://example.com/path/to/resource?query=value#fragment"
  /// ```
  ///
  public enum Component {

    /// The kind of component in a URI.
    public enum Kind {
      /// The scheme component (e.g., "http", "https").
      case scheme
      /// The host component (e.g., "example.com").
      case host
      /// The port component (e.g., 80, 443).
      case port
      /// The username component.
      case user
      /// The password component.
      case password
      /// The path component.
      case path
      /// The entire query component.
      case query
      /// A specific query item, by name, in the query component.
      case queryItem(name: String)
      /// The fragment component.
      case fragment

      /// The set of components that make up the authority.
      public static let authority: Set<Self> = [.host, .port, .user, .password]
      /// The set of components that make up the user information.
      public static let userInfo: Set<Self> = [.user, .password]
      /// The set of components that make up the subresource.
      public static let subresource: Set<Self> = [.query, .fragment]
      /// Creates a set of query item components for the given names.
      ///
      /// - Parameter names: The names of the query items
      /// - Returns: A set of query item components
      public static func queryItems(_ names: String...) -> Set<Self> { Set(names.map { .queryItem(name: $0) }) }

      /// All possible component kinds.
      public static let all = Set<Self>([
        .scheme,
        .host,
        .port,
        .user,
        .password,
        .path,
        .query,
        .fragment,
      ])
    }

    /// The scheme component with its value.
    case scheme(String)
    /// The host component with its value.
    case host(String)
    /// The port component with its value.
    case port(Int)
    /// The username component with its value.
    case user(String)
    /// The password component with its value.
    case password(String)
    /// The path component with its segments.
    case path([PathItem])
    /// The query component with its items.
    case query([QueryItem])
    /// The fragment component with its value.
    case fragment(String)
  }

}

extension URI.Component: Sendable {}
extension URI.Component: Hashable {}
extension URI.Component: Equatable {}

extension URI.Component.Kind: Sendable {}
extension URI.Component.Kind: Hashable {}
extension URI.Component.Kind: Equatable {}

extension Set where Element == URI.Component.Kind {

  /// Shorthand accessoor for all component kinds.
  public static let all: Set<Element> = [
    .scheme,
    .host,
    .port,
    .user,
    .password,
    .path,
    .query,
    .fragment,
  ]

}
