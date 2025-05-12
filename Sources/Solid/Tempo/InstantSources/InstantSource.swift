//
//  InstantSource.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/26/25.
//

/// Any source of ``Instant`` values.
///
public protocol InstantSource: Sendable {

  /// Returns the current instant since Tempo's epoch (January 1, 1970 equivalent to Unix epoch).
  var instant: Instant { get }
}
