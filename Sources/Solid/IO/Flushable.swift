//
//  Flushable.swift
//  SolidIO
//
//  Created by Kevin Wooten on 7/4/25.
//


/// Any type that supports a ``flush()`` operation.
///
public protocol Flushable {

  /// Writes any pending data to the destination sink.
  ///
  /// - Throws: ``IOError`` if writing pending data fails.
  ///
  func flush() async throws

}
