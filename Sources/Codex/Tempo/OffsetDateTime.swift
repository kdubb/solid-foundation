//
//  OffsetDateTime.swift
//  Codex
//
//  Created by Kevin Wooten on 4/27/25.
//

extension Tempo {

  /// A date & time at a specific fixed zone offset.
  ///
  public struct OffsetDateTime: DateTime {

    public var dateTime: LocalDateTime
    public var date: LocalDate { dateTime.date }
    public var time: LocalTime { dateTime.time }
    public var offset: ZoneOffset

    /// Initializes an instance of ``Tempo/OffsetDateTime`` with the specified date and time components
    /// at the specified zone offset.
    ///
    /// - Parameters:
    ///   - dateTime: The date and time components to use.
    ///   - offset: The time zone offset to use.
    ///
    public init(dateTime: LocalDateTime, offset: ZoneOffset) {
      self.dateTime = dateTime
      self.offset = offset
    }

    /// Initializes an instance of ``Tempo/OffsetDateTime`` with the specified date and time components
    /// at the offset of specified time zone.
    ///
    /// - Parameters:
    ///   - dateTime: The date and time components to use.
    ///   - zone: The time zone used to determine the `offset`.
    ///   - resolving: The resolution strategy to use. Defaults to `.default`.
    ///   - calendarSystem: The calendar system to use. Defaults to `.default`.
    /// - Throws: A ``Tempo/Error`` if the conversion local-time is an unresolvable local-time.
    ///
    public init(
      dateTime: LocalDateTime,
      zone: Zone,
      resolving: ResolutionStrategy.Options = [],
      in calendarSystem: CalendarSystem = .default
    ) throws {
      let instant = try calendarSystem.instant(from: dateTime, resolution: resolving.strategy)
      self.dateTime = dateTime
      self.offset = zone.offset(at: instant)
    }

    /// Initializes an instance of ``Tempo/OffsetDateTime`` with the specified date and time components
    /// at the specified zone offset.
    ///
    /// - Parameters:
    ///   - year: The year component of the date.
    ///   - month: The month component of the date.
    ///   - day: The day component of the date.
    ///   - hour: The hour component of the time.
    ///   - minute: The minute component of the time.
    ///   - second: The second component of the time.
    ///   - nanosecond: The nanosecond component of the time.
    ///   - offset: The time zone offset to use.
    /// - Throws: A ``Tempo/Error`` if the conversion local-time is an unresolvable local-time.
    ///
    public init(
      year: Int,
      month: Int,
      day: Int,
      hour: Int,
      minute: Int,
      second: Int,
      nanosecond: Int,
      offset: ZoneOffset
    ) throws {
      try self.init(
        dateTime: LocalDateTime(
          year: year,
          month: month,
          day: day,
          hour: hour,
          minute: minute,
          second: second,
          nanosecond: nanosecond
        ),
        offset: offset
      )
    }

    /// Creates a new instance of ``Tempo/OffsetDateTime`` with one or more of the date, time or zone parts
    /// modified.
    ///
    /// - Note: Modifying the `offset` part using this function will anchor to the same local-time. If
    ///    you want to preserve the same instant, use the `withOffset(_:anchor:)` method instead,
    ///    passing `.sameInstant` as the anchor.
    ///
    /// - Parameters:
    ///   - date: The new date to set. If `nil`, the current date is used.
    ///   - time: The new time to set. If `nil`, the current time is used.
    ///   - offset: The new time zone offset to set, anchoring to the local-time. If `nil`, the current time zone is used.
    /// - Returns: A new instance of ``Tempo/OffsetDateTime`` with the specified parts modified.
    ///
    public func with(
      date: LocalDate? = nil,
      time: LocalTime? = nil,
      offset: ZoneOffset? = nil,
    ) -> Self {
      let dateTime = dateTime.with(date: date ?? self.date, time: time ?? self.time)
      return Self(
        dateTime: dateTime,
        offset: offset ?? self.offset
      )
    }

    /// Creates a new instance of ``Tempo/OffsetDateTime`` with one or components of the date and time
    /// or the zone part modified.
    ///
    /// - Note: Modifying the `offset` part using this function will anchor to the same local-time. If
    ///    you want to preserve the same instant, use the `withOffset(_:anchor:)` method instead,
    ///    passing `.sameInstant` as the anchor.
    ///
    /// - Parameters:
    ///   - year: The new year to set. If `nil`, the current year is used.
    ///   - month: The new month to set. If `nil`, the current month is used.
    ///   - day: The new day to set. If `nil`, the current day is used.
    ///   - hour: The new hour to set. If `nil`, the current hour is used.
    ///   - minute: The new minute to set. If `nil`, the current minute is used.
    ///   - second: The new second to set. If `nil`, the current second is used.
    ///   - nanosecond: The new nanosecond to set. If `nil`, the current nanosecond is used.
    ///   - offset: The new time zone offset to set, anchoring to the local-time. If `nil`, the current time zone is used.
    /// - Returns: A new instance of ``Tempo/OffsetDateTime`` with the specified parts modified.
    /// - Throws: A ``Tempo/Error`` if the conversion fails due to an unresolvable local-time.
    ///
    public func with(
      year: Int? = nil,
      month: Int? = nil,
      day: Int? = nil,
      hour: Int? = nil,
      minute: Int? = nil,
      second: Int? = nil,
      nanosecond: Int? = nil,
      offset: ZoneOffset? = nil,
    ) throws -> Self {
      let date = date
      let time = time
      return try self.with(
        date: date.with(
          year: year ?? date.year,
          month: month ?? date.month,
          day: day ?? date.day
        ),
        time: time.with(
          hour: hour ?? time.hour,
          minute: minute ?? time.minute,
          second: second ?? time.second,
          nanosecond: nanosecond ?? time.nanosecond
        ),
        offset: offset ?? self.offset,
      )
    }

    /// Creates a new instance of ``Tempo/OffsetDateTime`` at the specified time zone offset.
    ///
    /// - Parameters:
    ///   - offset: The time zone offset to use.
    ///   - anchor: The ``Tempo/AdjustmentAnchor`` that determines whether the
    ///   instant or local-time the is preserved. Defaults to ``Tempo/AdjustmentAnchor/sameInstant``.
    ///   - calendarSystem: The calendar system to use. Defaults to `.default`.
    /// - Returns: A new instance of ``ZonedDateTime`` in the specified time zone.
    /// - Throws: A ``Tempo/Error`` if the conversion fails due to an unresolvable local-time.
    ///
    public func withOffset(
      _ offset: ZoneOffset,
      anchor: AdjustmentAnchor = .sameInstant,
      in calendarSystem: CalendarSystem = .default
    ) throws -> Self {
      switch anchor {
      case .sameLocalTime:
        return with(offset: offset)
      case .sameInstant:
        let instant = try calendarSystem.instant(from: self, resolution: .default)
        return calendarSystem.components(from: instant, in: .fixed(offset: offset))
      }
    }

    /// Creates a new instance of ``Tempo/OffsetDateTime`` sourced from a provided ``Tempo/Clock``.
    ///
    /// - Parameters:
    ///   - clock: The clock to use. Defaults to ``Tempo/Clock/system``.
    ///   - calendarSystem: The calendar system to use. Defaults to `.default`.
    /// - Returns: A new instance of ``Tempo/OffsetDateTime`` sourced from the provided `clock`.
    ///
    public static func now(clock: some Clock = .system, in calendarSystem: CalendarSystem = .default) -> Self {
      return calendarSystem.components(from: clock.instant, in: clock.zone)
    }
  }

}

extension Tempo.OffsetDateTime: Tempo.LinkedComponentContainer, Tempo.ComponentBuildable {

  public static let links: [any Tempo.ComponentLink<Self>] = [
    Tempo.ComponentKeyPathLink(.year, to: \.dateTime.date.year),
    Tempo.ComponentKeyPathLink(.monthOfYear, to: \.dateTime.date.month),
    Tempo.ComponentKeyPathLink(.dayOfMonth, to: \.dateTime.date.day),
    Tempo.ComponentKeyPathLink(.hourOfDay, to: \.dateTime.time.hour),
    Tempo.ComponentKeyPathLink(.minuteOfHour, to: \.dateTime.time.minute),
    Tempo.ComponentKeyPathLink(.secondOfMinute, to: \.dateTime.time.second),
    Tempo.ComponentKeyPathLink(.nanosecondOfSecond, to: \.dateTime.time.nanosecond),
    Tempo.ComponentKeyPathLink(.zoneOffset, to: \.offset.totalSeconds),
  ]

  public init(components: some Tempo.ComponentContainer) {
    self.init(
      dateTime: Tempo.LocalDateTime(components: components),
      offset: Tempo.ZoneOffset(components: components)
    )
  }

}

extension Tempo.OffsetDateTime: Sendable {}
extension Tempo.OffsetDateTime: Hashable {}
extension Tempo.OffsetDateTime: Equatable {}

extension Tempo.OffsetDateTime: CustomStringConvertible {

  public var description: String {
    "\(dateTime)\(offset)"
  }
}
