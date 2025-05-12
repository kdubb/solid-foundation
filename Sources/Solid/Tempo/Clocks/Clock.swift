//
//  Clock.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/26/25.
//

/// A clock is a source of instants in a specific time zone.
public protocol Clock: InstantSource {

  /// Time zone this clock provides instants for.
  var zone: Zone { get }
  /// The source of instants this clock uses.
  var source: any InstantSource { get }
  /// Returns the current instant in the clock's time zone.
  var instant: Instant { get }
}
