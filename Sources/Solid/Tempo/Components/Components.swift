//
//  Components.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/30/25.
//


public enum Components: Sendable {

  public enum Id: Int, Equatable, Hashable, Sendable, CaseIterable {

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

    // Date Shorthand

    public static let month = monthOfYear
    public static let day = dayOfMonth

    // Time shorthand

    public static let hour = hourOfDay
    public static let minute = minuteOfHour
    public static let second = secondOfMinute
    public static let nanosecond = nanosecondOfSecond

    /// The name of the component associated with this identifier.
    public var name: String {
      names[rawValue]
    }

    /// The ``Component`` associated with this identifier.
    public var component: any Component {
      all[rawValue]
    }
  }

  // MARK: - Static Lookup Tables

  // Tables for all components using the index from `Id.rawValue`. To
  // enable fast lookup of names & components by id.

  internal static let mapEntries: [(Id, String, any Component)] = [
    // Date
    (.era, "era", era),
    (.year, "year", year),
    (.yearOfEra, "yearOfEra", yearOfEra),
    (.monthOfYear, "monthOfYear", monthOfYear),
    (.weekOfYear, "weekOfYear", weekOfYear),
    (.weekOfMonth, "weekOfMonth", weekOfMonth),
    (.dayOfYear, "dayOfYear", dayOfYear),
    (.dayOfMonth, "dayOfMonth", dayOfMonth),
    (.dayOfWeek, "dayOfWeek", dayOfWeek),
    (.dayOfWeekForMonth, "dayOfWeekForMonth", dayOfWeekForMonth),
    (.yearForWeekOfYear, "yearForWeekOfYear", yearForWeekOfYear),
    (.isLeapMonth, "isLeapMonth", isLeapMonth),
    // Time
    (.hourOfDay, "hourOfDay", hourOfDay),
    (.minuteOfHour, "minuteOfHour", minuteOfHour),
    (.secondOfMinute, "secondOfMinute", secondOfMinute),
    (.nanosecondOfSecond, "nanosecondOfSecond", nanosecondOfSecond),
    (.zoneOffset, "zoneOffset", zoneOffset),
    (.hoursOfZoneOffset, "hours", hoursOfZoneOffset),
    (.minutesOfZoneOffset, "minutes", minutesOfZoneOffset),
    (.secondsOfZoneOffset, "seconds", secondsOfZoneOffset),
    (.zoneId, "zoneId", zoneId),
    // Period/Duration
    (.calendarYears, "calendarYears", calendarYears),
    (.calendarMonths, "calendarMonths", calendarMonths),
    (.calendarWeeks, "calendarWeeks", calendarWeeks),
    (.calendarDays, "calendarDays", calendarDays),
    (.numberOfDays, "numberOfDays", numberOfDays),
    (.numberOfHours, "numberOfHours", numberOfHours),
    (.numberOfMinutes, "numberOfMinutes", numberOfMinutes),
    (.numberOfSeconds, "numberOfSeconds", numberOfSeconds),
    (.numberOfMilliseconds, "numberOfMilliseconds", numberOfMilliseconds),
    (.numberOfMicroseconds, "numberOfMicroseconds", numberOfMicroseconds),
    (.numberOfNanoseconds, "numberOfNanoseconds", numberOfNanoseconds),
    (.totalDays, "totalDays", totalDays),
    (.totalHours, "totalHours", totalHours),
    (.totalMinutes, "totalMinutes", totalMinutes),
    (.totalSeconds, "totalSeconds", totalSeconds),
    (.totalMilliseconds, "totalMilliseconds", totalMilliseconds),
    (.totalMicroseconds, "totalMicroseconds", totalMicroseconds),
    (.totalNanoseconds, "totalNanoseconds", totalNanoseconds),
    (.hoursOfDay, "hoursOfDay", hoursOfDay),
    (.minutesOfDay, "minutesOfDay", minutesOfDay),
    (.secondsOfDay, "secondsOfDay", secondsOfDay),
    (.millisecondsOfDay, "millisecondsOfDay", millisecondsOfDay),
    (.microsecondsOfDay, "microsecondsOfDay", microsecondsOfDay),
    (.nanosecondsOfDay, "nanosecondsOfDay", nanosecondsOfDay),
    (.minutesOfHour, "minutesOfHour", minutesOfHour),
    (.secondsOfHour, "secondsOfHour", secondsOfHour),
    (.millisecondsOfHour, "millisecondsOfHour", millisecondsOfHour),
    (.microsecondsOfHour, "microsecondsOfHour", microsecondsOfHour),
    (.nanosecondsOfHour, "nanosecondsOfHour", nanosecondsOfHour),
    (.secondsOfMinute, "secondsOfMinute", secondsOfMinute),
    (.millisecondsOfMinute, "millisecondsOfMinute", millisecondsOfMinute),
    (.microsecondsOfMinute, "microsecondsOfMinute", microsecondsOfMinute),
    (.nanosecondsOfMinute, "nanosecondsOfMinute", nanosecondsOfMinute),
    (.millisecondsOfSecond, "millisecondsOfSecond", millisecondsOfSecond),
    (.microsecondsOfSecond, "microsecondsOfSecond", microsecondsOfSecond),
    (.nanosecondsOfSecond, "nanosecondsOfSecond", nanosecondsOfSecond),
  ]
  .sorted { $0.0.rawValue < $1.0.rawValue }

  public static let idMap = Dictionary(uniqueKeysWithValues: mapEntries.map { ($0.1, $0.2) })

  public static let all = {
    // Check for undefined components
    let undefined = Set(Id.allCases).subtracting(mapEntries.map(\.0))
    assert(undefined.isEmpty, "Undefined components: \(undefined)")
    return ContiguousArray(mapEntries.map(\.2))
  }()

  internal static let names = ContiguousArray(mapEntries.map(\.1))
}


extension Components.Id: Comparable {

  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.rawValue < rhs.rawValue
  }

}
