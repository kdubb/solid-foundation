//
//  ZoneTransitionRule.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/13/25.
//

import SolidCore


/// Describes the **recurring rule** that takes effect *after the last explicit
/// transition* that's defined.
///
/// A ``TailRule`` lets ``RegionZoneRules`` project offsets indefinitely into the
/// future.  When a caller asks for an `Instant` that is *later* than the final
/// transition in `transitions`, the rule is evaluated for the calendar year
/// that contains that instant to decide:
///
public struct ZoneTransitionRule: Sendable {

  /// A specific rule for projecting transitions into the future or past.
  ///
  public enum DateRule: Sendable {
    /// A transition that occurs every year on a **particular weekday of a
    /// particular week of a month**, at a specific local‑time offset from midnight.
    ///
    /// - Parameters:
    ///   - month: 1 through 12 (January = 1).
    ///   - week:  1 through 5, where 1 means "first week that contains the weekday"
    ///            and 5 means "last week that contains the weekday".
    ///   - day:   0 through 6 (Sunday = 0 … Saturday = 6).
    ///   - dayOffset: Seconds after local midnight at which the change happens
    ///                (e.g., `Duration.hours(2)` for 02:00).
    ///
    /// Example: `(month: 3, week: 2, day: 0, 02:00)`
    /// → "Second Sunday in March at 02:00 local time".
    ///
    case monthWeekDay(month: Int, week: Int, day: Int, dayOffset: Duration)

    /// A transition that occurs every year on an **absolute day‑of‑year**, with an
    /// optional local‑time offset from midnight.
    ///
    /// - Parameters:
    ///   - day: Day number within the civil year.
    ///
    ///     • If `leap` is `false`, the count skips 29 February, so
    ///      1 = 1 Jan, 59 = 28 Feb, 60 = 1 Mar, … 365 = 31 Dec.
    ///     • If `leap` is `true`, the count includes 29 February, so
    ///      0 = 1 Jan, 60 = 29 Feb (leap years), … 365 = 31 Dec.
    ///
    ///   - leap: Indicates which counting scheme is used (see above).
    ///   - dayOffset:Seconds after local midnight at which the change happens.
    ///
    /// Example: `(day: 60, leap: true, 7200 s)`
    /// →   "61-st day of the year (1 Mar in non-leap, 29 Feb in leap years) at 02:00".
    case julianDay(day: Int, leap: Bool, dayOffset: Duration)
  }

  /// Describes a standard time period.
  ///
  /// A standard time period is the time that is used when no transition is in effect.
  ///
  public struct StandardTime: Sendable {
    /// Offset for this time as the *total* difference from UTC.
    public let offset: ZoneOffset
    /// Designation for this time.
    public let designation: String
    /// Whether this time is a standard time period.
    public let isStandardTime: Bool
  }

  /// Describes a *daylight saving* time period and the rules governing
  /// its transition.
  ///
  public struct DaylightSavingTime: Sendable {
    /// Offset for this time as the *total* difference from UTC.
    public let offset: ZoneOffset
    /// Designation for this time.
    public let designation: String
    /// Rule describing when the DST period **begins** each year.
    public let startRule: DateRule
    /// Rule describing when the DST period **ends** each year.
    public let endRule: DateRule
  }

  /// The *standard-time* time details (always present).
  ///
  /// - Note: *Standard time* is the offset that applies when no daylight-saving
  ///   adjustment is in effect — either between DST periods or in zones that
  ///   never observe DST.
  ///
  public let standardTime: StandardTime
  /// The *daylight-saving-time* offset details, if the zone
  /// observes DST in future years.
  ///
  /// If the zone does not observe DST, this property will be `nil`.
  ///
  public let daylightSavingTime: DaylightSavingTime?

  /// Initialize a new tail rule with the given standard and daylight
  /// saving time offsets.
  public init(
    standardTime: StandardTime,
    daylightSavingTime: DaylightSavingTime?
  ) {
    self.standardTime = standardTime
    self.daylightSavingTime = daylightSavingTime
  }

  public func offset(at instant: Instant) -> ZoneOffset {
    guard let daylightSavingTime, let (start, end, _) = computeStartEnd(at: instant) else {
      return standardTime.offset
    }

    return instant >= start.instant && instant < end.instant ? daylightSavingTime.offset : standardTime.offset
  }

  public func offset(for dateTime: LocalDateTime) -> ZoneOffset {
    guard let daylightSavingTime, let (start, end, _) = computeStartEnd(for: dateTime) else {
      return standardTime.offset
    }

    return dateTime >= start.local && dateTime < end.local ? daylightSavingTime.offset : standardTime.offset
  }

  public func nextTransition(at instant: Instant) -> Instant? {
    guard let (start, end, year) = computeStartEnd(at: instant) else {
      return nil
    }

    if instant < start.instant {
      return start.instant
    } else if instant < end.instant {
      return end.instant
    } else {
      return start.rule.tailOffset(for: year + 1, offset: standardTime.offset).instant
    }
  }

  public func prevTransition(at instant: Instant) -> Instant? {
    guard let (start, end, year) = computeStartEnd(at: instant) else {
      return nil
    }

    if instant > end.instant {
      return end.instant
    } else if instant > start.instant {
      return start.instant
    } else {
      return end.rule.tailOffset(for: year - 1, offset: standardTime.offset).instant
    }
  }

  private func computeStartEnd(
    at instant: Instant
  ) -> (
    start: (instant: Instant, rule: DateRule),
    end: (instant: Instant, rule: DateRule),
    year: Int
  )? {
    guard let daylightSavingTime else {
      return nil
    }

    let startRule = daylightSavingTime.startRule
    let endRule = daylightSavingTime.endRule
    let date = GregorianCalendarSystem.default.localDate(instant: instant, at: standardTime.offset)
    let start = startRule.tailOffset(for: date.year, offset: standardTime.offset).instant
    let end = endRule.tailOffset(for: date.year, offset: daylightSavingTime.offset).instant
    return ((start, startRule), (end, endRule), date.year)
  }

  private func computeStartEnd(
    for dateTime: LocalDateTime
  ) -> (
    start: (local: LocalDateTime, rule: DateRule),
    end: (local: LocalDateTime, rule: DateRule),
    year: Int
  )? {

    guard let daylightSavingTime else {
      return nil
    }

    let startRule = daylightSavingTime.startRule
    let endRule = daylightSavingTime.endRule
    let date = dateTime.date
    let start = startRule.tailOffset(for: date.year, offset: standardTime.offset).local
    let end = endRule.tailOffset(for: date.year, offset: daylightSavingTime.offset).local
    return ((start, startRule), (end, endRule), date.year)
  }

}

extension ZoneTransitionRule.DateRule {

  // Compute the tail offset for a given year, rule, and offset.
  func tailOffset(for year: Int, offset: ZoneOffset) -> (instant: Instant, local: LocalDateTime) {
    let cal = GregorianCalendarSystem.default

    switch self {
    case .monthWeekDay(let month, let week, let weekday, let dayOffset):
      // 1) first day of month
      let firstOfMonth = LocalDate(valid: (year: year, month: month, day: 1))
      // 2) weekday of first day (0=Sun)
      let weekdayOfFirstOfMonth = isoCalendar.variant.dayOfWeek(for: firstOfMonth, in: isoCalendar) % 7
      // 3) compute target day of month
      var dayInMonth = 1 + ((7 + weekday - weekdayOfFirstOfMonth) % 7) + (week - 1) * 7
      if week == 5 {
        // Move to last such weekday in month
        while true {
          let next = dayInMonth + 7
          guard let _ = try? firstOfMonth.with(day: next) else {
            break
          }
          dayInMonth = next
        }
      }
      let date = LocalDate(valid: (year: year, month: month, day: dayInMonth))
      let dateTime = neverThrow(try LocalDateTime(date: date, timeDuration: dayOffset))
      return (cal.instant(from: dateTime, at: offset), dateTime)

    case .julianDay(let day, let leap, let dayOffset):
      var ordinal = day
      if !leap && cal.isLeapYear(year) && day >= 60 {
        ordinal += 1
      }
      let date = neverThrow(try LocalDate(year: year, ordinalDay: ordinal + 1))
      let dateTime = neverThrow(try LocalDateTime(date: date, timeDuration: dayOffset))
      return (cal.instant(from: dateTime, at: offset), dateTime)
    }
  }
}

private let isoCalendar = GregorianCalendarSystem.iso8601
