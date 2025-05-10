//
//  URI-Requirement.swift
//  SolidFoundation
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
      /// Requires an absolute URI/IRI with a scheme
      case absolute
      /// Requires a relative reference without a scheme
      case relativeReference

      /// Checks if a URI satisfies this required kind.
      ///
      /// - Parameter uri: The URI to check
      /// - Returns: true if the URI satisfies the requirement, false otherwise
      public func isSatisfied(by uri: URI) -> Bool {
        switch self {
        case .absolute:
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

      public func isSatisfied(by fragment: String?) -> Bool {
        switch self {
        case .required:
          return fragment != nil
        case .disallowed(let ignoreEmpty):
          return fragment == nil || (ignoreEmpty && fragment?.isEmpty == true)
        case .optional:
          return true
        }
      }
    }

    /// A requirement that the URI must be a valid URI or IRI according to a specific RFC.
    public enum RFC {
      /// The URI must be a valid URI according to RFC 3986
      case uri
      /// The URI must be a valid IRI according to RFC 3987
      case iri
    }

    /// Requires the URI to be one of a provided kinds
    case kinds(Set<Kind>)
    /// Requires the URI to meet the fragment requirements
    case fragment(Fragment)
    /// Requires the URI to be in normalized form
    case normalized
    /// Requires a specific RFC for URI or IRI
    case rfc(RFC)
    /// Requires the URI to be properly percent encoded
    case percentEncoded

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

    /// A requirement that the URI must be a valid IRI.
    public static var iri: Self {
      .rfc(.iri)
    }

    /// A requirement that the URI must be a valid URI.
    public static var uri: Self {
      .rfc(.uri)
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
      case .rfc(let rfc):
        switch rfc {
        case .uri:
          var parser = Parser(string: uri.encoded, requirements: .uri)
          return parser.parse() != nil
        case .iri:
          var parser = Parser(string: uri.encoded, requirements: .iri)
          return parser.parse() != nil
        }
      case .percentEncoded:
        return uri.isPercentEncoded
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

extension URI.Requirement.RFC: Sendable {}
extension URI.Requirement.RFC: Hashable {}
extension URI.Requirement.RFC: Equatable {}

extension Set where Element == URI.Requirement {

  /// Requires an absolute IRI.
  public static var iri: Self {
    [.rfc(.iri), .kind(.absolute)]
  }

  /// Requires an absolute URI.
  public static var uri: Self {
    [.rfc(.uri), .kind(.absolute)]
  }

  /// Requires an IRI reference.
  ///
  /// IRI references are either absolute or relative.
  public static var iriReference: Self {
    [.rfc(.iri), .kinds(.absolute, .relativeReference)]
  }

  /// Requires a URI reference.
  ///
  /// URI references are either absolute or relative.
  public static var uriReference: Self {
    [.rfc(.uri), .kinds(.absolute, .relativeReference)]
  }

  /// Requires a relative IRI reference.
  public static var iriRelativeReference: Self {
    [.rfc(.iri), .kind(.relativeReference)]
  }

  /// Requires a relative URI reference.
  public static var uriRelativeReference: Self {
    [.rfc(.uri), .kind(.relativeReference)]
  }

}
