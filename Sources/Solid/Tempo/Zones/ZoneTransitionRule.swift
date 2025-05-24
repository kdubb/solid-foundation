//
//  ZoneTransitionRule.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/13/25.
//

import SolidCore
import Synchronization
import Foundation


/// Describes the **recurring rule** that takes effect *after the last explicit
/// transition* that's defined.
///
/// A ``ZoneTransitionRule`` allows projecting offsets indefinitely into the
/// future. When paired with historical ``ZoneTransition`` instances, it can
/// project offsets for any instant after the last historical transition.
///
public struct ZoneTransitionRule {

  /// A specific rule for projecting transitions into the future or past.
  ///
  public enum DateRule {
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
  public struct StandardTime {
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
  public struct DaylightSavingTime {
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

  internal func offsetDetails(at instant: Instant) -> (offset: ZoneOffset, designation: String) {
    guard let daylightSavingTime else {
      return (standardTime.offset, standardTime.designation)
    }

    let local = isoCalendar.localDate(instant: instant, at: standardTime.offset)
    guard let (start, end) = projectTransitions(for: local.year) else {
      return (standardTime.offset, standardTime.designation)
    }

    return if start.localBoundaries.start < end.localBoundaries.start {
      instant < start.instant || instant >= end.instant
        ? (standardTime.offset, standardTime.designation)
        : (daylightSavingTime.offset, daylightSavingTime.designation)
    } else {
      instant >= start.instant || instant < end.instant
        ? (daylightSavingTime.offset, daylightSavingTime.designation)
        : (standardTime.offset, standardTime.designation)
    }
  }

  /// Returns the zone offset for the given instant.
  ///
  /// - Parameter instant: The instant to get the offset for.
  /// - Returns: The zone offset for the specified `instant`.
  ///
  public func offset(at instant: Instant) -> ZoneOffset {
    return offsetDetails(at: instant).offset
  }

  /// Returns the zone offset for the given local date/time.
  ///
  /// Determining the offset for a local date/time can be ambiguous when it occurs during a gap
  /// or overlap. This method returns the best available value, for normal cases the only valid
  /// offset is returned for ambiguous cases the offset **before** the transition is returned.
  ///
  /// - Note: If exact values are required, the ``validOffsets(for:)`` method should
  /// be used along with the appropriate handling of gap/overlap periods.
  ///
  /// - Parameter dateTime: Local date/time to determine offset for.
  /// - Returns: The specific offset for normal date/time values and the offset before for ambiguous
  /// date/time values.
  ///
  public func offset(for dateTime: LocalDateTime) -> ZoneOffset {

    guard let daylightSavingTime, let (start, end) = projectTransitions(for: dateTime.year) else {
      return standardTime.offset
    }

    return if start.localBoundaries.start < end.localBoundaries.start {
      dateTime < start.localBoundaries.end || dateTime >= end.localBoundaries.end
        ? standardTime.offset
        : daylightSavingTime.offset
    } else {
      dateTime >= start.localBoundaries.end || dateTime < end.localBoundaries.end
        ? daylightSavingTime.offset
        : standardTime.offset
    }
  }

  public func daylightSavingTime(for instant: Instant, at offset: ZoneOffset) -> Duration {
    guard let daylightSavingTime else {
      return .zero
    }

    let year = isoCalendar.year(for: instant, at: offset)
    guard let (start, end) = projectTransitions(for: year) else {
      return .zero
    }

    return if start.localBoundaries.start < end.localBoundaries.start {
      instant < start.instant || instant >= end.instant
        ? .zero
        : .seconds(daylightSavingTime.offset.totalSeconds - standardTime.offset.totalSeconds)
    } else {
      instant >= start.instant || instant < end.instant
        ? .seconds(daylightSavingTime.offset.totalSeconds - standardTime.offset.totalSeconds)
        : .zero
    }
  }

  public func validOffsets(for dateTime: LocalDateTime) -> ValidZoneOffsets {
    guard let daylightSavingTime, let (start, end) = projectTransitions(for: dateTime.year) else {
      return .normal(standardTime.offset)
    }

    guard let validOffsets = start.validOffsets(for: dateTime) ?? end.validOffsets(for: dateTime) else {

      return if start.localBoundaries.start < end.localBoundaries.start {
        dateTime < start.localBoundaries.end || dateTime >= end.localBoundaries.end
          ? .normal(standardTime.offset)
          : .normal(daylightSavingTime.offset)
      } else {
        dateTime >= start.localBoundaries.end || dateTime < end.localBoundaries.end
          ? .normal(daylightSavingTime.offset)
          : .normal(standardTime.offset)
      }
    }

    return validOffsets
  }

  public func applicableTransition(at dateTime: LocalDateTime) -> ZoneTransition? {
    guard let (start, end) = projectTransitions(for: dateTime.year) else {
      return nil
    }

    if start.contains(dateTime) {
      return start
    } else if end.contains(dateTime) {
      return end
    } else {
      return nil
    }
  }

  public func nextTransition(after instant: Instant, at offset: ZoneOffset) -> ZoneTransition? {
    let year = isoCalendar.year(for: instant, at: offset)
    guard let (start, end) = projectTransitions(for: year) else {
      return nil
    }

    return if start.localBoundaries.start < end.localBoundaries.start {
      if instant < start.instant {
        start
      } else if instant < end.instant {
        end
      } else {
        projectTransitions(for: year + 1)?.start
      }
    } else {
      if instant < end.instant {
        end
      } else if instant < start.instant {
        start
      } else {
        projectTransitions(for: year + 1)?.end
      }
    }
  }

  public func nextTransition(after dateTime: LocalDateTime) -> ZoneTransition? {
    guard let (start, end) = projectTransitions(for: dateTime.year) else {
      return nil
    }

    return if start.localBoundaries.start < end.localBoundaries.start {
      if dateTime < start.localBoundaries.start {
        start
      } else if dateTime < end.localBoundaries.start {
        end
      } else {
        projectTransitions(for: dateTime.year + 1)?.start
      }
    } else {
      if dateTime < end.localBoundaries.start {
        end
      } else if dateTime < start.localBoundaries.start {
        start
      } else {
        projectTransitions(for: dateTime.year + 1)?.end
      }
    }
  }

  public func priorTransition(before instant: Instant, at offset: ZoneOffset) -> ZoneTransition? {
    let year = isoCalendar.year(for: instant, at: offset)
    guard let (start, end) = projectTransitions(for: year) else {
      return nil
    }

    return if start.localBoundaries.start < end.localBoundaries.start {
      if instant > end.instant {
        end
      } else if instant > start.instant {
        start
      } else {
        projectTransitions(for: year - 1)?.end
      }
    } else {
      if instant > start.instant {
        start
      } else if instant > end.instant {
        end
      } else {
        projectTransitions(for: year - 1)?.start
      }
    }
  }

  public func priorTransition(before dateTime: LocalDateTime) -> ZoneTransition? {
    guard let (start, end) = projectTransitions(for: dateTime.year) else {
      return nil
    }

    return if start.localBoundaries.start < end.localBoundaries.start {
      if dateTime > end.localBoundaries.end {
        end
      } else if dateTime > start.localBoundaries.end {
        start
      } else {
        projectTransitions(for: dateTime.year - 1)?.end
      }
    } else {
      if dateTime > start.localBoundaries.end {
        start
      } else if dateTime > end.localBoundaries.end {
        end
      } else {
        projectTransitions(for: dateTime.year - 1)?.start
      }
    }
  }

  public func designation(at instant: Instant) -> String {
    return offsetDetails(at: instant).designation
  }

  private func projectTransitions(for year: Int) -> (start: ZoneTransition, end: ZoneTransition)? {

    guard let daylightSavingTime else {
      return nil
    }

    return Cache.transitions(year: year, standardTime: standardTime, daylightSavingTime: daylightSavingTime)
  }

}

extension ZoneTransitionRule: Sendable {}
extension ZoneTransitionRule: Equatable {}
extension ZoneTransitionRule: Hashable {}

extension ZoneTransitionRule: CustomStringConvertible {

  public var description: String {
    """
    ZoneTransitionRule(\
    STD: \(standardTime)\
    \(daylightSavingTime.map { ", DST: \($0)" } ?? "")\
    )
    """
  }

}

extension ZoneTransitionRule.StandardTime: Sendable {}
extension ZoneTransitionRule.StandardTime: Equatable {}
extension ZoneTransitionRule.StandardTime: Hashable {}

extension ZoneTransitionRule.StandardTime: CustomStringConvertible {

  public var description: String {
    "\(self.offset) \(self.designation)"
  }

}

extension ZoneTransitionRule.DaylightSavingTime: Sendable {}
extension ZoneTransitionRule.DaylightSavingTime: Equatable {}
extension ZoneTransitionRule.DaylightSavingTime: Hashable {}

extension ZoneTransitionRule.DaylightSavingTime: CustomStringConvertible {

  public var description: String {
    "\(self.offset) \(self.designation) [\(self.startRule) - \(self.endRule)]"
  }

}

extension ZoneTransitionRule.DateRule: Sendable {}
extension ZoneTransitionRule.DateRule: Equatable {}
extension ZoneTransitionRule.DateRule: Hashable {}

extension ZoneTransitionRule.DateRule: CustomStringConvertible {

  public var description: String {
    switch self {
    case .monthWeekDay(month: let month, week: let week, day: let weekday, dayOffset: let dayOffset):
      """
      \(week == 5 ? "Last" : ordinalFmt.string(from: NSNumber(value: week)).neverNil()) week of \
      \(posixLocale.calendar.monthSymbols[month - 1]), \
      \(posixLocale.calendar.weekdaySymbols[weekday]) at \
      \(LocalTime(durationSinceMidnight: dayOffset).description(style: .default))
      """
    case .julianDay(day: let day, leap: let isLeap, dayOffset: let dayOffset):
      """
      \(ordinalFmt.string(from: NSNumber(value: day)).neverNil())\
      \(
        isLeap && day >= 60
          ? "(\(ordinalFmt.string(from: NSNumber(value: day + 1)).neverNil()) for leap years)"
          : ""
      ) \
      day of year at \
      \(LocalTime(durationSinceMidnight: dayOffset).description(style: .default))
      """
    }
  }

}

extension ZoneTransitionRule.DateRule {

  /// Compute the transition time for a given year and offset.
  internal func projectTransition(for year: Int) -> LocalDateTime {

    switch self {
    case .monthWeekDay(let month, let week, let weekday, let dayOffset):
      // 1) first day of month
      let firstOfMonth = neverThrow(try LocalDate(year: year, month: month, day: 1))
      // 2) weekday of first day (0=Sun)
      let weekdayOfFirstOfMonth = isoCalendar.variant.dayOfWeek(for: firstOfMonth, in: isoCalendar) % 7
      // 3) compute target day of month
      var dayInMonth = 1 + ((7 + weekday - weekdayOfFirstOfMonth) % 7) + (week - 1) * 7
      if week == 5 {
        // If the nominal day spills past the end of the month,
        // step *back* one week at a time until it fits.
        while (try? firstOfMonth.with(day: dayInMonth)) == nil {
          dayInMonth -= 7
        }
        // Move to last such weekday in month
        while true {
          let next = dayInMonth + 7
          guard let _ = try? firstOfMonth.with(day: next) else {
            break
          }
          dayInMonth = next
        }
      }
      let date = neverThrow(try LocalDate(year: year, month: month, day: dayInMonth))
      return neverThrow(try LocalDateTime(date: date, adding: dayOffset))

    case .julianDay(let day, let leap, let dayOffset):
      var ordinal = day
      if !leap && isoCalendar.isLeapYear(year) && day >= 60 {
        ordinal += 1
      }
      let date = neverThrow(try LocalDate(year: year, ordinalDay: ordinal + 1))
      return neverThrow(try LocalDateTime(date: date, adding: dayOffset))
    }
  }
}

extension ZoneTransitionRule {

  struct Cache {

    struct Key: Hashable {
      let year: Int
      let dst: DaylightSavingTime
    }

    private static let transitionCache = Mutex<[Key: (start: ZoneTransition, end: ZoneTransition)]>([:])

    public static func transitions(
      year: Int,
      standardTime: StandardTime,
      daylightSavingTime: DaylightSavingTime
    ) -> (start: ZoneTransition, end: ZoneTransition)? {
      let key = Key(year: year, dst: daylightSavingTime)

      if let cached = Self.transitionCache.withLock({ $0[key] }) {
        return cached
      }

      let transitions = buildTransitions(for: year, standardTime: standardTime, daylightSavingTime: daylightSavingTime)
      Self.transitionCache.withLock { $0[key] = transitions }
      return (transitions.start, transitions.end)
    }

    private static func buildTransitions(
      for year: Int,
      standardTime: ZoneTransitionRule.StandardTime,
      daylightSavingTime: ZoneTransitionRule.DaylightSavingTime,
    ) -> (start: ZoneTransition, end: ZoneTransition) {

      let startTransition = buildTransition(
        for: year,
        standardTime: standardTime,
        daylightSavingTime: daylightSavingTime,
        rule: daylightSavingTime.startRule,
        isStart: true
      )

      let endTransition = buildTransition(
        for: year,
        standardTime: standardTime,
        daylightSavingTime: daylightSavingTime,
        rule: daylightSavingTime.endRule,
        isStart: false
      )

      return (startTransition, endTransition)
    }

    private static func buildTransition(
      for year: Int,
      standardTime: ZoneTransitionRule.StandardTime,
      daylightSavingTime: ZoneTransitionRule.DaylightSavingTime,
      rule: ZoneTransitionRule.DateRule,
      isStart: Bool
    ) -> ZoneTransition {

      let localTransition = rule.projectTransition(for: year)
      let (offsetBefore, offsetAfter, designation) =
        isStart
        ? (standardTime.offset, daylightSavingTime.offset, daylightSavingTime.designation)
        : (daylightSavingTime.offset, standardTime.offset, standardTime.designation)

      let instant = Instant(localTransition, offset: offsetBefore)

      return ZoneTransition.from(
        instant: instant,
        offsetBefore: offsetBefore,
        offsetAfter: offsetAfter,
        designation: designation,
        isDaylightSavingTime: isStart,
        in: .default
      )
    }
  }
}

private let posixLocale = Locale(identifier: "en_US_POSIX")
private let ordinalFmt = {
  let fmt = NumberFormatter()
  fmt.numberStyle = .ordinal
  fmt.locale = posixLocale
  return fmt
}()
private let isoCalendar = GregorianCalendarSystem.iso8601
