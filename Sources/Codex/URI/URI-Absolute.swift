//
//  URI-Absolute.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

import Foundation

extension URI {

  public struct Absolute {

    public var scheme: String
    public var authority: Authority
    public var path: [PathItem]
    public var query: [QueryItem]
    public var fragment: String?

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

    public var isNormalized: Bool {
      path.isNormalized
    }

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

  public var encodedScheme: String {
    scheme.lowercased()
  }

  public var encodedAuthority: String {
    authority.encoded
  }

  public var encodedPath: String {
    path.encoded(relative: false)
  }

  public var encodedQuery: String? {
    query.nilIfEmpty()?.encoded
  }

  public var encodedFragment: String? {
    fragment?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
  }

  public var encoded: String {
    let query = encodedQuery.map { "?\($0)" } ?? ""
    let fragment = encodedFragment.map { "#\($0)" } ?? ""
    return "\(scheme)://\(encodedAuthority)\(encodedPath)\(query)\(fragment)"
  }

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

  public func removing(parts: some Sequence<URI.Component.Kind>) -> URI {
    var result = self
    for part in parts {
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

  public var fragmentPointer: Pointer? {
    guard let fragment = fragment else {
      return nil
    }
    return Pointer(encoded: fragment)
  }

  public func replacing(fragment: String) -> URI {
    .absolute(copy(fragment: fragment))
  }

  public func replacing(fragmentPointer pointer: Pointer) -> URI {
    replacing(fragment: pointer.encoded)
  }

  public func appending(fragmentPointer pointer: Pointer) -> URI? {
    if let fragment {
      guard let fragmentPointer = Pointer(encoded: fragment) else {
        return nil
      }
      return .absolute(copy(fragment: (fragmentPointer / pointer).encoded))
    } else {
      return replacing(fragmentPointer: pointer)
    }
  }

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
          selfPath[commonPrefixCount] == otherPath[commonPrefixCount] {
      commonPrefixCount += 1
    }

    let relPath = Array([.current] + selfPath.dropFirst(commonPrefixCount))
    let query = self.query.nilIfEmpty() ?? other.query
    let fragment = self.fragment ?? other.fragment

    return .relative(path: relPath, query: query, fragment: fragment)
  }

}
