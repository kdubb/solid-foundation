//
//  URI.swift
//  Codex
//
//  Created by Kevin Wooten on 2/8/25.
//

import Foundation

public enum URI {

  case absolute(Absolute)
  case relative(Relative)
  case name(Name)

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

  public init? (encoded string: String, requirements: Requirement...) {
    self.init(encoded: string, requirements: Set(requirements))
  }

  public init(valid: String) {
    guard let uri = URI(encoded: valid) else {
      fatalError("Invalid URI: \(valid)")
    }
    self = uri
  }

  public static func valid(_ valid: String) -> URI {
    return URI(valid: valid)
  }

  public init?(url: URL) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
      return nil
    }
    self = components.uri
  }

  public var encoded: String {
    switch self {
    case .absolute(let absolute): absolute.encoded
    case .relative(let relative): relative.encoded
    case .name(let name): name.encoded
    }
  }

  public var isAbsolute: Bool {
    switch self {
    case .absolute: true
    case .relative: false
    case .name: true
    }
  }

  public var isRelative: Bool {
    guard case .relative = self else {
      return false
    }
    return true
  }

  public var isName: Bool {
    guard case .name = self else {
      return false
    }
    return true
  }

  public var isNormalized: Bool {
    switch self {
    case .absolute(let absolute): absolute.isNormalized
    case .relative(let relative): relative.isNormalized
    case .name: true
    }
  }

  public func normalized() -> URI {
    switch self {
    case .absolute(let absolute): .absolute(absolute.normalized())
    case .relative(let relative): .relative(relative.normalized())
    case .name: self
    }
  }

  public var scheme: String? {
    switch self {
    case .absolute(let absolute): absolute.scheme
    case .relative: nil
    case .name(let name): name.scheme
    }
  }

  public var query: [QueryItem] {
    switch self {
    case .absolute(let absolute): absolute.query
    case .relative(let relative): relative.query
    case .name(let name): name.query
    }
  }

  public var fragment: String? {
    switch self {
    case .absolute(let absolute): absolute.fragment
    case .relative(let relative): relative.fragment
    case .name(let name): name.fragment
    }
  }

  public var url: URL {
    switch self {
    case .absolute(let absolute): absolute.url
    case .relative(let relative): relative.url
    case .name(let name): name.url
    }
  }

  public func replacing(fragment: String) -> URI {
    switch self {
    case .absolute(let absolute): absolute.replacing(fragment: fragment)
    case .relative(let relative): relative.replacing(fragment: fragment)
    case .name(let name): name.replacing(fragment: fragment)
    }
  }

  public func replacing(fragmentPointer pointer: Pointer) -> URI {
    replacing(fragment: pointer.encoded)
  }

  public func replacing(fragmentPointer tokens: Pointer.ReferenceToken) -> URI {
    replacing(fragmentPointer: Pointer(tokens: tokens))
  }

  public func appending(fragmentPointer pointer: Pointer) -> URI? {
    switch self {
    case .absolute(let absolute): absolute.appending(fragmentPointer: pointer)
    case .relative(let relative): relative.appending(fragmentPointer: pointer)
    case .name(let name): name.appending(fragmentPointer: pointer)
    }
  }

  public func appending(fragmentPointer tokens: Pointer.ReferenceToken...) -> URI? {
    appending(fragmentPointer: Pointer(tokens: tokens))
  }

  public func updating(_ components: Component.Kind...) -> URI {
    removing(Set(components))
  }

  public func updating(_ components: Set<Component>) -> URI {
    switch self {
    case .absolute(let absolute): absolute.updating(Set(components))
    case .relative(let relative): relative.updating(Set(components))
    case .name(let name): name.updating(components)
    }
  }

  public func removing(_ components: Component.Kind...) -> URI {
    removing(Set(components))
  }

  public func removing(_ components: some Sequence<Component.Kind>) -> URI {
    switch self {
    case .absolute(let absolute): absolute.removing(parts: components)
    case .relative(let relative): relative.removing(parts: components)
    case .name(let name): name.removing(parts: components)
    }
  }

  public enum RelativePathStyle {
    case relative
    case absolute
    case directory
  }

  public func relative(pathStyle: RelativePathStyle = .directory) -> URI {
    switch self {
    case .relative:
      return self
    case .absolute(let absolute):
      let path = switch pathStyle {
      case .absolute: absolute.path.absolute
      case .relative: absolute.path.relative
      case .directory: absolute.path.directoryRelative
      }
      return .relative(
        path: path,
        query: absolute.query,
        fragment: absolute.fragment
      )
    case .name(let name):
      return .relative(path: [], query: name.query, fragment: name.fragment)
    }
  }

  public func resolved(against base: URI) -> URI {
    switch (self, base) {
    case (.absolute, .absolute): self
    case (.relative(let rel), .absolute(let abs)): rel.resolved(against: abs)
    case (.relative(let rel), .name(let name)): rel.resolved(against: name)
    default: self
    }
  }

  public func resolved(against base: String) -> URI? {
    guard let baseURI = URI(encoded: base) else {
      return nil
    }
    return resolved(against: baseURI)
  }

  public func relative(to absolute: URI) -> URI {
    switch (self, absolute) {
    case (.absolute(let specific), .absolute(let base)): specific.relative(to: base)
    case (.name(let a), .name(let b)): a.relative(to: b)
    default: self
    }
  }

  public func relative(to absolute: String) -> URI? {
    guard let absoluteURI = URI(encoded: absolute) else {
      return nil
    }
    return relative(to: absoluteURI)
  }

}

extension URI: Sendable {}
extension URI: Hashable {}
extension URI: Equatable {}

extension URI {

  public static func absolute(
    scheme: String,
    authority: URI.Absolute.Authority,
    path: [URI.PathItem] = [],
    query: [URI.QueryItem] = [],
    fragment: String? = nil
  ) -> Self {
    .absolute(.init(scheme: scheme, authority: authority, path: path, query: query, fragment: fragment))
  }

  public static func relative(
    path: [URI.PathItem] = [],
    query: [URI.QueryItem] = [],
    fragment: String? = nil
  ) -> Self {
    .relative(.init(path: path, query: query, fragment: fragment))
  }

  public static func relative(
    encodedPath: String,
    query: [URI.QueryItem] = [],
    fragment: String? = nil
  ) -> Self {
    .relative(.init(path: .from(encoded: encodedPath, absolute: false), query: query, fragment: fragment))
  }

  public static func name(
    scheme: String,
    path: String,
    query: [URI.QueryItem] = [],
    fragment: String? = nil
  ) -> Self {
    .name(.init(scheme: scheme, path: path, query: query, fragment: fragment))
  }

}

extension URI: CustomStringConvertible, CustomDebugStringConvertible {

  public var description: String { encoded }
  public var debugDescription: String { encoded }

}
