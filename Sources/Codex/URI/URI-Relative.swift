//
//  URI-Relative.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

import Foundation

extension URI {

  public struct Relative {

    public var path: [PathItem]
    public var query: [QueryItem]
    public var fragment: String?

    public init(path: [PathItem], query: [QueryItem], fragment: String?, normalized: Bool = true) {
      self.path = normalized ? path.normalized : path
      self.query = query
      self.fragment = fragment
    }

    public var isNormalized: Bool {
      path.isNormalized
    }

    public func normalized() -> Self {
      Self(
        path: path,
        query: query,
        fragment: fragment,
        normalized: true
      )
    }
  }

}

extension URI.Relative: Sendable {}
extension URI.Relative: Hashable {}
extension URI.Relative: Equatable {}

extension URI.Relative {

  public func copy(
    path: [URI.PathItem]? = nil,
    query: [URI.QueryItem]? = nil,
    fragment: String?? = nil
  ) -> Self {
    Self(
      path: path ?? self.path,
      query: query ?? self.query,
      fragment: fragment ?? self.fragment
    )
  }

  public var isAbsolutePath: Bool {
    path.first == .root
  }

  public var encodedPath: String? {
    path.encoded(relative: true)
  }

  public var encodedQuery: String? {
    query.nilIfEmpty()?.encoded
  }

  public var encodedFragment: String? {
    fragment?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
  }

  public var encoded: String {
    let path = encodedPath ?? ""
    let query = encodedQuery.map { "?\($0)" } ?? ""
    let fragment = encodedFragment.map { "#\($0)" } ?? ""
    return "\(path)\(query)\(fragment)"
  }

  public var url: URL {
    var components = URLComponents()
    components.percentEncodedPath = encodedPath ?? ""
    components.percentEncodedQuery = encodedQuery
    components.percentEncodedFragment = fragment
    return components.url.neverNil()
  }

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
    return .relative(copy)
  }

  public func removing(parts: some Sequence<URI.Component.Kind>) -> URI {
    var copy = self
    for part in parts {
      switch part {
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
    return .relative(copy)
  }

  public func replacing(fragment: String) -> URI {
    .relative(copy(fragment: fragment))
  }

  public func appending(fragmentPointer pointer: Pointer) -> URI? {
    guard let baseFragmentPointer = self.fragment.map(Pointer.init(encoded:)) ?? nil else {
      return nil
    }
    let fragmentPointer = baseFragmentPointer / pointer
    return .relative(copy(fragment: fragmentPointer.encoded))
  }

  public func resolved(against base: URI.Absolute) -> URI {
    let selfPath = path
    let basePath = base.path

    var absPath: [URI.PathItem]

    if selfPath.isEmpty {
      absPath = basePath
    } else if basePath.isEmpty || (selfPath.count > 1 && selfPath.first == .root) {
      absPath = selfPath.first != .root ? selfPath : [.root] + selfPath
    } else {
      var resPath: [URI.PathItem] = selfPath.first == .current ? basePath : basePath.dropLast()
      for component in selfPath {
        switch component {
        case .current:
          if resPath.last == .root {
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

    let query = self.query.nilIfEmpty() ?? base.query
    let fragment = self.fragment ?? base.fragment

    return .absolute(
      base.copy(
        path: absPath,
        query: query,
        fragment: fragment
      )
    )
  }

  public func resolved(against base: URI.Name) -> URI {
    let query = self.query.nilIfEmpty() ?? base.query
    let fragment = self.fragment ?? base.fragment
    return .name(base.copy(query: query, fragment: fragment))
  }

}
