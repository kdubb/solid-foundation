//
//  GregorianSystem.swift
//  Codex
//
//  Created by Kevin Wooten on 4/29/25.
//

import SolidCore


/// Implementation of Gregorian style calendar systems, including variants.
///
/// - Note: Tempo uses the ``GregorianCalendarSystem/Variant/iso8601``
/// variant by default for all date/time calculations. This is for its locale independence
/// and use in data exchange.
///
public struct GregorianCalendarSystem: CalendarSystem, Sendable {

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

  internal let variant: Variant

  /// Initializes a Gregorian calendar system with a specific variant.
  ///
  /// - Parameter variant: The variant of the Gregorian calendar.
  ///
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

  /// Computes a set of components for the given `Instant` in the specified time zone.
  ///
  /// - Parameters:
  ///   - instant: The instant to convert.
  ///   - zone: The time zone of instant.
  ///   - type: The type of container to convert to.
  /// - Returns: A set of components representing the instant in the specified time zone.
  ///
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
    bag.setValue(date.month, for: .monthOfYear)
    bag.setValue(date.day, for: .dayOfMonth)
    bag.setValue(hour, for: .hourOfDay)
    bag.setValue(minute, for: .minuteOfHour)
    bag.setValue(second, for: .secondOfMinute)
    bag.setValue(nano, for: .nanosecondOfSecond)
    bag.setValue(offset.totalSeconds, for: .zoneOffset)
    bag.setValue(zone.identifier, for: .zoneId)

    // Add missing required components
    for componentId in C.requiredComponentIds.subtracting(bag.availableComponentIds) {
      guard let component = componentId.component as? any DateTimeComponent else {
        fatalError("Only date/time components can be required by builders.")
      }
      let value = try! self.component(component, from: bag, resolution: .default)
      bag.setValue(value, for: component)
    }

    return C(components: bag)
  }

  /// Resolves the given components to a valid set of equivalent components.
  ///
  /// - Parameters:
  ///   - components: The components to resolve.
  ///   - resolution: The resolution strategy to use.
  /// - Returns: A valid set of components.
  /// - Throws: A ``TempoError`` if the components cannot be resolved.
  ///
  public func resolve<C, S>(
    components: S,
    resolution: ResolutionStrategy
  ) throws -> C where S: ComponentContainer, C: ComponentBuildable {

    guard let zoneId = components.valueIfPresent(for: .zoneId) else {
      // Components either has a zone offset or neither
      // (defaulting to UTC)... so components are valid
      return C(components: components)
    }

    let zone = Zone(availableComponents: [.zoneId(zoneId)])
    let dateTime = LocalDateTime(availableComponents: components)
    let offsets = zone.rules.validOffsets(for: dateTime)

    switch offsets {

    case .normal(let offset):
      return C(components: dateTime.union(with: [.zoneId(zoneId), .zoneOffset(offset.totalSeconds)]))

    case .ambiguous(let offsets):
      let offset: ZoneOffset
      switch resolution.ambiguousLocalTime {
      case .earliest:
        offset = offsets[offsets.startIndex]
      case .latest:
        offset = offsets[offsets.endIndex - 1]
      case .reject:
        throw TempoError.ambiguousTimeResolutionFailed(reason: .rejectedByStrategy)
      }
      return C(components: dateTime.union(with: [.zoneId(zoneId), .zoneOffset(offset.totalSeconds)]))

    case .skipped(let transition):
      let instant =
        switch resolution.skippedLocalTime {
        case .nextValid:
          Instant(durationSinceEpoch: dateTime.durationSinceEpoch) + transition.duration
        case .previousValid:
          Instant(durationSinceEpoch: dateTime.durationSinceEpoch) - transition.duration
        case .boundary(.start):
          transition.instant
        case .boundary(.end):
          transition.instant + transition.duration
        case .boundary(.nearest):
          Instant(durationSinceEpoch: dateTime.durationSinceEpoch) < (transition.instant + transition.duration / 2)
            ? transition.instant
            : transition.instant + transition.duration
        case .reject:
          throw TempoError.skippedTimeResolutionFailed(reason: .rejectedByStrategy)
        }
      return self.components(from: instant, in: zone)
    }
  }

  /// Looks up or computes the a requested component from a set of components.
  ///
  /// - Parameters:
  ///   - component: The component to resolve.
  ///   - components: The set of components to resolve from.
  ///   - resolution: The resolution strategy to use.
  /// - Returns: The resolved component value.
  /// - Throws: A ``TempoError`` if the component cannot be resolved.
  ///
  public func component<C, S>(
    _ component: C,
    from components: S,
    resolution: ResolutionStrategy
  ) throws -> C.Value where C: DateTimeComponent, S: ComponentContainer {

    if let value = components.valueIfPresent(for: component) {
      return value
    }

    let resolved: ComponentArray = try resolve(components: components, resolution: resolution)

    return compute(component, from: resolved)
  }

  /// Computes the value of the specified integer date/time component from the given components.
  internal func compute<C, S>(
    _ component: C,
    from components: S,
  ) -> C.Value where C: IntegerDateTimeComponent, S: ComponentContainer {
    switch component.id {

    case .year, .hourOfDay, .minuteOfHour, .secondOfMinute, .nanosecondOfSecond:
      return components.valueIfPresent(for: component) ?? 0

    case .monthOfYear, .dayOfMonth:
      return components.valueIfPresent(for: component) ?? 1

    case .weekOfYear:
      return C.Value(weekOfYear(for: components))

    case .weekOfMonth:
      return C.Value(weekOfMonth(for: components))

    case .dayOfYear:
      let year = components.valueIfPresent(for: .year) ?? 0
      let month = components.valueIfPresent(for: .monthOfYear) ?? 1
      let day = components.valueIfPresent(for: .dayOfMonth) ?? 1
      var total = day
      for m in 1..<month {
        total += daysInMonth(year: year, month: m)
      }
      return C.Value(total)

    case .dayOfWeek:
      return C.Value(dayOfWeek(for: components))

    case .dayOfWeekForMonth:
      let day = components.valueIfPresent(for: .dayOfMonth) ?? 1
      return C.Value((day - 1) / 7 + 1)

    case .yearForWeekOfYear:
      return C.Value(yearForWeekOfYear(for: components))

    case .zoneOffset:
      if let offset = components.valueIfPresent(for: .zoneOffset) {
        return C.Value(offset)
      } else if let zoneId = components.valueIfPresent(for: .zoneId) {
        let zone = Zone(availableComponents: [.zoneId(zoneId)])
        let instant = try! self.instant(from: components, resolution: .default)
        return C.Value(zone.offset(at: instant).totalSeconds)
      } else {
        return C.Value(0)
      }

    default:
      fatalError("Unsupported component: \(component)")
    }
  }

  /// Computes the value of the specified boolean date/time component from the given components.
  internal func compute<C, S>(
    _ component: C,
    from components: S,
  ) -> C.Value where C: DateTimeComponent, C.Value == Bool, S: ComponentContainer {
    switch component.id {
    case .isLeapMonth:
      return false
    default:
      fatalError("Unsupported component: \(component)")
    }
  }

  /// Computes the value of the specified string date/time component from the given components.
  internal func compute<C, S>(
    _ component: C,
    from components: S,
  ) -> C.Value where C: DateTimeComponent, C.Value == String, S: ComponentContainer {
    switch component.id {
    case .zoneId:
      return components.valueIfPresent(for: component) ?? "UTC"
    default:
      fatalError("Unsupported component: \(component)")
    }
  }

  /// Default implementation for computing date/time components that fails.
  ///
  /// This is a fallback for the generic system and shouldn't be called directly. Nor
  /// should it ever get called indirectly since all date/time components should have
  /// specialized implementations.
  ///
  internal func compute<C, S>(
    _ component: C,
    from components: S,
  ) -> C.Value where C: DateTimeComponent, S: ComponentContainer {
    fatalError("Unsupported component: \(component)")
  }

  /// Computes the corresponding `Instant` for the specified components.
  ///
  /// - Parameters:
  ///   - components: The components to convert.
  ///   - resolution: The resolution strategy to use.
  /// - Returns: The instant corresponding to the components.
  /// - Throws: A ``TempoError`` if the components instant cannot be computed.
  ///
  public func instant(
    from components: some ComponentContainer,
    resolution: ResolutionStrategy
  ) throws -> Instant {

    let avail = components.availableComponentIds
    let dateTime = LocalDateTime(availableComponents: components)
    let instant = Instant(durationSinceEpoch: dateTime.durationSinceEpoch)

    if avail.contains(.zoneId) {

      // Resolve the date/time in the specified zone

      let zone = Zone(availableComponents: components)

      // If the zone has a fixed offset, apply it directly
      if let fixedOffset = zone.fixedOffset {

        return instant - .seconds(fixedOffset.totalSeconds)
      }
      // If the components have a specific zone offset, validate & apply it
      else if avail.contains(.zoneOffset) {

        let zoneOffset = ZoneOffset(availableComponents: components)

        guard zone.rules.isValidOffset(zoneOffset, for: dateTime) else {
          throw TempoError.invalidComponentValue(
            component: "zoneOffset",
            reason: .invalidZoneId(id: "\(zoneOffset)")
          )
        }

        return instant + .seconds(zoneOffset.totalSeconds)
      }

      // Otherwise, we need to resolve the date time using offsets from the
      let offsets = zone.rules.validOffsets(for: dateTime)
      return try offsets.apply(resolution: resolution, to: instant)

    } else if let off = components.valueIfPresent(for: .zoneOffset) {
      // Apply fixed offsets directly
      return instant + .seconds(off)
    } else {
      // Imply UTC, no offset
      return instant
    }
  }

  /// Computes the corresponding `Instant` for the specified components using a specific zone offset.
  ///
  /// - Parameters:
  ///   - dateTime: The date/time to convert.
  ///   - offset: The zone offset to use for the computation.
  /// - Returns: The instant corresponding to the date/time at the specified offset.
  ///
  public func instant(from dateTime: some DateTime, at offset: ZoneOffset) -> Instant {

    return Instant(durationSinceEpoch: dateTime.durationSinceEpoch) - .seconds(offset.totalSeconds)
  }

  /// Determines the valid range of values for the specified component at a given instant.
  ///
  /// - Parameters:
  ///   - component: The component to determine the range for.
  ///   - instant: The instant to determine the valid range at.
  /// - Returns: A range of valid values for the specified component at the given instant.
  ///
  public func range<C>(
    of component: C,
    at instant: Instant
  ) -> Range<C.Value> where C: IntegerDateTimeComponent {

    switch component.id {

    case .dayOfMonth:
      let date = localDate(instant: instant, at: .zero)
      return C.Value(1)..<C.Value(daysInMonth(year: date.year, month: date.month) + 1)

    case .dayOfYear:
      let date = localDate(instant: instant, at: .zero)
      return C.Value(1)..<C.Value(daysInYear(date.year) + 1)

    case .weekOfYear:
      let date = localDate(instant: instant, at: .zero)
      let weekCount = weekOfYear(for: LocalDateTime(date: date, time: .midnight))
      // If the week for Jan-1 is 52, the year has 52 weeks, else 53
      let max = weekCount == 52 && date.month == 12 ? 52 : 53
      return C.Value(1)..<C.Value(max + 1)

    case .weekOfMonth:
      let date = localDate(instant: instant, at: .zero)
      let weekdayOfFirst = dayOfWeek(
        for: LocalDateTime(date: LocalDate(valid: (date.year, date.month, 1)), time: .midnight)
      )
      // weeks spanned = ceil((weekdayOfFirst-1 + daysInMonth)/7)
      let weeksInMonth =
        (weekdayOfFirst - 1
          + daysInMonth(
            year: date.year,
            month: date.month
          ) + 6) / 7
      return C.Value(1)..<C.Value(weeksInMonth + 1)

    default:
      return component.range.lowerBound..<(component.range.upperBound + 1)
    }
  }

  /// Adds the date/time components in `addition` to the components in `base`, returning the resulting components.
  ///
  /// This method resolves the original components to an `Instant`, applies period and duration components from `addition`,
  /// and then resolves the result back to components using the original's zone if present.
  ///
  /// - Parameters:
  ///   - addition: The components to add.
  ///   - base: The components to add to.
  ///   - resolution: The resolution strategy to use.
  /// - Returns: The resulting components after addition.
  /// - Throws: A ``TempoError`` if the addition cannot be performed.
  ///
  public func adding<C>(
    components addition: some ComponentContainer,
    to base: C,
    resolution: ResolutionStrategy = .default
  ) throws -> C where C: ComponentContainer & ComponentBuildable {

    let baseInstant = try self.instant(from: base, resolution: resolution)
    var resultInstant = baseInstant

    // Determine target zone for conversion
    let zone: Zone
    if let zoneId = base.valueIfPresent(for: .zoneId) {
      zone = Zone(availableComponents: [.zoneId(zoneId)])
    } else if let offset = base.valueIfPresent(for: .zoneOffset) {
      zone = Zone(offset: ZoneOffset(availableComponents: [.zoneOffset(offset)]))
    } else {
      zone = .utc
    }

    // Apply period-based components (calendar-aware)
    let calendarYears = addition.valueIfPresent(for: .calendarYears) ?? 0
    let calendarMonths = addition.valueIfPresent(for: .calendarMonths) ?? 0
    let calendarWeeks = addition.valueIfPresent(for: .calendarWeeks) ?? 0
    let calendarDays = addition.valueIfPresent(for: .calendarDays) ?? 0

    if calendarYears != 0 || calendarMonths != 0 || calendarWeeks != 0 || calendarDays != 0 {
      // Extract base date
      let baseDateTime = components(from: baseInstant, in: zone, as: LocalDateTime.self)
      var year = baseDateTime.year
      var month = baseDateTime.month
      var day = baseDateTime.day

      year += calendarYears
      month += calendarMonths
      day += calendarWeeks * 7 + calendarDays

      // Normalize month overflow
      while month > 12 {
        year += 1
        month -= 12
      }
      while month < 1 {
        year -= 1
        month += 12
      }

      // Clamp day to valid range for resulting month/year
      let maxDay = daysInMonth(year: year, month: month)
      day = min(day, maxDay)

      // Recompute base instant with new date and original time components
      let newInstantBase = Instant(
        durationSinceEpoch: .days(daysSinceEpoch(year: year, month: month, day: day)) + .hours(baseDateTime.hour)
          + .minutes(baseDateTime.minute) + .seconds(baseDateTime.second) + .nanoseconds(baseDateTime.nanosecond)
      )
      resultInstant = newInstantBase
    }

    // Apply duration-based components
    if let days = addition.valueIfPresent(for: .numberOfDays) {
      resultInstant += .days(days)
    }
    if let hours = addition.valueIfPresent(for: .numberOfHours) {
      resultInstant += .hours(hours)
    }
    if let minutes = addition.valueIfPresent(for: .numberOfMinutes) {
      resultInstant += .minutes(minutes)
    }
    if let seconds = addition.valueIfPresent(for: .numberOfSeconds) {
      resultInstant += .seconds(seconds)
    }
    if let nanos = addition.valueIfPresent(for: .numberOfNanoseconds) {
      resultInstant += .nanoseconds(nanos)
    }

    return components(from: resultInstant, in: zone, as: C.self)
  }

  public func localDateTime(
    instant: Instant,
    at offset: ZoneOffset
  ) -> LocalDateTime {

    let shifted = instant.durationSinceEpoch + Duration(offset)
    let daysSinceEpoch = shifted.value(for: .numberOfDays)
    let localDate = localDate(daysSinceEpoch: daysSinceEpoch)
    let localTime = neverThrow(
      try LocalTime(
        hour: shifted.value(for: .hoursOfDay),
        minute: shifted.value(for: .minutesOfHour),
        second: shifted.value(for: .secondsOfMinute),
        nanosecond: shifted.value(for: .nanosecondsOfSecond)
      )
    )
    return LocalDateTime(date: localDate, time: localTime)
  }

  /// Computes the date (year, month, day) for the *UTC* instant adjusted by `offset`.
  ///
  /// - Parameters:
  ///   - instant: The UTC instant.
  ///   - offset:  The fixed offset to apply *before* extracting
  ///   civil fields (e.g. the zone’s standard offset).
  /// - Returns: The (year, month, day) in the proleptic Gregorian calendar.
  ///
  public func localDate(
    instant: Instant,
    at offset: ZoneOffset,
  ) -> LocalDate {

    let shifted = instant.durationSinceEpoch + Duration(offset)
    let daysSinceEpoch = shifted.value(for: .numberOfDays)
    return localDate(daysSinceEpoch: daysSinceEpoch)
  }

  /// Computes the date (year, month, day) for a number of days since the epoch.
  ///
  /// - Parameter daysSinceEpoch: The number of days since the epoch.
  /// - Returns: The corresponding date for the given number of days since the epoch.
  ///
  public func localDate(daysSinceEpoch: Int) -> LocalDate {
    let days = daysSinceEpoch + Consts.daysBetweenUnixEpochAndMarchZeroEpoch

    let era = (days >= 0 ? days : days - Consts.daysPerCycle + 1) / Consts.daysPerCycle
    let dayOfEra = days - era * Consts.daysPerCycle

    var yearOfEra = (Consts.yearsPerCycle * dayOfEra + Consts.dayOfEraBias) / Consts.daysPerCycle

    var startOfYear = yearOfEra * Consts.daysPerNonLeapYear
    startOfYear += yearOfEra / Consts.yearsPerLeapCycle
    startOfYear -= yearOfEra / Consts.yearsPerCentury
    startOfYear += yearOfEra / Consts.yearsPerCycle

    if startOfYear > dayOfEra {
      yearOfEra -= 1
      startOfYear = yearOfEra * Consts.daysPerNonLeapYear
      startOfYear += yearOfEra / Consts.yearsPerLeapCycle
      startOfYear -= yearOfEra / Consts.yearsPerCentury
      startOfYear += yearOfEra / Consts.yearsPerCycle
    }

    let year = yearOfEra + era * Consts.yearsPerCycle
    let dayOfYear = dayOfEra - startOfYear
    let marchBasedMonth = (5 * dayOfYear + 2) / Consts.daysIn5MarchMonths
    let day = dayOfYear - (Consts.daysIn5MarchMonths * marchBasedMonth + 2) / 5 + 1
    let month = (marchBasedMonth + 2) % 12 + 1
    let finalYear = year + (marchBasedMonth / 10)

    return LocalDate(valid: (year: finalYear, month: month, day: day))
  }

  /// Computes the date (year, month, day) for a given proleptic year and ordinal day.
  ///
  /// - Parameters:
  ///   - year: Proleptic year.
  ///   - ordinalDay: Ordinal day-of-year in range **1...365** (366 for leap years).
  /// - Returns: The corresponding date (year, month, day).
  /// - Throws: `Error.invalidComponentValue` if the ordinal is outside the valid
  /// range for that year.
  public func localDate(year: Int, ordinalDay: Int) throws -> LocalDate {

    let cumDays = isLeapYear(year) ? Consts.cumulativeDayOfLeapYearMonths : Consts.cumulativeDayOfStandardYearMonths
    let maxOrd = cumDays[12]
    guard ordinalDay >= 1 && ordinalDay <= maxOrd else {
      throw TempoError.invalidComponentValue(
        component: "ordinalDay",
        reason: .outOfRange(value: "\(ordinalDay)", range: "Invalid ordinal day for year '\(year)' (1...\(maxOrd))")
      )
    }

    // Find month by binary search or linear scan (12 elements)
    var month = 1
    while month <= 12 && ordinalDay > cumDays[month] { month += 1 }

    let day = ordinalDay - cumDays[month - 1]
    return LocalDate(valid: (year, month, day))
  }

  /// Computes the number of days between the epoch and a given date.
  public func daysSinceEpoch(date: LocalDate) -> Int {
    return daysSinceEpoch(
      year: date.year,
      month: date.month,
      day: date.day
    )
  }

  /// Computes the number of days between the epoch and the given date components.
  public func daysSinceEpoch(year: Int, month: Int, day: Int) -> Int {
    let adjustedYear = month <= 2 ? year - 1 : year
    let adjustedMonth = month <= 2 ? month + 12 : month

    let era = adjustedYear / Consts.yearsPerCycle
    let yearOfEra = adjustedYear - era * Consts.yearsPerCycle

    let dayOfYear = (Consts.daysIn5MarchMonths * (adjustedMonth - 3) + 2) / 5 + day - 1
    let dayOfEra =
      yearOfEra * Consts.daysPerNonLeapYear
      + yearOfEra / Consts.yearsPerLeapCycle
      - yearOfEra / Consts.yearsPerCentury
      + yearOfEra / Consts.yearsPerCycle
      + dayOfYear

    return era * Consts.daysPerCycle + dayOfEra - Consts.daysBetweenUnixEpochAndMarchZeroEpoch
  }

  public func weekOfYear(for components: some ComponentContainer) -> Int {
    return variant.weekOfYear(for: components, in: self)
  }

  public func weekOfMonth(for components: some ComponentContainer) -> Int {
    return variant.weekOfMonth(for: components, in: self)
  }

  public func dayOfWeek(for components: some ComponentContainer) -> Int {
    return variant.dayOfWeek(for: components, in: self)
  }

  public func yearForWeekOfYear(for components: some ComponentContainer) -> Int {
    return variant.yearForWeekOfYear(for: components, in: self)
  }

  // Constants used for Gregorian calculations
  enum Consts {

    /// The number of years in a full Gregorian calendar cycle.
    ///
    /// The Gregorian calendar repeats ever cycle (400 years).
    ///
    static let yearsPerCycle = 400

    /// The number of years in a Gregorian century.
    static let yearsPerCentury = 100

    /// The number of years that occur between leap years.
    static let yearsPerLeapCycle = 4

    /// Number of days in a standard (non-leap) year.
    static let daysPerNonLeapYear = 365

    /// Total number of days in a cycle.
    static let daysPerCycle = 146097

    /// Total number of days in a century.
    static let daysPerCentury = 36524
    /// Total number of days in a leap year cycle.
    static let daysPerLeapCycle = 1461
    /// Number of days to shift from Unix epoch (1970-01-01) to a March based year zero epoch (0000-03-01).
    ///
    /// Using a March based year is easier to compute than a January based year.
    ///   1. Leap days are the last day of the year.
    ///   2. Month lengths repeat 31, 30, 31....
    static let daysBetweenUnixEpochAndMarchZeroEpoch = 719468

    /// Bias constant for converting day of era to year of era.
    static let dayOfEraBias = 591

    /// Days in a 5 month span for a March based year.
    static let daysIn5MarchMonths = 153

    /// Cumulative day of year at the end of each month for leap years.
    static let cumulativeDayOfLeapYearMonths: [Int] = [
      0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366,
    ]
    /// Cumulative day of year at the end of each month, for standard years.
    static let cumulativeDayOfStandardYearMonths: [Int] = [
      0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365,
    ]
  }
}

extension CalendarSystem where Self == GregorianCalendarSystem {

  // Common variants
  public static var iso8601: Self { GregorianCalendarSystem.iso8601 }
  public static var gregorian: Self { GregorianCalendarSystem.gregorian }

}

extension GregorianCalendarSystem.Variant {

  internal func weekOfYear(
    for components: some ComponentContainer,
    in calendar: GregorianCalendarSystem
  ) -> Int {
    let year = components.valueIfPresent(for: .year) ?? 0
    let month = components.valueIfPresent(for: .monthOfYear) ?? 1
    let day = components.valueIfPresent(for: .dayOfMonth) ?? 1

    switch self {
    case .none:
      let doy = calendar.compute(.dayOfYear, from: components)
      let dow = calendar.compute(.dayOfWeek, from: components)
      return (doy + 6 - dow) / 7 + 1
    case .iso8601:
      let days = calendar.daysSinceEpoch(year: year, month: month, day: day)
      let jan4 = calendar.daysSinceEpoch(year: year, month: 1, day: 4)
      let jan4Weekday = ((jan4 + 3) % 7 + 7) % 7
      let weekStart = jan4 - jan4Weekday
      return (days - weekStart) / 7 + 1
    }
  }

  internal func weekOfMonth(
    for components: some ComponentContainer,
    in calendar: GregorianCalendarSystem
  ) -> Int {
    let day = components.valueIfPresent(for: .dayOfMonth) ?? 1
    let weekday = calendar.compute(.dayOfWeek, from: components)
    switch self {
    case .none:
      return (day + weekday - 2) / 7 + 1
    case .iso8601:
      return (day + weekday - 2) / 7 + 1
    }
  }

  internal func dayOfWeek(
    for components: some ComponentContainer,
    in calendar: GregorianCalendarSystem
  ) -> Int {
    let year = components.valueIfPresent(for: .year) ?? 0
    let month = components.valueIfPresent(for: .monthOfYear) ?? 1
    let day = components.valueIfPresent(for: .dayOfMonth) ?? 1
    let days = calendar.daysSinceEpoch(year: year, month: month, day: day)
    switch self {
    case .none:
      // Sunday = 1 ... Saturday = 7
      return ((days + 4) % 7 + 7) % 7 + 1
    case .iso8601:
      // Monday = 1 ... Sunday = 7
      return ((days + 3) % 7 + 7) % 7 + 1
    }
  }

  internal func yearForWeekOfYear(
    for components: some ComponentContainer,
    in calendar: GregorianCalendarSystem
  ) -> Int {
    switch self {
    case .none:
      return components.valueIfPresent(for: .year) ?? 0
    case .iso8601:
      let week = weekOfYear(for: components, in: calendar)
      let month = components.valueIfPresent(for: .monthOfYear) ?? 1
      let year = components.valueIfPresent(for: .year) ?? 0
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
