//
//  URI.swift
//  Codex
//
//  Created by Kevin Wooten on 2/8/25.
//

import Foundation

public enum URI {

  case absolute(Absolute)
  case relativeReference(RelativeReference)

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

  public init?(encoded string: String, requirements: Requirement...) {
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
    case .relativeReference(let relative): relative.encoded
    }
  }

  public var isAbsolute: Bool {
    switch self {
    case .absolute: true
    case .relativeReference: false
    }
  }

  public var isRelativeReference: Bool {
    guard case .relativeReference = self else {
      return false
    }
    return true
  }

  public var isNormalized: Bool {
    switch self {
    case .absolute(let absolute): absolute.isNormalized
    case .relativeReference(let relative): relative.isNormalized
    }
  }

  public func normalized() -> URI {
    switch self {
    case .absolute(let absolute): .absolute(absolute.normalized())
    case .relativeReference(let relative): .relativeReference(relative.normalized())
    }
  }

  public var scheme: String? {
    switch self {
    case .absolute(let absolute): absolute.scheme
    case .relativeReference: nil
    }
  }

  public var query: [QueryItem] {
    switch self {
    case .absolute(let absolute): absolute.query
    case .relativeReference(let relative): relative.query
    }
  }

  public var fragment: String? {
    switch self {
    case .absolute(let absolute): absolute.fragment
    case .relativeReference(let relative): relative.fragment
    }
  }

  public var url: URL {
    switch self {
    case .absolute(let absolute): absolute.url
    case .relativeReference(let relative): relative.url
    }
  }

  public func replacing(fragment: String) -> URI {
    switch self {
    case .absolute(let absolute): absolute.replacing(fragment: fragment)
    case .relativeReference(let relative): relative.replacing(fragment: fragment)
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
    case .relativeReference(let relative): relative.appending(fragmentPointer: pointer)
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
    case .relativeReference(let relative): relative.updating(Set(components))
    }
  }

  public func removing(_ components: Component.Kind...) -> URI {
    removing(Set(components))
  }

  public func removing(_ components: some Sequence<Component.Kind>) -> URI {
    switch self {
    case .absolute(let absolute): absolute.removing(parts: components)
    case .relativeReference(let relative): relative.removing(parts: components)
    }
  }

  public enum RelativePathStyle {
    case relative
    case absolute
    case directory
  }

  public func relative(pathStyle: RelativePathStyle = .directory) -> URI {
    switch self {
    case .relativeReference:
      return self
    case .absolute(let absolute):
      let path =
        switch pathStyle {
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

  public func resolved(against base: URI) -> URI {
    switch (self, base) {
    case (.absolute, .absolute): self
    case (.relativeReference(let rel), .absolute(let abs)): rel.resolved(against: abs)
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
    authority: URI.Authority,
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
    .relativeReference(.init(path: path, query: query, fragment: fragment))
  }

  public static func relative(
    encodedPath: String,
    query: [URI.QueryItem] = [],
    fragment: String? = nil
  ) -> Self {
    .relativeReference(.init(path: .from(encoded: encodedPath, absolute: false), query: query, fragment: fragment))
  }

}

extension URI: CustomStringConvertible, CustomDebugStringConvertible {

  public var description: String { encoded }
  public var debugDescription: String { encoded }

}
