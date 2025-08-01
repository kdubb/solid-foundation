//
//  Instant+Foundation.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/26/25.
//

import Foundation

extension Instant {

  /// Initializes an `Instant` from a `Foundation.Date`.
  ///
  /// - Parameter date: The `Date` to convert to an `Instant`.
  ///
  public init(date: Date) {
    let duration = Duration(
      seconds: date.timeIntervalSinceReferenceDate + Date.timeIntervalBetween1970AndReferenceDate
    )
    self.init(durationSinceEpoch: duration)
  }

}

extension Date {

  /// Initializes a `Date` from an `Instant`.
  ///
  /// - Parameter instant: The `Instant` to convert to a `Date`.
  ///
  public init(instant: Instant) {
    let durationSinceReferenceDate = instant.durationSinceEpoch - durationBetween1970AndReferenceDate
    let timeIntervalSinceReferenceDate = Double(durationSinceReferenceDate.nanoseconds) / 1_000_000_000
    self.init(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
  }

}

private let durationBetween1970AndReferenceDate = Duration(seconds: Date.timeIntervalBetween1970AndReferenceDate)
