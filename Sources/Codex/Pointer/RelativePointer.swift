//
//  RelativePointer.swift
//  Codex
//
//  Created by Kevin Wooten on 4/4/25.
//

import Foundation
import RegexBuilder

/// A relative JSON pointer that references a location relative to a current JSON pointer.
///
/// Implements relative JSON pointers as defined in draft-handrews-relative-json-pointer-01.
/// A relative pointer is of the form:
///     non-negative-integer ( ("#") / ( "/" json-pointer ) )
/// For example:
///     "0#"    -> means 0 levels up and return the key/index of the current node.
///     "1/foo" -> means go up one level, then follow the JSON pointer "/foo".
///
/// The syntax is defined in draft-handrews-relative-json-pointer-01 as:
///
///     relative-json-pointer = non-negative-integer ( ("#") / ( "/" json-pointer ) )
///
/// This struct uses the existing `Pointer` type (defined in Pointer.swift) to represent the JSON pointer portion.
public struct RelativePointer: Equatable, Hashable, CustomStringConvertible {

  /// The tail of a relative pointer, which is either a key indicator ("#")
  /// or a JSON pointer.
  public enum Tail: Equatable, Hashable {
    /// Indicates that the relative pointer ends with "#". This form is used to
    /// return the key (or index) of the current location in its parent.
    case keyIndicator

    /// A JSON pointer (as defined in RFC 6901) that follows the relative pointer
    /// upward traversal.
    case pointer(Pointer)
  }

  /// The number of levels to go up from the current location.
  public let up: Int

  /// The tail part of the relative pointer.
  public let tail: Tail

  /// Returns the encoded relative pointer string.
  public var description: String {
    switch tail {
    case .keyIndicator:
      return "\(up)#"
    case .pointer(let pointer):
      return "\(up)\(pointer.encoded)"
    }
  }

  /// The encoded form of the relative pointer.
  public var encoded: String {
    description
  }

  /// Initializes a RelativePointer from an encoded relative pointer string.
  ///
  /// The relative pointer must follow the syntax:
  ///
  ///     relative-json-pointer = non-negative-integer ( ("#") / ( "/" json-pointer ) )
  ///
  /// For example:
  ///
  ///     "0#"    represents 0 levels up with a key indicator.
  ///     "1/foo" represents 1 level up followed by the JSON pointer "/foo".
  ///
  /// - Parameter string: The encoded relative pointer string.
  public init?(encoded string: String) {
    let regex = #/^(?<up>\d+)(?<tail>#|/.*)$/#

    guard let match = string.wholeMatch(of: regex) else {
      return nil
    }

    // Extract the 'up' count.
    self.up = Int(match.output.up) ?? 0

    // Extract the tail component.
    let tailString = String(match.output.tail)
    if tailString == "#" {
      self.tail = .keyIndicator
    } else {
      // The tail must start with '/', as per the syntax.
      guard tailString.first == "/" else { return nil }
      // Use the existing Pointer initializer to parse the JSON pointer portion.
      guard let pointer = Pointer(encoded: tailString) else {
        return nil
      }
      self.tail = .pointer(pointer)
    }
  }

  public func relative(to pointer: Pointer) -> Pointer? {
    var pointer: Pointer = pointer
    for _ in 0..<up {
      pointer = pointer.parent
      if pointer.tokens.isEmpty {
        break
      }
    }
    switch tail {
    case .keyIndicator:
      return pointer
    case .pointer(let tailPointer):
      return pointer / tailPointer
    }
  }
}