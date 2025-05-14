//
//  RegionZoneRules.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//

import SolidCore


/// Rules defining the transitions that occur in a specific region.
///
/// Specifically for region based time zone (e.g., America/New_York), as opposed to fixed
/// offset time zones (e.g., UTC-05:00). Fixed offset time zones are handled by the
/// ``FixedOffsetZoneRules`` class.
///
public final class RegionZoneRules: ZoneRules, Sendable {

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
  ///
  public let tailRule: ZoneTransitionRule?

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
    tailRule: ZoneTransitionRule? = nil,
    designationMap: [Instant: String] = [:]
  ) {
    self.initial = (initial.offset, Duration(initial.offset), initial.isStandard)
    self.final = (final.offset, Duration(final.offset), final.isStandard)
    self.transitions = transitions
    self.tailRule = tailRule
    self.designationMap = designationMap
  }

  // MARK: - ZoneRules Protocol Requirements

  public var isFixedOffset: Bool {
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
    return ZoneOffset(availableComponents: [.zoneOffset(totalOffset.totalSeconds - standardOffset.totalSeconds)])
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

  public func offset(for dateTime: LocalDateTime) -> ZoneOffset {

    if let lastTransition = transitions.last, dateTime >= lastTransition.local.end, let tailRule {
      return tailRule.offset(for: dateTime)
    }

    guard let transition = transitions.last(where: { $0.local.start <= dateTime }) else {
      return initial.offset
    }
    guard dateTime < transition.local.end else {
      return transition.after.offset
    }

    switch transition.kind {
    case .gap:
      return transition.after.offset
    case .overlap:
      return transition.before.offset
    }
  }

  public func validOffsets(for dateTime: LocalDateTime) -> ValidZoneOffsets {
    let cal: GregorianCalendarSystem = .default

    for transition in transitions {
      let localBefore = cal.localDateTime(
        instant: transition.instant + transition.before.duration,
        at: transition.before.offset
      )
      let localAfter = cal.localDateTime(
        instant: transition.instant + transition.after.duration,
        at: transition.after.offset
      )

      switch transition.kind {
      case .gap:
        if dateTime >= localBefore && dateTime < localAfter {
          return .skipped(transition)
        }
      case .overlap:
        var offsets: [ZoneOffset] = []

        let localBeforeEnd = cal.localDateTime(
          instant: transition.instant + transition.before.duration + transition.after.duration,
          at: transition.before.offset
        )
        if dateTime >= localBefore && dateTime < localBeforeEnd {
          offsets.append(transition.before.offset)
        }

        let localAfterEnd = cal.localDateTime(
          instant: transition.instant + transition.after.duration + transition.before.duration,
          at: transition.after.offset
        )
        if dateTime >= localAfter && dateTime < localAfterEnd {
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
    let instant = cal.instant(from: dateTime, at: .utc)
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
