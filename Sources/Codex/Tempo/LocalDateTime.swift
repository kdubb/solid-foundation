//
//  LocalDateTime.swift
//  Codex
//
//  Created by Kevin Wooten on 4/27/25.
//

extension Tempo {

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

}

extension Tempo.LocalDateTime: Sendable {}
extension Tempo.LocalDateTime: Hashable {}
extension Tempo.LocalDateTime: Equatable {}

extension Tempo.LocalDateTime: Comparable {

  public static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.date != rhs.date {
      return lhs.date < rhs.date
    }
    return lhs.time < rhs.time
  }
}

extension Tempo.LocalDateTime: CustomStringConvertible {

  public var description: String {
    return "\(date) \(time)"
  }
}

extension Tempo.LocalDateTime: Tempo.LinkedComponentContainer, Tempo.ComponentBuildable {

  public static let links: [any Tempo.ComponentLink<Self>] = [
    Tempo.ComponentKeyPathLink(.year, to: \.date.year),
    Tempo.ComponentKeyPathLink(.monthOfYear, to: \.date.month),
    Tempo.ComponentKeyPathLink(.dayOfMonth, to: \.date.day),
    Tempo.ComponentKeyPathLink(.hourOfDay, to: \.time.hour),
    Tempo.ComponentKeyPathLink(.minuteOfHour, to: \.time.minute),
    Tempo.ComponentKeyPathLink(.secondOfMinute, to: \.time.second),
    Tempo.ComponentKeyPathLink(.nanosecondOfSecond, to: \.time.nanosecond),
  ]

  public init(components: some Tempo.ComponentContainer) {
    self.init(
      date: Tempo.LocalDate(components: components),
      time: Tempo.LocalTime(components: components),
    )
  }

}

// MARK - Conversion Initializers

extension Tempo.LocalDateTime {

  /// Initializes an ``Tempo/LocalTime`` by converting an instance of the ``Tempo/DateTime`` protocol.
  ///
  /// - Parameter dateTime: The ``Tempo/DateTime`` to convert.
  ///
  public init(_ dateTime: some Tempo.DateTime) {
    self.init(date: dateTime.date, time: dateTime.time)
  }

}
