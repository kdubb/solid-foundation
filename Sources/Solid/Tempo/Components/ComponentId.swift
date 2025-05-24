//
//  ComponentId.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/23/25.
//

public enum ComponentId: String {

  // Date

  case era
  case year
  case yearOfEra
  case monthOfYear
  case weekOfYear
  case weekOfMonth
  case dayOfYear
  case dayOfMonth
  case dayOfWeek

  case dayOfWeekForMonth
  case yearForWeekOfYear
  case isLeapMonth

  // Time

  case hourOfDay
  case minuteOfHour
  case secondOfMinute
  case nanosecondOfSecond

  case zoneOffset
  case hoursOfZoneOffset
  case minutesOfZoneOffset
  case secondsOfZoneOffset

  case zoneId

  // Period/Duration

  // Period

  case calendarYears
  case calendarMonths
  case calendarWeeks
  case calendarDays

  // Duration

  case numberOfDays
  case numberOfHours
  case numberOfMinutes
  case numberOfSeconds
  case numberOfMilliseconds
  case numberOfMicroseconds
  case numberOfNanoseconds

  case totalDays
  case totalHours
  case totalMinutes
  case totalSeconds
  case totalMilliseconds
  case totalMicroseconds
  case totalNanoseconds

  case hoursOfDay
  case minutesOfDay
  case secondsOfDay
  case millisecondsOfDay
  case microsecondsOfDay
  case nanosecondsOfDay

  case minutesOfHour
  case secondsOfHour
  case millisecondsOfHour
  case microsecondsOfHour
  case nanosecondsOfHour

  case secondsOfMinute
  case millisecondsOfMinute
  case microsecondsOfMinute
  case nanosecondsOfMinute

  case millisecondsOfSecond
  case microsecondsOfSecond
  case nanosecondsOfSecond

  public var name: String { rawValue }

  public var component: any Component {
    switch self {

    case .era: .era
    case .year: .year
    case .yearOfEra: .yearOfEra
    case .monthOfYear: .monthOfYear
    case .weekOfYear: .weekOfYear
    case .weekOfMonth: .weekOfMonth
    case .dayOfYear: .dayOfYear
    case .dayOfMonth: .dayOfMonth
    case .dayOfWeek: .dayOfWeek

    case .dayOfWeekForMonth: .dayOfWeekForMonth
    case .yearForWeekOfYear: .yearForWeekOfYear
    case .isLeapMonth: .isLeapMonth

    case .hourOfDay: .hourOfDay
    case .minuteOfHour: .minuteOfHour
    case .secondOfMinute: .secondOfMinute
    case .nanosecondOfSecond: .nanosecondOfSecond

    case .zoneOffset: .zoneOffset
    case .hoursOfZoneOffset: .hoursOfZoneOffset
    case .minutesOfZoneOffset: .minutesOfZoneOffset
    case .secondsOfZoneOffset: .secondsOfZoneOffset

    case .zoneId: .zoneId

    case .calendarYears: .calendarYears
    case .calendarMonths: .calendarMonths
    case .calendarWeeks: .calendarWeeks
    case .calendarDays: .calendarDays

    case .numberOfDays: .numberOfDays
    case .numberOfHours: .numberOfHours
    case .numberOfMinutes: .numberOfMinutes
    case .numberOfSeconds: .numberOfSeconds
    case .numberOfMilliseconds: .numberOfMilliseconds
    case .numberOfMicroseconds: .numberOfMicroseconds
    case .numberOfNanoseconds: .numberOfNanoseconds

    case .totalDays: .totalDays
    case .totalHours: .totalHours
    case .totalMinutes: .totalMinutes
    case .totalSeconds: .totalSeconds
    case .totalMilliseconds: .totalMilliseconds
    case .totalMicroseconds: .totalMicroseconds
    case .totalNanoseconds: .totalNanoseconds

    case .hoursOfDay: .hoursOfDay
    case .minutesOfDay: .minutesOfDay
    case .secondsOfDay: .secondsOfDay
    case .millisecondsOfDay: .millisecondsOfDay
    case .microsecondsOfDay: .microsecondsOfDay
    case .nanosecondsOfDay: .nanosecondsOfDay

    case .minutesOfHour: .minutesOfHour
    case .secondsOfHour: .secondsOfHour
    case .millisecondsOfHour: .millisecondsOfHour
    case .microsecondsOfHour: .microsecondsOfHour
    case .nanosecondsOfHour: .nanosecondsOfHour

    case .secondsOfMinute: .secondsOfMinute
    case .millisecondsOfMinute: .millisecondsOfMinute
    case .microsecondsOfMinute: .microsecondsOfMinute
    case .nanosecondsOfMinute: .nanosecondsOfMinute

    case .millisecondsOfSecond: .millisecondsOfSecond
    case .microsecondsOfSecond: .microsecondsOfSecond
    case .nanosecondsOfSecond: .nanosecondsOfSecond

    }
  }
}

extension ComponentId: Equatable {}
extension ComponentId: Hashable {}

extension ComponentId: Comparable {

  public static func < (lhs: ComponentId, rhs: ComponentId) -> Bool { lhs.rawValue < rhs.rawValue }

}

extension ComponentId: Sendable {}

extension ComponentId: CustomStringConvertible {

  public var description: String {
    rawValue
  }

}
