//
//  LocalDateTime.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

/// A date and time without a time zone.
///
public struct LocalDateTime: DateTime {

  public static let min = LocalDateTime(date: .min, time: .min)
  public static let max = LocalDateTime(date: .max, time: .max)

  /// The date part.
  public var date: LocalDate
  /// The time part.
  public var time: LocalTime

  /// The year component of the date.
  public var year: Int { date.year }
  /// The month component of the date.
  public var month: Int { date.month }
  /// The day component of the date.
  public var day: Int { date.day }
  /// The hour component of the time.
  public var hour: Int { time.hour }
  /// The minute component of the time.
  public var minute: Int { time.minute }
  /// The second component of the time.
  public var second: Int { time.second }
  /// The nanosecond component of the time.
  public var nanosecond: Int { time.nanosecond }

  public init(date: LocalDate, time: LocalTime) {
    self.date = date
    self.time = time
  }

  public init(
    year: Int,
    month: Int,
    day: Int,
    hour: Int,
    minute: Int,
    second: Int,
    nanosecond: Int
  ) throws {
    self.init(
      date: try LocalDate(year: year, month: month, day: day),
      time: try LocalTime(hour: hour, minute: minute, second: second, nanosecond: nanosecond)
    )
  }

  public func at(zone: Zone, resolving: ResolutionStrategy.Options = []) throws -> ZonedDateTime {
    return try ZonedDateTime(
      dateTime: self,
      zone: zone,
      resolving: resolving,
    )
  }

  public func at(offset: ZoneOffset) -> OffsetDateTime {
    return OffsetDateTime(dateTime: self, offset: offset)
  }

  public func with(
    year: Int? = nil,
    month: Int? = nil,
    day: Int? = nil,
    hour: Int? = nil,
    minute: Int? = nil,
    second: Int? = nil,
    nanosecond: Int? = nil
  ) throws -> Self {
    return Self(
      date: try date.with(year: year, month: month, day: day),
      time: try time.with(hour: hour, minute: minute, second: second, nanosecond: nanosecond)
    )
  }

  public func with(date: LocalDate? = nil, time: LocalTime? = nil) -> Self {
    return Self(
      date: date ?? self.date,
      time: time ?? self.time
    )
  }

  public static func now(clock: some Clock = .system, in calendarSystem: CalendarSystem = .default) -> Self {
    return calendarSystem.components(from: clock.instant, in: clock.zone)
  }

}

extension LocalDateTime: Sendable {}
extension LocalDateTime: Hashable {}
extension LocalDateTime: Equatable {}

extension LocalDateTime: Comparable {

  public static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.date != rhs.date {
      return lhs.date < rhs.date
    }
    return lhs.time < rhs.time
  }
}

extension LocalDateTime: CustomStringConvertible {

  public var description: String {
    return "\(date) \(time)"
  }
}

extension LocalDateTime: LinkedComponentContainer, ComponentBuildable {

  public static let links: [any ComponentLink<Self>] = [
    ComponentKeyPathLink(.year, to: \.date.year),
    ComponentKeyPathLink(.monthOfYear, to: \.date.month),
    ComponentKeyPathLink(.dayOfMonth, to: \.date.day),
    ComponentKeyPathLink(.hourOfDay, to: \.time.hour),
    ComponentKeyPathLink(.minuteOfHour, to: \.time.minute),
    ComponentKeyPathLink(.secondOfMinute, to: \.time.second),
    ComponentKeyPathLink(.nanosecondOfSecond, to: \.time.nanosecond),
  ]

  public init(components: some ComponentContainer) {

    if let dateTime = components as? LocalDateTime {
      self = dateTime
      return
    } else if let dateTime = components as? DateTime {
      self.init(date: dateTime.date, time: dateTime.time)
      return
    }

    self.init(
      date: LocalDate(components: components),
      time: LocalTime(components: components),
    )
  }

  public init(availableComponents components: some ComponentContainer) {

    if let dateTime = components as? LocalDateTime {
      self = dateTime
      return
    } else if let dateTime = components as? DateTime {
      self.init(date: dateTime.date, time: dateTime.time)
      return
    }

    self.init(
      date: LocalDate(availableComponents: components),
      time: LocalTime(availableComponents: components),
    )
  }

}

// MARK - Conversion Initializers

extension LocalDateTime {

  /// Initializes a local date/time by converting an instance of the ``DateTime`` protocol.
  ///
  /// - Parameter dateTime: The ``DateTime`` to convert.
  ///
  public init(_ dateTime: some DateTime) {
    self.init(date: dateTime.date, time: dateTime.time)
  }

  /// Inlitializes a local date/time from a date and a duration of time.
  ///
  /// The time duration is converted to a local time with any duration of time over 24 hours
  /// added to the date.
  ///
  /// - Parameters:
  ///   - date: The local date.
  ///   - timeDuration: The duration of time to convert to a local time with any overflow added to the date.
  /// - Throws: A ``TempoError`` if the date, after applying any overflow, is invalid.
  ///
  public init(date: LocalDate, timeDuration: Duration) throws {
    let time = try LocalTime(dayOffset: timeDuration)
    let timeRollover: Duration = timeDuration - .nanoseconds(timeDuration[.nanosecondsOfDay])
    let rolledDate = try GregorianCalendarSystem.default.adding(components: timeRollover, to: date)
    self.init(date: rolledDate, time: time)
  }

}

extension LocalDateTime {

  /// Parses a date and time string per RFC-3339 (`YYYY-MM-DDTHH:MM:SS[.ssssssss]`) .
  ///
  /// - Parameter string: The date-time string.
  /// - Returns: Parsed date and time instance if valid; otherwise, nil.
  ///
  public static func parse(string: String) -> Self? {

    guard let sepIndex = string.firstIndex(where: { $0 == "T" || $0 == "t" }) else {
      return nil
    }

    let datePart = String(string[..<sepIndex])
    let timePart = String(string[string.index(after: sepIndex)...])

    guard
      let date = LocalDate.parse(string: datePart),
      let (time, rollover) = LocalTime.parseReportingRollver(string: timePart)
    else {
      return nil
    }

    guard rollover else {
      return Self(date: date, time: time)
    }

    guard
      let rolloverDate = try? GregorianCalendarSystem.default.adding(components: [.numberOfDays(1)], to: date)
    else {
      return nil
    }
    return Self(date: rolloverDate, time: time)
  }
}
