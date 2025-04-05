//
//  RFC6531.swift
//  Codex
//
//  Created by Kevin Wooten on 4/4/25.
//
import Foundation

public enum RFC6531 {

  /// A structure representing an Internationalized (IDN) email address.
  public struct Mailbox {
    /// The local-part (before the "@").
    public let local: String
    /// The domain (after the "@"). Domain literals retain their enclosing brackets.
    public let domain: String

    public init(local: String, domain: String) {
      self.local = local
      self.domain = domain
    }

    /// Parses an IDN‑email address according to the mailbox production in RFC 6531.
    ///
    /// The local‑part is matched as either:
    ///  - A dot‑string composed of one or more allowed characters (Unicode letters/digits and
    ///    the symbols !#$%&'*+/=?^_`{|}~ and hyphen) separated by literal periods.
    ///  - A quoted‑string enclosed in double quotes that permits escaped printable characters.
    ///
    /// The domain is matched as either:
    ///  - A dot‑string domain of labels (each label starts and ends with a Unicode letter or digit,
    ///    with interior hyphens allowed), or
    ///  - A domain literal enclosed in square brackets.
    ///
    /// - Parameter string: The email address string.
    /// - Returns: An `Mailbox` instance if the input is valid; otherwise, `nil`.
    public static func parse(string: String) -> Mailbox? {

      // The following regex uses named capture groups "local" and "domain".
      let regex =
        #/^(?<local>(?:[\p{L}\p{N}!#$%&'*+/=?^_`{|}~\-]+(?:\.[\p{L}\p{N}!#$%&'*+/=?^_`{|}~\-]+)*|"(?:[^"\\\r\n]|\\.)*"))@(?<domain>(?:[\p{L}\p{N}\-\.]+|\[.+\]))$/#

      guard let match = string.wholeMatch(of: regex) else {
        return nil
      }

      let local = String(match.output.local)
      let domain = String(match.output.domain)

      // Additional validation
      guard validate(local: local) && validate(domain: domain) else {
        return nil
      }

      return Mailbox(local: local, domain: domain)
    }

    public static func validate(local: String) -> Bool {

      // Check max length of local part
      guard local.count <= 64 else {
        return false
      }

      // Validate quoted strings
      if isQuotedString(local) {
        guard validate(quotedString: local) else {
          return false
        }
      }

      return true
    }

    public static func isQuotedString(_ string: String) -> Bool {
      string.hasPrefix("\"") && string.hasSuffix("\"")
    }

    public static func validate(quotedString: String) -> Bool {

      let content = quotedString.dropFirst().dropLast()

      // Check for valid escape sequences
      var i = content.startIndex
      while i < content.endIndex {
        if content[i] == "\\" {
          // Must have a character after the backslash
          let nextIndex = content.index(after: i)
          guard nextIndex < content.endIndex else {
            return false
          }

          // Only " and \ can be escaped
          let nextChar = content[nextIndex]
          guard ["\"", "\\"].contains(nextChar) else {
            return false
          }

          // Skip the escaped character
          i = nextIndex
        }
        i = content.index(after: i)
      }

      // Ensure we don't end with a single backslash
      if content.last == "\\" {
        return false
      }

      return true
    }

    public static func validate(domain: String) -> Bool {
      // If the domain is a literal, we need to validate the content
      if isDomainLiteral(domain) {
        guard validate(domainLiteral: domain) else {
          return false
        }
      }
      // Otherwise, validate as a hostname
      else {
        // Must contain at least one dot, not end with a dot, and be a valid hostname
        guard
          domain.contains(".") && !domain.hasSuffix("."),
          RFC5890.IDNHostname.parse(string: String(domain)) != nil
        else {
          return false
        }
      }
      return true
    }

    public static func isDomainLiteral(_ string: String) -> Bool {
      string.hasPrefix("[") && string.hasSuffix("]")
    }

    public static func validate(domainLiteral: String) -> Bool {
      let literalContent = String(domainLiteral.dropFirst().dropLast())
      return validateIPv4AddressLiteral(literalContent)
        || validateIPv6AddressLiteral(literalContent) || validateGeneralLiteral(literalContent)
    }

    public static func validateIPv4AddressLiteral(_ string: String) -> Bool {
      RFC2673.IPv4Address.parse(string: string) != nil
    }

    public static let ipv6LiteralPrefix = "IPv6:"

    public static func validateIPv6AddressLiteral(_ string: String) -> Bool {
      string.hasPrefix(Self.ipv6LiteralPrefix)
        && RFC4291.IPv6Address.parse(string: String(string.trimmingPrefix(Self.ipv6LiteralPrefix))) != nil
    }

    public static func validateGeneralLiteral(_ string: String) -> Bool {
      let parts = string.split(separator: ":", maxSplits: 2)
      guard parts.count == 2 else {
        return false
      }
      // Validate the label is a valid hostname
      let standardizedLabel = String(parts[0])
      guard RFC5890.IDNHostname.parse(string: standardizedLabel) != nil else {
        return false
      }
      // Validate the content
      let content = String(parts[1])
      guard content.wholeMatch(of: #/^[\x21-\x5A\x5E-\x7E]+$/#) != nil else {
        return false
      }
      return true
    }
  }
}
