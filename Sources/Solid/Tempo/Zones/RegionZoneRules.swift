//
//  RegionZoneRules.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//

/// Rules defining the transitions that occur in a specific region.
///
/// Specifically for region based time zone (e.g., America/New_York), as opposed to fixed
/// offset time zones (e.g., UTC-05:00). Fixed offset time zones are handled by the
/// ``FixedOffsetZoneRules`` class.
///
public final class RegionZoneRules: ZoneRules, Sendable {

  /// Describes the **recurring rule** that takes effect *after the last explicit
  /// transition* that's defined.
  ///
  /// A ``TailRule`` lets ``RegionZoneRules`` project offsets indefinitely into the
  /// future.  When a caller asks for an `Instant` that is *later* than the final
  /// transition in `transitions`, the rule is evaluated for the calendar year
  /// that contains that instant to decide:
  ///
  public struct TailRule: Sendable {

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
  }

  /// The initial offset for the region.
  ///
  /// - Note: The value is stored as both a ``ZoneOffset`` and a
  /// ``Duration`` for convenience in calculations.
  ///
  public let initial: (offset: ZoneOffset, duration: Duration, isStandard: Bool)
  /// The final offset for the region.
  ///
  /// - Note: The value is stored as both a ``ZoneOffset`` and a
  /// ``Duration`` to avoid recalculating the duration on each access.
  ///
  public let final: (offset: ZoneOffset, duration: Duration, isStandard: Bool)
  /// The transitions for the region.
  ///
  public let transitions: [ZoneTransition]
  /// The tail rule for the region, if any.
  public let tailRule: TailRule?

  private let designationMap: [Instant: String]

  /// Initialize a new region zone rules with the given initial offset,
  /// final offset, and transitions and other metadata.
  ///
  /// - Parameters:
  ///   - initial: The initial offset & standard indicator for the region.
  ///   - final: The final offset & standard indicator for the region.
  ///   - transitions: The transitions for the region.
  ///   - tailRule: The tail rule for the region, if any.
  ///   - designationMap: The designation map for the region.
  ///
  public init(
    initial: (offset: ZoneOffset, isStandard: Bool),
    final: (offset: ZoneOffset, isStandard: Bool),
    transitions: [ZoneTransition],
    tailRule: TailRule? = nil,
    designationMap: [Instant: String] = [:]
  ) {
    self.initial = (initial.offset, Duration(initial.offset), initial.isStandard)
    self.final = (final.offset, Duration(final.offset), final.isStandard)
    self.transitions = transitions
    self.tailRule = tailRule
    self.designationMap = designationMap
  }

  // MARK: - ZoneRules Protocol Requirements

  public var isFixed: Bool {
    return transitions.isEmpty && initial.offset == final.offset
  }

  public func standardOffset(at instant: Instant) -> ZoneOffset {

    // If after the last transition, use the tail rule if available
    if let lastTransition = transitions.last, instant > lastTransition.instant {
      guard let tailRule else {
        // No tail rule, so fixed final offset
        return final.offset
      }
      return tailRule.standardTime.offset
    }

    // If before the first transition, use the initial offset
    if let firstTransition = transitions.first, instant < firstTransition.instant {
      guard !initial.isStandard else {
        // Initial offset is standard, so use it
        return initial.offset
      }
      // Otherwise walk *forward* to the first standard transition.
      if let std = transitions.first(where: { $0.isStandardTime }) {
        return std.after.offset
      }
      // Fallback: no standard flag in table – assume initial
      return initial.offset
    }

    // Find last transition at or before instant
    guard let transitionIdx = transitions.lastIndex(where: { $0.instant <= instant }) else {
      return initial.offset    // should never hit due to earlier guard
    }

    // Walk backward until we hit a transition whose *after* is standard
    for checkTransitionIndx in stride(from: transitionIdx, through: 0, by: -1) {
      let checkTransition = transitions[checkTransitionIndx]
      if checkTransition.isStandardTime { return checkTransition.after.offset }
    }

    // If none flagged, fall back to initial offset
    return initial.offset
  }

  public func daylightSavingsTime(at instant: Instant) -> ZoneOffset {
    let totalOffset = offset(at: instant)
    let standardOffset = standardOffset(at: instant)
    return ZoneOffset(valid: totalOffset.totalSeconds - standardOffset.totalSeconds)
  }

  public func isDaylightSavingsTime(at instant: Instant) -> Bool {
    guard let transition = transitions.last(where: { $0.instant <= instant }) else {
      return false
    }
    return transition.isDaylightSavingTime
  }

  public func offset(at instant: Instant) -> ZoneOffset {

    if let lastTransition = transitions.last, instant > lastTransition.instant, let tailRule {
      return tailRule.offset(at: instant)
    }

    guard let transition = transitions.last(where: { $0.instant <= instant }) else {
      return initial.offset
    }

    return transition.after.offset
  }

  public func validOffsets(for dateTime: LocalDateTime) -> ValidZoneOffsets {
    let cal: CalendarSystem = .default

    for transition in transitions {
      let localBefore: LocalDateTime = cal.components(
        from: transition.instant + transition.before.duration,
        in: .fixed(offset: transition.before.offset)
      )
      let localAfter: LocalDateTime = cal.components(
        from: transition.instant + transition.after.duration,
        in: .fixed(offset: transition.after.offset)
      )

      switch transition.kind {
      case .gap:
        if dateTime >= localBefore && dateTime < localAfter {
          return .skipped
        }
      case .overlap:
        var offsets: [ZoneOffset] = []
        // swift-format-ignore: NeverUseForceTry
        if try! dateTime >= localBefore && dateTime < localBefore.adding(transition.after.duration) {
          offsets.append(transition.before.offset)
        }
        // swift-format-ignore: NeverUseForceTry
        if try! dateTime >= localAfter && dateTime < localAfter.adding(transition.before.duration) {
          offsets.append(transition.after.offset)
        }
        switch offsets.count {
        case 2:
          return .ambiguous(offsets)
        case 1:
          return .normal(offsets[0])
        default:
          // No valid offsets in this range
          break
        }
      }
    }

    // Normal case: exactly one valid offset
    let instant = cal.nearestInstant(from: dateTime)
    let off = offset(at: instant)
    return .normal(off)
  }

  public func isValidOffset(_ offset: ZoneOffset, for dateTime: LocalDateTime) -> Bool {
    let validOffsets = validOffsets(for: dateTime)
    return validOffsets.contains(offset)
  }

  public func applicableTransition(for dateTime: LocalDateTime) -> ZoneTransition? {
    let cal: CalendarSystem = .default

    // Check each transition to see if it applies to this local date/time

    for transition in transitions {
      let localBefore: LocalDateTime = cal.components(
        from: transition.instant + transition.before.duration,
        in: .fixed(offset: transition.before.offset)
      )
      let localAfter: LocalDateTime = cal.components(
        from: transition.instant + transition.after.duration,
        in: .fixed(offset: transition.after.offset)
      )

      switch transition.kind {
      case .gap:
        if dateTime >= localBefore && dateTime < localAfter {
          return transition
        }
      case .overlap:
        // swift-format-ignore: NeverUseForceTry
        if try! (dateTime >= localBefore && dateTime < localBefore.adding(transition.after.duration))
          || (dateTime >= localAfter && dateTime < localAfter.adding(transition.before.duration))
        {
          return transition
        }
      }
    }

    return nil
  }

  public func nextTransition(after instant: Instant) -> Instant? {
    guard let nextSpecific = transitions.first(where: { $0.instant > instant }) else {
      guard let tailRule else {
        return nil
      }
      return tailRule.nextTransition(at: instant)
    }
    return nextSpecific.instant
  }

  public func previousTransition(before instant: Instant) -> Instant? {
    guard let prevSpecific = transitions.last(where: { $0.instant < instant }) else {
      guard let tailRule else {
        return nil
      }
      return tailRule.prevTransition(at: instant)
    }
    return prevSpecific.instant
  }

  public func designation(for instant: Instant) -> String? {

    // After last transition, use tail rule if available
    if let last = transitions.last, instant > last.instant, let rule = tailRule {
      // Decide which side of the rule we are on
      if let dst = rule.daylightSavingTime {
        // Tail rule has DST → evaluate offset to distinguish
        let off = rule.offset(at: instant)
        if off == dst.offset { return dst.designation }
        return rule.standardTime.designation
      }
      // No DST in tail rule → always standard
      return rule.standardTime.designation
    }

    // Between first and last transition, use the latest transition
    if let tr = transitions.last(where: { $0.instant <= instant }) {
      return tr.designation
    }

    // Before the first transition → sentinel entry in designationMap
    // ------------------------------------------------------------------
    // `designationMap` was seeded with an entry whose key is Instant.min
    // so the max key ≤ instant gives the correct initial designation.
    let key = designationMap.keys.filter { $0 <= instant }.max()
    return key.flatMap { designationMap[$0] }
  }
}

extension RegionZoneRules.TailRule {

  func offset(at instant: Instant) -> ZoneOffset {
    guard let daylightSavingTime, let (start, end, _) = computeStartEnd(at: instant) else {
      return standardTime.offset
    }

    return instant >= start.instant && instant < end.instant ? daylightSavingTime.offset : standardTime.offset
  }

  func nextTransition(at instant: Instant) -> Instant? {
    guard let (start, end, year) = computeStartEnd(at: instant) else {
      return nil
    }

    if instant < start.instant {
      return start.instant
    } else if instant < end.instant {
      return end.instant
    } else {
      return start.rule.tailOffset(for: year + 1, offset: standardTime.offset)
    }
  }

  func prevTransition(at instant: Instant) -> Instant? {
    guard let (start, end, year) = computeStartEnd(at: instant) else {
      return nil
    }

    if instant > end.instant {
      return end.instant
    } else if instant > start.instant {
      return start.instant
    } else {
      return end.rule.tailOffset(for: year - 1, offset: standardTime.offset)
    }
  }

  func computeStartEnd(
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
    let date = GregorianCalendarSystem.default.localDate(instant: instant, offset: standardTime.offset)
    let start = startRule.tailOffset(for: date.year, offset: standardTime.offset)
    let end = endRule.tailOffset(for: date.year, offset: daylightSavingTime.offset)
    return ((start, startRule), (end, endRule), date.year)
  }

}

extension RegionZoneRules.TailRule.DateRule {

  // Compute the tail offset for a given year, rule, and offset.
  func tailOffset(for year: Int, offset: ZoneOffset) -> Instant {
    let cal = GregorianCalendarSystem.default

    switch self {
    case .monthWeekDay(let m, let w, let d, let dayOffset):
      // 1) first day of month
      var date = LocalDate(valid: (year: year, month: m, day: 1))
      // 2) weekday of first day (0=Sun)
      // swift-format-ignore: NeverUseForceTry
      let weekday = try! cal.resolve(.dayOfWeek, from: date, resolution: .default)
      // 3) compute target day of month
      var dayInMonth = 1 + ((7 + d - weekday) % 7) + (w - 1) * 7
      if w == 5 {
        // Move to last such weekday in month
        while true {
          let next = dayInMonth + 7
          guard let _ = try? date.with(day: next) else {
            break
          }
          dayInMonth = next
        }
      }
      date = LocalDate(valid: (year: year, month: m, day: dayInMonth))
      // swift-format-ignore: NeverUseForceTry
      let offsetDate = try! date.adding(dayOffset).adding(-Duration(offset))
      return cal.instant(from: offsetDate, resolution: .default)

    case .julianDay(let n, let leap, let dayOff):
      var ordinal = n
      if !leap && cal.isLeapYear(year) && n >= 60 {
        ordinal += 1
      }
      // swift-format-ignore: NeverUseForceTry
      let date = try! LocalDate(year: year, ordinalDay: ordinal + 1)    // ordinal is 1-based
      // swift-format-ignore: NeverUseForceTry
      let offsetDate = try! date.adding(dayOff).adding(-Duration(components: offset))
      return cal.instant(from: offsetDate, resolution: .default)
    }
  }
}
