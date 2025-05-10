//
//  Clock.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/26/25.
//

extension Tempo {

  /// A clock is a source of instants in a specific time zone.
  public protocol Clock: InstantSource {

    /// Time zone this clock provides instants for.
    var zone: Zone { get }
    /// The source of instants this clock uses.
    var source: any Tempo.InstantSource { get }
    /// Returns the current instant in the clock's time zone.
    var instant: Tempo.Instant { get }
  }

}
