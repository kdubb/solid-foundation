//
//  LogLevel.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/28/25.
//

import Synchronization


public enum LogLevel: Int, Equatable, Hashable, Comparable, Sendable {

  case trace = 0
  case debug = 1
  case info = 2
  case notice = 3
  case warning = 4
  case error = 5
  case critical = 6

  @inlinable
  public func isEnabled(in minimumLevel: Self) -> Bool {
    return self >= minimumLevel
  }

  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }

}

extension LogLevel: AtomicRepresentable {}
