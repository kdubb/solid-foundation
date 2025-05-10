//
//  Unit.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/5/25.
//

extension Tempo {

  /// Units for durations and periods of time.
  public enum Unit: Sendable, Hashable, Equatable, Comparable {
    case nan
    case eras
    case millenia
    case centuries
    case decades
    case years
    case months
    case weeks
    case days
    case hours
    case minutes
    case seconds
    case milliseconds
    case microseconds
    case nanoseconds
  }

}
