//
//  Pointer-Error.swift
//  Codex
//
//  Created by Kevin Wooten on 1/31/25.
//

import Foundation

extension Pointer {

  /// Errors that can occur when working with JSON Pointers.
  public enum Error: Swift.Error {
    /// The reference token is invalid.
    ///
    /// This error occurs when trying to create a reference token from an invalid string.
    case invalidReferenceToken(String)
  }

}

extension Pointer.Error: LocalizedError {

  /// Human-readable description of the error.
  public var errorDescription: String? {
    switch self {
    case .invalidReferenceToken(let token):
      return "The reference token '\(token)' is invalid."
    }
  }

}
