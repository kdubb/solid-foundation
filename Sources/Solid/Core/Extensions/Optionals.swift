//
//  Optionals.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/8/25.
//

public enum OptionalError: Error {
  case nilUnwrapped(message: String)
}

extension Optional {

  @inlinable
  package func unwrap(_ message: String? = nil) throws -> Wrapped {
    try unwrap(or: OptionalError.nilUnwrapped(message: message ?? "Attempt to unwrap nil"))
  }

  @inlinable
  package func unwrap(or error: @autoclosure () -> Error) throws -> Wrapped {
    guard let value = self else {
      throw error()
    }
    return value
  }

  package func neverNil(
    _ message: String = "Unwrap of optional declared as never nil",
    file: StaticString = #file,
    line: UInt = #line
  ) -> Wrapped {
    guard let value = self else {
      fatalError(message, file: file, line: line)
    }
    return value
  }

}

package protocol OptionalConvertible {
  associatedtype Wrapped
  var toOptional: Optional<Wrapped> { get }
}

extension Optional: OptionalConvertible {
  package var toOptional: Optional<Wrapped> { self }
}
