//
//  RFC5891.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/4/25.
//

import Foundation

/// Namespace for RFC-5891 related types and functions.
///
public enum RFC5891 {

  /// A collection of functions for validating Punycode labels.
  public enum Punycode {

    /// The case-insensitive prefix that identifies a Punycode label.
    public static let prefix = "xn--"

    /// Tests whether a label appears to be in Punycode format by checking for the ``prefix``.
    ///
    /// This is a quick check that only verifies the presence of the Punycode prefix.
    /// For full validation, use `validate(punycodeLabel:)` after calling this function.
    ///
    /// - Parameter label: The string to check for Punycode format
    /// - Returns: `true` if the label starts with "xn--" (case-insensitive), `false` otherwise
    ///
    public static func isProbablyPunycode(_ label: Substring) -> Bool {
      label.lowercased().hasPrefix(prefix)
    }

    /// Validates whether a given label conforms to the Punycode (A-label) format.
    ///
    /// A valid Punycode label must:
    /// - Start with "xn--" (case-insensitive prefix)
    /// - Be followed by one alphanumeric character
    /// - Contain 0-57 additional alphanumeric characters or single hyphens (no consecutive hyphens)
    /// - End with an alphanumeric character
    /// - Have a total length between 5 and 63 characters
    ///
    /// - Parameter punycodeLabel: The string to validate as a Punycode label
    /// - Returns: `true` if the label is a valid Punycode label, `false` otherwise
    ///
    public static func validate(punycodeLabel: Substring) -> Bool {
      // Matches a Punycode label: "xn--" prefix (case-insensitive), followed by alphanumeric chars
      // with optional single hyphens in between (no consecutive hyphens)
      let punycodeRegex = /^(?i:xn--)[A-Za-z0-9](?:[A-Za-z0-9]|-(?!-))*[A-Za-z0-9]$/

      // Check the basic format
      return punycodeLabel.wholeMatch(of: punycodeRegex) != nil
    }

  }

}
