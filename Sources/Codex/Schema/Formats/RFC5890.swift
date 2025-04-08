//
//  RFC5890.swift
//  Codex
//
//  Created by Kevin Wooten on 4/4/25.
//

import Foundation
import RegexBuilder

/// Namespace for RFC-5890 related types and functions.
///
public enum RFC5890 {

  /// A structure representing a validated hostname.
  public struct IDNHostname {

    /// Maximum overall length for a hostname.
    public static let maxLength = 255

    /// The hostname split into its labels.
    public let labels: [String]

    /// The fully qualified hostname string.
    public var value: String {
      labels.joined(separator: ".")
    }

    /// Initializes a Hostname instance with the provided labels.
    ///
    /// - Parameter labels: An array of labels that make up the hostname.
    public init(labels: [String]) {
      self.labels = labels
    }

    /// Attempts to parse and validate an IDN hostname string.
    ///
    /// The hostname must be a series of labels separated by dots.
    /// Each label must either be:
    ///   - a Unicode label: starting and ending with a Unicode letter or digit, and containing
    ///     only Unicode letters, digits, and hyphens (with a maximum length of 63 characters), or
    ///   - a Punycode label: beginning with the case‑insensitive prefix "xn--" and conforming to the
    ///     same LDH rules (with the remainder being 1–59 characters).
    /// An optional trailing dot is allowed.
    ///
    /// - Parameter string: The hostname string to validate.
    /// - Returns: A Hostname instance if valid; otherwise, nil.
    public static func parse(string: String) -> IDNHostname? {

      guard let labels = RFC1123.Hostname.extractLabelsIfValid(string: string, maxLength: maxLength) else {
        return nil
      }

      // Validate each label is either a valid Unicode label or a valid Punycode label
      for label in labels {
        // Check if it's a Punycode label
        if RFC5891.Punycode.isProbablyPunycode(label) {
          guard RFC5891.Punycode.validate(punycodeLabel: label) else {
            return nil
          }
        }
        // Otherwise check if it's a valid Unicode label
        else if !label.isEmpty {
          guard validate(unicodeLabel: label) else {
            return nil
          }
        }
      }

      return IDNHostname(labels: labels.map(String.init))
    }

    /// Validates whether a given label conforms to the Unicode (U-label) format.
    ///
    /// A valid Unicode label must:
    /// - Start with a Unicode letter or digit
    /// - Contain 0-61 additional Unicode letters, digits, or hyphens
    /// - End with a Unicode letter or digit
    /// - Have a total length between 1 and 63 characters
    /// - Not contain consecutive hyphens (handled separately)
    ///
    /// - Parameter unicodeLabel: The string to validate as a Unicode hostname label
    /// - Returns: `true` if the label is a valid Unicode hostname label, `false` otherwise
    public static func validate(unicodeLabel: Substring) -> Bool {

      // Check for consecutive hyphens (not allowed in non-Punycode labels)
      guard !unicodeLabel.contains("--") else {
        return false
      }

      // Matches a label that starts and ends with Unicode letters/digits, with optional letters/digits/hyphens in between
      let unicodeRegex = /^[\p{L}\p{N}](?:[\p{L}\p{N}-]{0,61}[\p{L}\p{N}])?$/

      return unicodeLabel.wholeMatch(of: unicodeRegex) != nil
    }
  }
}
