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
  /// The duration since the epoch (1970-01-01).
  var durationSinceEpoch: Duration { get }
}

extension DateTime {

  public var durationSinceEpoch: Duration {

    let days = GregorianCalendarSystem.default.daysSinceEpoch(year: date.year, month: date.month, day: date.day)

    return .days(days) + Duration(components: time)
  }

}
