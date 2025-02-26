//
//  URI-Name.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

import Foundation

extension URI {

  public struct Name {

    public var scheme: String
    public var path: String
    public var query: [QueryItem]
    public var fragment: String?

    public init(scheme: String, path: String, query: [QueryItem], fragment: String?) {
      self.scheme = scheme
      self.path = path
      self.query = query
      self.fragment = fragment
    }

  }

}

public typealias URN = URI.Name

extension URI.Name: Sendable {}
extension URI.Name: Hashable {}
extension URI.Name: Equatable {}

extension URI.Name {

  public func copy(
    scheme: String? = nil,
    path: String? = nil,
    query: [URI.QueryItem]? = nil,
    fragment: String?? = nil
  ) -> Self {
    Self(
      scheme: scheme ?? self.scheme,
      path: path ?? self.path,
      query: query ?? self.query,
      fragment: fragment ?? self.fragment
    )
  }

  public var encodedPath: String? {
    path.nilIfEmpty()
  }

  public var encodedQuery: String? {
    query.nilIfEmpty()?.encoded
  }

  public var encodedFragment: String? {
    fragment?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
  }

  public var encoded: String {
    let scheme = scheme
    let path = encodedPath ?? ""
    let query = encodedQuery.map { "?\($0)" } ?? ""
    let fragment = encodedFragment.map { "#\($0)" } ?? ""
    return "\(scheme):\(path)\(query)\(fragment)"
  }

  public var url: URL {
    var components = URLComponents()
    components.scheme = scheme
    components.percentEncodedPath = encodedPath ?? ""
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
      case .path(let path):
        copy = self.copy(path: path.map(\.value).joined(separator: "/"))
      case .query(let query):
        copy = self.copy(query: query)
      case .fragment(let fragment):
        copy = self.copy(fragment: fragment)
      default:
        break
      }
    }
    return .name(copy)
  }

  public func removing(parts: some Sequence<URI.Component.Kind>) -> URI {
    var copy = self
    for part in parts {
      switch part {
      case .query:
        copy = self.copy(query: [])
      case .fragment:
        copy = self.copy(fragment: .some(nil))
      default:
        break
      }
    }
    return .name(copy)
  }

  public func replacing(fragment: String) -> URI {
    .name(copy(fragment: fragment))
  }

  public func appending(fragmentPointer pointer: Pointer) -> URI? {
    let pointerFragment: Pointer
    if let fragment {
      guard let baseFragmentPointer = Pointer.init(encoded: fragment) else {
        return nil
      }
      pointerFragment = baseFragmentPointer / pointer
    } else {
      pointerFragment = pointer
    }
    return .name(copy(fragment: pointerFragment.encoded))
  }

  public func relative(to other: URI.Name) -> URI {

    guard
      scheme == other.scheme,
      path.hasPrefix(other.path)
    else {
      return .name(self)
    }

    return .relative(path: [], query: query.nilIfEmpty() ?? other.query, fragment: fragment ?? other.fragment)
  }

}
