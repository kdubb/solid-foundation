//
//  ZonedDateTime.swift
//  Codex
//
//  Created by Kevin Wooten on 4/27/25.
//

extension Tempo {

  /// A date & time in a specific time zone.
  ///
  public struct ZonedDateTime: DateTime {

    /// The date and time parts.
    public var dateTime: LocalDateTime
    /// The date part.
    public var date: LocalDate { dateTime.date }
    /// The time part.
    public var time: LocalTime { dateTime.time }
    /// The time zone.
    public var zone: Zone
    /// The specific zone offset for this date and time in ``zone``.
    public var offset: ZoneOffset

    internal init(dateTime: LocalDateTime, zone: Zone, offset: ZoneOffset) {
      self.dateTime = dateTime
      self.zone = zone
      self.offset = offset
    }

    /// Initializes an instance of ``Tempo/ZonedDateTime`` with the specified date and time
    /// in the specified time zone.
    ///
    /// - Parameters:
    ///   - dateTime: The date and time to use.
    ///   - zone: The time zone to use.
    ///   - resolving: The resolution strategy to use when converting the date and time.
    ///   - calendarSystem: The calendar system to use.
    /// - Throws: A ``Tempo/Error`` if the conversion fails due to an unresolvable local-time.
    ///
    public init(
      dateTime: LocalDateTime,
      zone: Zone,
      resolving: ResolutionStrategy.Options = [],
      in calendarSystem: CalendarSystem = .default
    ) throws {
      if let fixedOffset = zone.fixedOffset {
        self.init(dateTime: dateTime, zone: zone, offset: fixedOffset)
      } else {
        let dateTimeZone = dateTime.union(with: .zoneId(zone.identifier))
        self = try calendarSystem.resolve(components: dateTimeZone, resolution: resolving.strategy)
      }
    }

    /// Initializes an instance of ``Tempo/ZonedDateTime`` with the specified date and time
    /// in the specified fixed offset time zone.
    ///
    /// - Parameters:
    ///   - dateTime: The date and time to use.
    ///   - zoneOffset: The time zone to use.
    ///
    public init(dateTime: LocalDateTime, zoneOffset: ZoneOffset) {
      self.init(dateTime: dateTime, zone: .fixed(offset: zoneOffset), offset: zoneOffset)
    }

    /// Initializes an instance of ``Tempo/ZonedDateTime`` with the specified date and time components
    /// in the specified time zone.
    ///
    /// - Parameters:
    ///   - year: The year component of the date.
    ///   - month: The month component of the date.
    ///   - day: The day component of the date.
    ///   - hour: The hour component of the time.
    ///   - minute: The minute component of the time.
    ///   - second: The second component of the time.
    ///   - nanosecond: The nanosecond component of the time.
    ///   - zone: The time zone to use.
    ///   - calendarSystem: The calendar system to use.
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
      zone: Zone,
      in calendarSystem: CalendarSystem = .default
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
        zone: zone,
        in: calendarSystem
      )
    }

    /// Creates a new instance of ``Tempo/ZonedDateTime`` with one or more of the date, time or zone parts
    /// modified.
    ///
    /// - Note: Modifying the `zone` part using this function will anchor to the same local-time. If
    ///    you want to preserve the same instant, use the `withZone(_:anchor:)` method instead,
    ///    passing `.sameInstant` as the anchor.
    ///
    /// - Parameters:
    ///   - date: The new date to set. If `nil`, the current date is used.
    ///   - time: The new time to set. If `nil`, the current time is used.
    ///   - zone: The new time zone to set, anchoring to the local-time. If `nil`, the current time zone offset is used.
    ///   - resolving: The resolution strategy to use when converting the date and time.
    ///   - calendarSystem: The calendar system to use.
    /// - Returns: A new instance of ``Tempo/ZonedDateTime`` with the specified parts modified.
    /// - Throws: A ``Tempo/Error`` if the conversion fails due to an unresolvable local-time.
    ///
    public func with(
      date: LocalDate? = nil,
      time: LocalTime? = nil,
      zone: Zone? = nil,
      resolving: ResolutionStrategy.Options = [],
      in calendarSystem: CalendarSystem = .default
    ) throws -> Self {
      let dateTime = dateTime.with(date: date ?? self.date, time: time ?? self.time)
      return try Self(
        dateTime: dateTime,
        zone: zone ?? self.zone,
        resolving: resolving,
        in: calendarSystem
      )
    }

    /// Creates a new instance of ``Tempo/ZonedDateTime`` with one or components of the date and time
    /// or the zone part modified.
    ///
    /// - Note: Modifying the `zone` part using this function will anchor to the same local-time. If
    ///    you want to preserve the same instant, use the `withZone(_:anchor:)` method instead,
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
    ///   - zone: The new time zone to set, anchoring to the local-time. If `nil`, the current time zone is used.
    ///   - resolving: The resolution strategy to use when converting the date and time
    ///   - calendarSystem: The calendar system to use.
    /// - Returns: A new instance of ``Tempo/ZonedDateTime`` with the specified parts modified.
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
      zone: Zone? = nil,
      resolving: ResolutionStrategy.Options = [],
      in calendarSystem: CalendarSystem = .default
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
        zone: zone ?? self.zone,
        resolving: resolving,
        in: calendarSystem
      )
    }

    /// Creates a new instance of ``ZonedDateTime`` in the specified time zone.
    ///
    /// - Parameters:
    ///   - zone: The time zone to use.
    ///   - anchor: The ``Tempo/AdjustmentAnchor`` that determines whether the
    ///   instant or local-time the is preserved. Defaults to ``Tempo/AdjustmentAnchor/sameInstant``.
    ///   - resolving: The resolution strategy to use when converting the date and time
    ///   - calendarSystem: The calendar system to use.
    /// - Returns: A new instance of ``ZonedDateTime`` in the specified time zone.
    /// - Throws: A ``Tempo/Error`` if the conversion fails due to an unresolvable local-time.
    ///
    public func withZone(
      _ zone: Zone,
      anchor: AdjustmentAnchor = .sameInstant,
      resolving: ResolutionStrategy.Options = [],
      in calendarSystem: CalendarSystem = .default
    ) throws -> Self {
      switch anchor {
      case .sameLocalTime:
        return try with(zone: zone, resolving: resolving)
      case .sameInstant:
        let instant = try calendarSystem.instant(from: self, resolution: resolving.strategy)
        return calendarSystem.components(from: instant, in: zone)
      }
    }

    /// Creates a new instance of ``ZonedDateTime`` sourced from a provided ``Tempo/Clock``.
    ///
    /// - Parameters:
    ///   - clock: The clock to use. Defaults to ``Tempo/Clock/system``.
    ///   - calendarSystem: The calendar system to use.
    /// - Returns: A new instance of ``ZonedDateTime`` sourced from the provided `clock`.
    ///
    public static func now(clock: some Clock = .system, in calendarSystem: CalendarSystem = .default) -> Self {
      return calendarSystem.components(from: clock.instant, in: clock.zone)
    }
  }

}

extension Tempo.ZonedDateTime: Sendable {}
extension Tempo.ZonedDateTime: Hashable {}
extension Tempo.ZonedDateTime: Equatable {}

extension Tempo.ZonedDateTime: CustomStringConvertible {

  public var description: String {
    let dateTimeField = "\(dateTime)"
    let offsetField =
      offset == .zero
      ? "Z"
      : "\(offset)"
    let zoneField =
      if !zone.isFixed {
        "[\(zone.identifier)]"
      } else {
        ""
      }
    return "\(dateTimeField) \(offsetField) \(zoneField)"
  }
}

extension Tempo.ZonedDateTime: Tempo.LinkedComponentContainer, Tempo.ComponentBuildable {

  public static let links: [any Tempo.ComponentLink<Self>] = [
    Tempo.ComponentKeyPathLink(.year, to: \.dateTime.date.year),
    Tempo.ComponentKeyPathLink(.monthOfYear, to: \.dateTime.date.month),
    Tempo.ComponentKeyPathLink(.dayOfMonth, to: \.dateTime.date.day),
    Tempo.ComponentKeyPathLink(.hourOfDay, to: \.dateTime.time.hour),
    Tempo.ComponentKeyPathLink(.minuteOfHour, to: \.dateTime.time.minute),
    Tempo.ComponentKeyPathLink(.secondOfMinute, to: \.dateTime.time.second),
    Tempo.ComponentKeyPathLink(.nanosecondOfSecond, to: \.dateTime.time.nanosecond),
    Tempo.ComponentKeyPathLink(.zoneOffset, to: \.offset.totalSeconds),
    Tempo.ComponentKeyPathLink(.zoneId, to: \.zone.identifier),
  ]

  public init(components: some Tempo.ComponentContainer) {
    self.init(
      dateTime: Tempo.LocalDateTime(components: components),
      zone: Tempo.Zone(components: components),
      offset: Tempo.ZoneOffset(components: components),
    )
  }

}

extension Tempo.ZonedDateTime {

  // MARK: Mathemtical Operations

  public mutating func add(_ duration: Duration) throws {
    // TODO: do something
  }

  public func adding(_ duration: Duration) throws -> Self {
    var result = self
    try result.add(duration)
    return result
  }

}
