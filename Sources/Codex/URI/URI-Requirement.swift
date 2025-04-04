//
//  URI-Requirement.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

extension URI {

  public enum Requirement {

    public enum Kind {
      case uri
      case uriReference
      case relativeReference

      public func isSatisfied(by uri: URI) -> Bool {
        switch self {
        case .uriReference:
          return uri.isAbsolute || uri.isRelativeReference
        case .uri:
          return uri.isAbsolute
        case .relativeReference:
          return uri.isRelativeReference
        }
      }
    }

    public enum Fragment {
      case required
      case disallowed(ignoreEmpty: Bool)
      case optional

      public static let disallowed: Self = .disallowed(ignoreEmpty: false)
      public static let disallowedOrEmpty: Self = .disallowed(ignoreEmpty: true)
    }

    case kinds(Set<Kind>)
    case fragment(Fragment)
    case normalized

    public static func kind(_ kind: Kind) -> Self {
      .kinds([kind])
    }

    public static func kinds(_ kinds: Kind...) -> Self {
      .kinds(Set(kinds))
    }

    public func isSatisfied(by uri: URI) -> Bool {
      switch self {
      case .kinds(let kinds):
        return kinds.anySatisfy { $0.isSatisfied(by: uri) }
      case .normalized:
        return uri.isNormalized
      case .fragment(let fragment):
        switch fragment {
        case .required:
          return uri.fragment != nil
        case .disallowed(let emptyAllowed):
          return uri.fragment == nil || (emptyAllowed && (uri.fragment ?? "").isEmpty)
        case .optional:
          return true
        }
      }
    }
  }

}

extension URI.Requirement: Sendable {}
extension URI.Requirement: Hashable {}
extension URI.Requirement: Equatable {}

extension URI.Requirement.Kind: Sendable {}
extension URI.Requirement.Kind: Hashable {}
extension URI.Requirement.Kind: Equatable {}

extension URI.Requirement.Fragment: Sendable {}
extension URI.Requirement.Fragment: Hashable {}
extension URI.Requirement.Fragment: Equatable {}
