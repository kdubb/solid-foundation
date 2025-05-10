//
//  Optionals.swift
//  Codex
//
//  Created by Kevin Wooten on 2/8/25.
//

extension Optional {

  func unwrap(or error: @autoclosure () -> Error) throws -> Wrapped {
    guard let value = self else {
      throw error()
    }
    return value
  }

  func neverNil(
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

internal protocol OptionalConvertible {
  associatedtype Wrapped
  var toOptional: Optional<Wrapped> { get }
}

extension Optional: OptionalConvertible {
  var toOptional: Optional<Wrapped> { self }
}
