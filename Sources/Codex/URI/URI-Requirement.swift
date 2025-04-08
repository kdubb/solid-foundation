//
//  URI-Requirement.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

extension URI {

  /// A requirement that a URI must satisfy.
  ///
  /// Requirements can be used to validate URIs during creation or to ensure
  /// they meet specific criteria for a particular use case.
  public enum Requirement {

    /// The kind of URI that is required.
    public enum Kind {
      /// Requires an absolute URI with a scheme
      case uri
      /// Allows either an absolute URI or a relative reference
      case uriReference
      /// Requires a relative reference without a scheme
      case relativeReference

      /// Checks if a URI satisfies this required kind.
      ///
      /// - Parameter uri: The URI to check
      /// - Returns: true if the URI satisfies the requirement, false otherwise
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

    /// Requirements for the fragment component of a URI.
    public enum Fragment {
      /// The URI must have a non-empty fragment
      case required
      /// The URI must not have a fragment, with an option to consider an empty fragment as valid.
      case disallowed(ignoreEmpty: Bool)
      /// The URI may or may not have a fragment
      case optional

      /// A requirement that disallows any fragment.
      public static let disallowed: Self = .disallowed(ignoreEmpty: false)
      /// A requirement that disallows non-empty fragments.
      public static let disallowedOrEmpty: Self = .disallowed(ignoreEmpty: true)
    }

    /// Requires the URI to be one of a provided kinds
    case kinds(Set<Kind>)
    /// Requires the URI to meet the fragment requirements
    case fragment(Fragment)
    /// Requires the URI to be in normalized form
    case normalized

    /// Creates a requirement for a specific kind of URI.
    ///
    /// - Parameter kind: The kind of URI required
    /// - Returns: A requirement for the specified kind
    public static func kind(_ kind: Kind) -> Self {
      .kinds([kind])
    }

    /// Creates a requirement for a set of kinds of URIs.
    ///
    /// - Parameter kinds: The kinds of URIs required
    /// - Returns: A requirement for the specified kinds
    public static func kinds(_ kinds: Kind...) -> Self {
      .kinds(Set(kinds))
    }

    /// Checks if the given URI satisfies this requirement.
    ///
    /// - Parameter uri: The URI to check
    /// - Returns: true if the given URI satisfies this requirement, false otherwise
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
