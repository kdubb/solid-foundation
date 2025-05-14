//
//  RFC3339.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/4/25.
//

import SolidNumeric


/// Namespace for RFC-3339 related types and functions.
///
public struct RFC3339 {

  /// A structure representing an ISO‑8601 duration.
  public struct Duration {
    /// Period as years, months, and days, or weeks.
    public enum Period {
      /// Years, months, and days.
      case date(years: Int?, months: Int?, days: Int?)
      /// Weeks.
      case weeks(Int)
    }

    /// Time as hours, minutes, and seconds.
    public struct Time {
      /// Hours (HH).
      public var hours: Int?
      /// Minutes (MM).
      public var minutes: Int?
      /// Seconds (SS[.SSSSSSSSS]).
      public var seconds: BigDecimal?
    }

    /// The period component of the duration.
    public var period: Period?
    /// The time component of the duration.
    public var time: Time?

    /// Initializes a Duration with the given period and time components.
    ///
    /// - Parameters:
    ///  - period: The period component.
    ///  - time: The time component.
    ///
    public init(period: Period?, time: Time?) {
      self.period = period
      self.time = time
    }
  }
}
