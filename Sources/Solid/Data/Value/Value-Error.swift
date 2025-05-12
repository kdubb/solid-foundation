//
//  Value-Error.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 1/28/25.
//

extension Value {

  /// Errors that can occur when working with JSON values.
  public enum Error: Swift.Error {
    /// The value cannot be converted to an integer.
    ///
    /// - Parameter value: The invalid value that was attempted to be converted
    case invalidInteger(Any & Sendable)
    /// The value cannot be converted to a decimal number.
    ///
    /// - Parameter value: The invalid value that was attempted to be converted
    case invalidDecimal(Any & Sendable)
  }

}
