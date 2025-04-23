//
//  BigDecimal+Foundation.swift
//  Codex
//
//  Created by Kevin Wooten on 4/16/25.
//

import Foundation


/// A format style that formats a BigDecimal value.
public struct DecimalFormatStyle: FormatStyle, Codable, Hashable, Sendable {

  public typealias FormatInput = BigDecimal
  public typealias FormatOutput = String

  internal static let `default`: DecimalFormatStyle = .init()

  /// The locale to use when formatting the number.
  public var locale: Locale

  /// The grouping style to use when formatting the number.
  public var grouping: DecimalFormatStyle.Grouping

  /// The sign display strategy to use when formatting the number.
  public var sign: DecimalFormatStyle.SignDisplayStrategy

  /// The precision to use when formatting the number.
  public var precision: DecimalFormatStyle.Precision

  /// The decimal separator display strategy to use when formatting the number.
  public var decimalSeparator: DecimalFormatStyle.DecimalSeparatorDisplayStrategy

  /// Creates a new format style with default settings.
  public init() {
    self.locale = .autoupdatingCurrent
    self.grouping = .automatic
    self.sign = .automatic
    self.precision = .fractionLength(0...6)
    self.decimalSeparator = .automatic
  }

  /// Formats a BigDecimal value using this style.
  public func format(_ value: BigDecimal) -> String {
    // Handle special values
    if value.isNaN {
      return "NaN"
    }
    if value.isInfinite {
      return value.isNegative ? "-∞" : (sign == .always ? "+∞" : "∞")
    }

    // Format the number
    var string: String

    // Handle zero case
    if value.isZero {
      string = "0"
      if value.scale > 0 {
        string += (locale.decimalSeparator ?? ".") + String(repeating: "0", count: value.scale)
      }
    } else {
      // Convert magnitude to string
      let digits = value.mantissa.magnitude.description

      // Handle scale = 0
      if value.scale == 0 {
        string = digits
      } else if value.scale < 0 {
        // Negative scale (multiply by 10^n)
        string = digits + String(repeating: "0", count: -value.scale)
      } else {
        // Positive scale (divide by 10^n)
        if value.scale >= digits.count {
          // All digits go after decimal point with leading zeros
          let leadingZeros = String(repeating: "0", count: value.scale - digits.count)
          string = "0" + leadingZeros + digits
          string.insert(contentsOf: locale.decimalSeparator ?? ".", at: string.index(after: string.startIndex))
        } else {
          // Split digits around decimal point
          let decimalIndex = digits.count - value.scale
          string = digits
          string.insert(
            contentsOf: locale.decimalSeparator ?? ".",
            at: string.index(string.startIndex, offsetBy: decimalIndex)
          )
        }
      }

      // Add sign if negative
      if value.isNegative {
        string = "-" + string
      }
    }

    // Apply sign strategy
    switch sign {
    case .automatic:
      break
    case .always:
      if !value.isNegative && !value.isZero {
        string = "+" + string
      }
    case .never:
      if value.isNegative {
        string.removeFirst()
      }
    }

    // Apply precision
    switch precision {
    case .fractionLength(let range):
      let parts = string.split(separator: locale.decimalSeparator ?? ".")
      if parts.count == 1 {
        if range.lowerBound > 0 {
          string += (locale.decimalSeparator ?? ".") + String(repeating: "0", count: range.lowerBound)
        }
      } else {
        let fraction = parts[1]
        if fraction.count < range.lowerBound {
          string += String(repeating: "0", count: range.lowerBound - fraction.count)
        } else if fraction.count > range.upperBound {
          let index = string.index(string.startIndex, offsetBy: parts[0].count + 1 + range.upperBound)
          string = String(string[..<index])
        }
      }
    case .significantDigits(let range):
      // Remove any existing sign and decimal point
      let isNegative = string.hasPrefix("-")
      if isNegative {
        string.removeFirst()
      }
      string = string.replacingOccurrences(of: locale.decimalSeparator ?? ".", with: "")

      // Count leading zeros
      let leadingZeros = string.prefix(while: { $0 == "0" }).count
      let significantDigits = string.count - leadingZeros

      if significantDigits == 0 {
        // All zeros case
        string = String(repeating: "0", count: range.lowerBound)
        if range.lowerBound > 0 {
          string = "0" + (locale.decimalSeparator ?? ".") + string
        }
      } else {
        // Normal case
        let targetDigits = min(max(range.lowerBound, significantDigits), range.upperBound)
        let digitsToKeep = targetDigits + leadingZeros

        if digitsToKeep < string.count {
          // Need to round
          let index = string.index(string.startIndex, offsetBy: digitsToKeep)
          let nextDigit = string[index].wholeNumberValue ?? 0
          let rounded = String(string[..<index])
          let roundedInt = BigInt(rounded) ?? .zero
          let roundedUp = nextDigit >= 5 ? roundedInt + 1 : roundedInt
          string = String(roundedUp)
        }

        // Add decimal point if needed
        if leadingZeros > 0 {
          // Scientific notation
          let exponent = -(leadingZeros + 1)
          let mantissa = string.prefix(targetDigits)
          string = String(mantissa)
          string.insert(contentsOf: locale.decimalSeparator ?? ".", at: string.index(after: string.startIndex))
          string += "e" + (exponent >= 0 ? "+" : "") + String(exponent)
        } else if string.count > 1 {
          // Regular decimal
          string.insert(contentsOf: locale.decimalSeparator ?? ".", at: string.index(after: string.startIndex))
        }
      }

      // Restore sign
      if isNegative {
        string = "-" + string
      }
    }

    // Apply decimal separator strategy
    switch decimalSeparator {
    case .automatic:
      break
    case .always:
      if !string.contains(locale.decimalSeparator ?? ".") {
        string += locale.decimalSeparator ?? "."
      }
    case .never:
      string = string.replacingOccurrences(of: locale.decimalSeparator ?? ".", with: "")
    }

    return string
  }

}

// MARK: - Format Style Configuration

extension DecimalFormatStyle {

  /// The grouping style for decimal numbers.
  public enum Grouping: Codable, Hashable, Sendable {
    /// Use the locale's default grouping.
    case automatic
    /// Never use grouping.
    case never
  }

  /// The sign display strategy for decimal numbers.
  public enum SignDisplayStrategy: Codable, Hashable, Sendable {
    /// Show the sign only when the number is negative.
    case automatic
    /// Always show the sign.
    ///
    /// - Note: ``BigDecimal`` does not have signed zero and
    /// will never include a sign for zero.
    case always
    /// Never show the sign.
    case never
  }

  /// The precision for decimal numbers.
  public enum Precision: Codable, Hashable, Sendable {
    /// A range of fraction digits to display.
    case fractionLength(ClosedRange<Int>)
    /// A range of significant digits to display.
    case significantDigits(ClosedRange<Int>)
  }

  /// The decimal separator display strategy.
  public enum DecimalSeparatorDisplayStrategy: Codable, Hashable, Sendable {
    /// Use the locale's default decimal separator behavior.
    case automatic
    /// Always show the decimal separator.
    case always
    /// Never show the decimal separator.
    case never
  }

}

// MARK: - Format Style Configuration Methods

extension DecimalFormatStyle {

  /// Sets the locale for formatting.
  public func locale(_ locale: Locale) -> Self {
    var copy = self
    copy.locale = locale
    return copy
  }

  /// Sets the grouping style for formatting.
  public func grouping(_ grouping: Grouping) -> Self {
    var copy = self
    copy.grouping = grouping
    return copy
  }

  /// Sets the sign display strategy for formatting.
  public func sign(strategy: SignDisplayStrategy) -> Self {
    var copy = self
    copy.sign = strategy
    return copy
  }

  /// Sets the precision for formatting.
  public func precision(_ precision: Precision) -> Self {
    var copy = self
    copy.precision = precision
    return copy
  }

  /// Sets the decimal separator display strategy for formatting.
  public func decimalSeparator(strategy: DecimalSeparatorDisplayStrategy) -> Self {
    var copy = self
    copy.decimalSeparator = strategy
    return copy
  }

}

// MARK: - Sign Display Strategy Extensions

extension DecimalFormatStyle.SignDisplayStrategy {

  /// A strategy that always shows the sign.
  public struct Always {
    /// Whether to show the sign for zero.
    public let includingZero: Bool

    /// Creates a new strategy that always shows the sign.
    public init(includingZero: Bool = false) {
      self.includingZero = includingZero
    }
  }

  /// A strategy that never shows the sign.
  public struct Never {
    /// Creates a new strategy that never shows the sign.
    public init() {}
  }

}

// MARK: - Grouping Extensions

extension DecimalFormatStyle.Grouping {

  /// A strategy that never uses grouping.
  public struct Never {
    /// Creates a new strategy that never uses grouping.
    public init() {}
  }

}

// MARK: - Decimal Separator Display Strategy Extensions

extension DecimalFormatStyle.DecimalSeparatorDisplayStrategy {

  /// A strategy that always shows the decimal separator.
  public struct Always {
    /// Creates a new strategy that always shows the decimal separator.
    public init() {}
  }

  /// A strategy that never shows the decimal separator.
  public struct Never {
    /// Creates a new strategy that never shows the decimal separator.
    public init() {}
  }

}

// MARK: - Format Style Protocol Conformance

extension FormatStyle where Self == DecimalFormatStyle {

  /// Returns a format style for formatting decimal numbers.
  public static var number: Self {
    DecimalFormatStyle()
  }

}
