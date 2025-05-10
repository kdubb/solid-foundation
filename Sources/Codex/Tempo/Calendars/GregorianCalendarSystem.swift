//
//  GregorianSystem.swift
//  Codex
//
//  Created by Kevin Wooten on 4/29/25.
//

extension Tempo {

  /// Implementation of Gregorian style calendar systems, including variants.
  ///
  /// - Note: Tempo uses the ``Tempo/GregorianSystem/Variant/iso8601``
  /// variant by default for all date/time calculations. This is for its locale independence
  /// and use in data exchange.
  ///
  public struct GregorianCalendarSystem: CalendarSystem, Sendable {

    private enum Constants {
      // Number of days in a 400 year cycle (365*400 + 97 leap days)
      static let daysPer400Years = 146097
      // Number of days in a 100 year cycle (365*100 + 24 leap days)
      static let daysPer100Years = 36524
      // Number of days in a 4 year cycle (365*4 + 1 leap day)
      static let daysPer4Years = 1461
      // Number of days to shift from 0000-03-01 to 1970-01-01
      static let daysFrom0000ToEpoch = 719468
      // Number of days in a non-leap year
      static let daysPerYear = 365
      // Number of days in a non-leap year
      static let daysInMarchBasedYear = 365
    }

    public static let iso8601 = GregorianCalendarSystem(variant: .iso8601)
    public static let gregorian = GregorianCalendarSystem(variant: .none)
    public static let system = iso8601

    /// Variants of the Gregorian calendar system.
    public enum Variant: Sendable {
      /// No variant, uses the default Gregorian calendar.
      case none
      /// ISO 8601 variant, which is the **default**.
      case iso8601
    }

    private let variant: Variant

    public init(variant: Variant = .iso8601) {
      self.variant = variant
    }

    /// Returns the number of days in the given month of the given year.
    ///
    /// - Parameters:
    ///   - year: The year.
    ///   - month: The month (1 based).
    /// - Returns: The number of days in the month.
    ///
    public func daysInMonth(year: Int, month: Int) -> Int {
      switch month {
      case 1, 3, 5, 7, 8, 10, 12:
        return 31
      case 4, 6, 9, 11:
        return 30
      case 2:
        return isLeapYear(year) ? 29 : 28
      default:
        fatalError("Invalid month: \(month)")
      }
    }

    /// Returns whether the given year is a leap year.
    ///
    /// - Parameter year: The year.
    /// - Returns: Whether the year is a leap year.
    ///
    public func isLeapYear(_ year: Int) -> Bool {
      return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
    }

    /// Returns the number of days in the given year.
    ///
    /// - Parameter year: The year.
    /// - Returns: The number of days in the year.
    ///
    public func daysInYear(_ year: Int) -> Int {
      return isLeapYear(year) ? 366 : 365
    }

    public func components<C>(
      from instant: Instant,
      in zone: Zone,
      as type: C.Type = C.self
    ) -> C where C: ComponentBuildable {

      let offset = zone.offset(at: instant)
      let shifted = instant.durationSinceEpoch + Duration(offset)

      // Split shifted days/time
      let days = shifted.value(for: .numberOfDays)
      let date = localDate(daysSinceEpoch: days)

      let hour = shifted.value(for: .hoursOfDay)
      let minute = shifted.value(for: .minutesOfHour)
      let second = shifted.value(for: .secondsOfMinute)
      let nano = shifted.value(for: .nanosecondsOfSecond)

      var bag = ComponentArray()
      bag.setValue(date.year, for: .year)
      bag.setValue(date.month, for: .month)
      bag.setValue(date.day, for: .day)
      bag.setValue(hour, for: .hour)
      bag.setValue(minute, for: .minute)
      bag.setValue(second, for: .second)
      if nano != 0 { bag.setValue(nano, for: .nanosecond) }

      bag.setValue(offset.totalSeconds, for: .zoneOffset)
      bag.setValue(zone.identifier, for: .zoneId)

      return C(components: bag)
    }

    public func resolve<C, S>(
      components: S,
      resolution: ResolutionStrategy
    ) -> C where S: ComponentContainer, C: ComponentBuildable {

      let instant = self.instant(from: components, resolution: resolution)

      if let zoneId = components.valueIfPresent(for: .zoneId) {
        let zone = Zone(valid: zoneId)
        return self.components(from: instant, in: zone)
      } else if let zoneOffset = components.valueIfPresent(for: .zoneOffset) {
        let zone = Zone(offset: ZoneOffset(valid: zoneOffset))
        return self.components(from: instant, in: zone)
      } else {
        return self.components(from: instant, in: Zone.utc)
      }
    }

    internal func compute<C, S>(
      _ component: C,
      from components: S,
    ) -> C.Value where C: Tempo.DateTimeComponent, C.Value == Int, S: Tempo.ComponentContainer {
      switch component.id {
      case .year, .monthOfYear, .dayOfMonth,
        .hourOfDay, .minuteOfHour, .secondOfMinute, .nanosecondOfSecond:
        return components.valueIfPresent(for: component) ?? 0

      case .weekOfYear:
        return variant.computeWeekOfYear(for: components, in: self)

      case .weekOfMonth:
        return variant.computeWeekOfMonth(for: components, in: self)

      case .dayOfYear:
        let year = components.value(for: .year)
        let month = components.value(for: .month)
        let day = components.value(for: .day)
        var total = day
        for m in 1..<month {
          total += daysInMonth(year: year, month: m)
        }
        return total

      case .dayOfWeek:
        return variant.computeDayOfWeek(for: components, in: self)

      case .dayOfWeekForMonth:
        let day = components.value(for: .day)
        return (day - 1) / 7 + 1

      case .yearForWeekOfYear:
        return variant.computeYearForWeekOfYear(for: components, in: self)

      default:
        fatalError("Unsupported component: \(component)")
      }
    }

    internal func compute<C, S>(
      _ component: C,
      from components: S,
    ) -> C.Value where C: Tempo.DateTimeComponent, C.Value == Int128, S: Tempo.ComponentContainer {
      switch component.id {
      case .durationSinceEpoch:
        return components.valueIfPresent(for: component) ?? 0
      default:
        fatalError("Unsupported component: \(component)")
      }
    }

    internal func compute<C, S>(
      _ component: C,
      from components: S,
    ) -> C.Value where C: Tempo.DateTimeComponent, C.Value == Bool, S: Tempo.ComponentContainer {
      switch component.id {
      case .isLeapMonth:
        return false
      default:
        fatalError("Unsupported component: \(component)")
      }
    }

    internal func compute<C, S>(
      _ component: C,
      from components: S,
    ) -> C.Value where C: Tempo.DateTimeComponent, C.Value == String, S: Tempo.ComponentContainer {
      switch component.id {
      case .zoneId:
        return components.valueIfPresent(for: component) ?? "UTC"
      default:
        fatalError("Unsupported component: \(component)")
      }
    }

    internal func compute<C, S>(
      _ component: C,
      from components: S,
    ) -> C.Value where C: Tempo.DateTimeComponent, S: Tempo.ComponentContainer {
      fatalError("Unsupported component: \(component)")
    }

    public func resolve<C, S>(
      _ component: C,
      from components: S,
      resolution: Tempo.ResolutionStrategy
    ) throws -> C.Value where C: Tempo.DateTimeComponent, S: Tempo.ComponentContainer {

      if let value = components.valueIfPresent(for: component) {
        return value
      }

      let resolved: ComponentArray = resolve(components: components, resolution: resolution)

      return compute(component, from: resolved)
    }

    public func instant(
      from comps: some ComponentContainer,
      resolution: ResolutionStrategy
    ) -> Instant {

      let year = comps.valueIfPresent(for: .year) ?? 0
      let month = comps.valueIfPresent(for: .month) ?? 0
      let day = comps.valueIfPresent(for: .day) ?? 0
      let hour = comps.valueIfPresent(for: .hour) ?? 0
      let minute = comps.valueIfPresent(for: .minute) ?? 0
      let second = comps.valueIfPresent(for: .second) ?? 0
      let nano = comps.valueIfPresent(for: .nanosecond) ?? 0

      let zone: Zone
      if let id = comps.valueIfPresent(for: .zoneId) {
        zone = Zone(valid: id)
      } else if let off = comps.valueIfPresent(for: .zoneOffset) {
        zone = Zone(offset: ZoneOffset(valid: off))
      } else {
        zone = .utc
      }

      // Convert YMD → daysSinceEpoch
      let days = computeDaysSinceEpoch(year: year, month: month, day: day)

      var instant = Instant(
        durationSinceEpoch: .days(days) + .hours(hour) + .minutes(minute) + .seconds(second) + .nanoseconds(nano)
      )

      // Subtract zone offset (convert local → UTC)
      instant -= Duration(zone.offset(at: instant))

      return instant
    }

    public func nearestInstant(from comps: some ComponentContainer) -> Instant {
      return instant(from: comps, resolution: .default)
    }

    public func range<C>(
      of component: C,
      at instant: Instant
    ) -> Range<C.Value> where C: DateTimeComponent, C.Value: FixedWidthInteger {
      switch component.id {
      case .year, .yearForWeekOfYear:
        return C.Value.min..<C.Value.max
      case .monthOfYear:
        return 1..<13
      case .dayOfMonth:
        let date = localDate(instant: instant)
        return C.Value(1)..<C.Value(daysInMonth(year: date.year, month: date.month) + 1)
      case .dayOfWeek:
        return 1..<8
      case .dayOfYear:
        let date = localDate(instant: instant)
        return C.Value(1)..<C.Value(daysInYear(date.year) + 1)
      case .hourOfDay:
        return 0..<24
      case .minuteOfHour, .secondOfMinute:
        return 0..<60
      case .nanosecondOfSecond:
        return 0..<1_000_000_000
      default:
        fatalError("Range not implemented for component: \(component)")
      }
    }

    /// Computes the (year, month, day) in the proleptic Gregorian calendar
    /// for the *UTC* instant adjusted by `offset`.
    ///
    /// - Parameters:
    ///   - instant: The UTC instant.
    ///   - offset:  The fixed offset to apply *before* extracting
    ///   civil fields (e.g. the zone’s standard offset).
    /// - Returns: The (year, month, day) in the proleptic Gregorian calendar.
    ///
    public func localDate(
      instant: Instant,
      offset: ZoneOffset = .utc,
    ) -> LocalDate {

      let shifted = instant + Duration(offset)
      let daysSinceEpoch = shifted.value(for: .numberOfDays)
      return localDate(daysSinceEpoch: daysSinceEpoch)
    }

    /// Converts a number of days since 1970-01-01 (Unix epoch)
    /// into the year, month, and day in the proleptic Gregorian calendar.
    ///
    /// - Parameter daysSinceEpoch: The number of days since 1970-01-01 (Unix epoch).
    /// - Returns: A tuple containing the year, month (1 based), and day (1 based).
    ///
    public func localDate(daysSinceEpoch: Int) -> LocalDate {
      let days = daysSinceEpoch + Constants.daysFrom0000ToEpoch

      let era = (days >= 0 ? days : days - Constants.daysPer400Years + 1) / Constants.daysPer400Years
      let dayOfEra = days - era * Constants.daysPer400Years

      let yearOfEra =
        (dayOfEra - dayOfEra / Constants.daysPer4Years
          + dayOfEra / Constants.daysPer100Years
          - dayOfEra / Constants.daysPer400Years) / Constants.daysPerYear
      let year = yearOfEra + era * 400

      let dayOfYear =
        dayOfEra
        - (Constants.daysPerYear * yearOfEra
          + yearOfEra / 4
          - yearOfEra / 100
          + yearOfEra / 400)

      let marchBasedMonth = (5 * dayOfYear + 2) / 153
      let day = dayOfYear - (153 * marchBasedMonth + 2) / 5 + 1
      let month = (marchBasedMonth + 2) % 12 + 1
      let finalYear = year + (marchBasedMonth / 10)

      return LocalDate(valid: (year: finalYear, month: month, day: day))
    }

    private func computeDaysSinceEpoch(date: LocalDate) -> Int {
      return computeDaysSinceEpoch(
        year: date.year,
        month: date.month,
        day: date.day
      )
    }

    /// Converts a Gregorian calendar date to the number of days since 1970-01-01 (Unix epoch).
    private func computeDaysSinceEpoch(year: Int, month: Int, day: Int) -> Int {
      let adjustedYear = month <= 2 ? year - 1 : year
      let adjustedMonth = month <= 2 ? month + 12 : month

      let era = adjustedYear / 400
      let yearOfEra = adjustedYear - era * 400

      let dayOfYear = (153 * (adjustedMonth - 3) + 2) / 5 + day - 1
      let dayOfEra =
        yearOfEra * Constants.daysPerYear
        + yearOfEra / 4
        - yearOfEra / 100
        + yearOfEra / 400
        + dayOfYear

      return era * Constants.daysPer400Years + dayOfEra - Constants.daysFrom0000ToEpoch
    }
  }
}

extension Tempo.CalendarSystem where Self == Tempo.GregorianCalendarSystem {

  // Common variants
  public static var iso8601: Self { Tempo.GregorianCalendarSystem.iso8601 }
  public static var gregorian: Self { Tempo.GregorianCalendarSystem.gregorian }

}

extension Tempo.GregorianCalendarSystem.Variant {

  func computeWeekOfYear(
    for components: some Tempo.ComponentContainer,
    in calendar: Tempo.GregorianCalendarSystem
  ) -> Int {
    let year = components.value(for: .year)
    let month = components.value(for: .month)
    let day = components.value(for: .day)

    switch self {
    case .none:
      let doy = calendar.compute(.dayOfYear, from: components)
      let dow = calendar.compute(.dayOfWeek, from: components)
      return (doy - dow + 7) / 7 + 1
    case .iso8601:
      let days = calendar.computeDaysSinceEpoch(year: year, month: month, day: day)
      let jan4 = calendar.computeDaysSinceEpoch(year: year, month: 1, day: 4)
      let jan4Weekday = ((jan4 + 3) % 7 + 7) % 7
      let weekStart = jan4 - jan4Weekday
      return (days - weekStart) / 7 + 1
    }
  }

  func computeWeekOfMonth(
    for components: some Tempo.ComponentContainer,
    in calendar: Tempo.GregorianCalendarSystem
  ) -> Int {
    let day = components.value(for: .day)
    let weekday = calendar.compute(.dayOfWeek, from: components)
    switch self {
    case .none:
      return (day + weekday - 2) / 7 + 1
    case .iso8601:
      return (day + weekday - 2) / 7 + 1
    }
  }

  func computeDayOfWeek(
    for components: some Tempo.ComponentContainer,
    in calendar: Tempo.GregorianCalendarSystem
  ) -> Int {
    let year = components.value(for: .year)
    let month = components.value(for: .month)
    let day = components.value(for: .day)
    let days = calendar.computeDaysSinceEpoch(year: year, month: month, day: day)

    switch self {
    case .none:
      // Sunday = 1 ... Saturday = 7
      return ((days + 4) % 7 + 7) % 7 + 1
    case .iso8601:
      // Monday = 1 ... Sunday = 7
      return ((days + 3) % 7 + 7) % 7 + 1
    }
  }

  func computeYearForWeekOfYear(
    for components: some Tempo.ComponentContainer,
    in calendar: Tempo.GregorianCalendarSystem
  ) -> Int {
    switch self {
    case .none:
      return components.value(for: .year)
    case .iso8601:
      let week = computeWeekOfYear(for: components, in: calendar)
      let month = components.value(for: .month)
      let year = components.value(for: .year)
      if week == 1 && month == 12 {
        return year + 1
      } else if week >= 52 && month == 1 {
        return year - 1
      } else {
        return year
      }
    }
  }
}
