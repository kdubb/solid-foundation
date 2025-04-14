//
//  BigDecimal.swift
//  Codex
//
//  Created by Kevin Wooten on 2/13/25.
//

import BigDecimal

package extension BigDecimal {

  /// Initialize a BigDecimal from a string.
  ///
  /// - Parameter string: The string to initialize the BigDecimal from.
  ///
  init?<S: StringProtocol>(string: S) {
    let value = BigDecimal(string.description)
    guard value.isFinite else {
      return nil
    }
    self = value
  }

  /// Round a BigDecimal to the nearest integer, truncating fractional digits.
  ///
  /// - Returns: A BigDecimal rounded to the nearest integer.
  ///
  func truncate() -> BigDecimal {
    self.rounded(.towardZero)
  }

}
