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

  public var date: LocalDate
  public var time: LocalTime

  public var availableZone: Zone? { nil }
  public var availableZoneOffset: ZoneOffset? { nil }

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
    self.init(
      date: LocalDate(components: components),
      time: LocalTime(components: components),
    )
  }

}

// MARK - Conversion Initializers

extension LocalDateTime {

  /// Initializes an ``LocalTime`` by converting an instance of the ``DateTime`` protocol.
  ///
  /// - Parameter dateTime: The ``DateTime`` to convert.
  ///
  public init(_ dateTime: some DateTime) {
    self.init(date: dateTime.date, time: dateTime.time)
  }

}
