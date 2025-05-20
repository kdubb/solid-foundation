//
//  DateTime.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

/// Any composite date and time representation.
public protocol DateTime: Sendable, ComponentContainer, ComponentBuildable {
  /// The date component.
  var date: LocalDate { get }
  /// The time component.
  var time: LocalTime { get }
  /// The duration since the epoch (1970-01-01) at the given offset.
  func durationSinceEpoch(at offset: ZoneOffset) -> Duration
}

extension DateTime {

  public func durationSinceEpoch(at offset: ZoneOffset) -> Duration {

    let days = GregorianCalendarSystem.default.daysSinceEpoch(year: date.year, month: date.month, day: date.day)

    return .days(days) + Duration(components: time) - Duration(offset)
  }

  public func instant(at offset: ZoneOffset) -> Instant {
    Instant(durationSinceEpoch: durationSinceEpoch(at: offset))
  }

}
