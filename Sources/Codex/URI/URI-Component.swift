//
//  URI-Component.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

extension URI {

  public enum Component {

    public enum Kind {
      case scheme
      case host
      case port
      case user
      case password
      case path
      case query
      case queryItem(name: String)
      case fragment

      public static let authority: Set<Self> = [.host, .port, .user, .password]
      public static let userInfo: Set<Self> = [.user, .password]
      public static let subresource: Set<Self> = [.query, .fragment]
      public static func queryItems(_ names: String...) -> Set<Self> { Set(names.map { .queryItem(name: $0) }) }

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

    case scheme(String)
    case host(String)
    case port(Int)
    case user(String)
    case password(String)
    case path([PathItem])
    case query([QueryItem])
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

  public static let all: Set<Element> = [
    .scheme,
    .host,
    .port,
    .user,
    .password,
    .path,
    .query,
    .fragment
  ]

}
