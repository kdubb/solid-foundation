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
  public let initial: (offset: ZoneOffset, duration: Duration, isStandardTime: Bool)

  /// The final offset for the region.
  ///
  /// - Note: The value is stored as both a ``ZoneOffset`` and a
  /// ``Duration`` to avoid recalculating the duration on each access.
  ///
  public let final: (offset: ZoneOffset, duration: Duration, isStandardTime: Bool)

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
    initial: (offset: ZoneOffset, isStandardTime: Bool),
    final: (offset: ZoneOffset, isStandardTime: Bool),
    transitions: [ZoneTransition],
    tailRule: ZoneTransitionRule? = nil,
    designationMap: [Instant: String] = [:]
  ) {
    self.initial = (initial.offset, Duration(initial.offset), initial.isStandardTime)
    self.final = (final.offset, Duration(final.offset), final.isStandardTime)
    self.transitions = transitions
    self.tailRule = tailRule
    self.designationMap = designationMap

    // Validate transition timestamps and local date/times are strictly increasing
    for (transitionIdx, transition) in transitions.enumerated() where transitionIdx > 0 {

      let previous = transitions[transitionIdx - 1]
      guard transition.instant > previous.instant else {
        fatalError("Transition timestamps must be strictly increasing.")
      }
      guard transition.before.local > previous.before.local else {
        fatalError("Transition timestamps must be strictly increasing.")
      }
      guard transition.after.local > previous.after.local else {
        fatalError("Transition timestamps must be strictly increasing.")
      }
      guard transition.localBoundaries.start > previous.localBoundaries.start else {
        fatalError("Transition timestamps must be strictly increasing.")
      }
      guard transition.localBoundaries.end > previous.localBoundaries.end else {
        fatalError("Transition timestamps must be strictly increasing.")
      }

    }
  }

  private func isProjected(_ dateTime: LocalDateTime) -> Bool {
    guard let lastTransition = transitions.last else {
      return false
    }
    return dateTime >= lastTransition.localBoundaries.end
  }

  private func isProjected(_ instant: Instant) -> Bool {
    guard let lastTransition = transitions.last else {
      return false
    }
    return instant > lastTransition.instant
  }

  // MARK: - ZoneRules Protocol Requirements

  public var isFixedOffset: Bool {
    return transitions.isEmpty && initial.offset == final.offset
  }

  public func standardOffset(at instant: Instant) -> ZoneOffset {

    guard !isProjected(instant) else {
      return tailRule?.standardTime.offset ?? final.offset
    }

    // If before the first transition, use the first available standard offset
    if let firstTransition = transitions.first, instant < firstTransition.instant {

      guard !initial.isStandardTime else {
        return initial.offset
      }

      // Find a transition to standard, fallback to initial
      return transitions.first(where: { $0.isStandardTime })?.after.offset ?? initial.offset
    }

    // Find last transition at or before instant
    guard let transitionIdx = transitions.lastIndex(where: { $0.instant <= instant }) else {
      fatalError("No transition found for instant, should have exited via before first/after last checks")
    }

    // Walk backward until we hit a transition to standard
    for checkTransitionIndx in stride(from: transitionIdx, through: 0, by: -1) {
      let checkTransition = transitions[checkTransitionIndx]
      if checkTransition.isStandardTime { return checkTransition.after.offset }
    }

    // If none flagged, fall back to initial offset
    return initial.offset
  }

  public func daylightSavingsTime(at instant: Instant) -> Duration {

    if isProjected(instant), let tailRule = tailRule {
      return tailRule.daylightSavingTime(for: instant, at: final.offset)
    }

    // Find last transition at or before instant
    guard let transitionIdx = transitions.lastIndex(where: { $0.instant <= instant }) else {
      // If initial is standard, no difference, otherwise find the first
      // transition to standard and compute difference
      guard
        !initial.isStandardTime,
        let stdTransition = transitions.first(where: { $0.isStandardTime })
      else {
        return .zero
      }
      return (Duration(stdTransition.after.offset) - Duration(initial.offset)).magnitude
    }

    let transition = transitions[transitionIdx]

    // Walk backward until we hit a transition to standard
    for curTransitionIndx in stride(from: transitionIdx, through: 0, by: -1) {
      let curTransition = transitions[curTransitionIndx]
      if curTransition.isStandardTime {
        return (Duration(curTransition.after.offset) - Duration(transition.after.offset)).magnitude
      }
    }
    // Walk forward until we hit a transition to standard
    for curTransitionIndx in stride(from: transitionIdx, to: transitions.count, by: 1) {
      let curTransition = transitions[curTransitionIndx]
      if curTransition.isStandardTime {
        return (Duration(transition.after.offset) - Duration(curTransition.after.offset)).magnitude
      }
    }

    // No transition to standard, compute vs. initial
    return (Duration(initial.offset) - Duration(transition.after.offset)).magnitude
  }

  public func isDaylightSavingsTime(at instant: Instant) -> Bool {
    return daylightSavingsTime(at: instant) > .zero
  }

  public func offset(at instant: Instant) -> ZoneOffset {

    if isProjected(instant), let tailRule {
      return tailRule.offset(at: instant)
    }

    // Find last transition at or before instant
    guard let transition = transitions.last(where: { $0.instant <= instant }) else {
      return initial.offset
    }

    return instant >= transition.instant ? transition.after.offset : transition.before.offset
  }

  public func offset(for dateTime: LocalDateTime) -> ZoneOffset {

    if isProjected(dateTime), let tailRule {
      return tailRule.offset(for: dateTime)
    }

    // Find last transition at or before local
    guard let transition = transitions.last(where: { $0.localBoundaries.start <= dateTime }) else {
      return initial.offset
    }
    guard dateTime < transition.localBoundaries.end else {
      return transition.after.offset
    }

    return transition.before.offset
  }

  public func validOffsets(for dateTime: LocalDateTime) -> ValidZoneOffsets {

    if isProjected(dateTime) {
      return tailRule?.validOffsets(for: dateTime) ?? .normal(final.offset)
    }

    // Find last transition at or before local
    guard let transition = transitions.last(where: { $0.localBoundaries.start <= dateTime }) else {
      return .normal(initial.offset)
    }

    guard let transitionOffsets = transition.validOffsets(for: dateTime) else {
      return .normal(transition.after.offset)
    }

    return transitionOffsets
  }

  public func isValidOffset(_ offset: ZoneOffset, for dateTime: LocalDateTime) -> Bool {
    return validOffsets(for: dateTime).contains(offset)
  }

  public func applicableTransition(for dateTime: LocalDateTime) -> ZoneTransition? {

    if isProjected(dateTime) {
      return tailRule?.applicableTransition(at: dateTime)
    }

    return transitions.first { $0.contains(dateTime) }
  }

  public func nextTransition(after instant: Instant) -> ZoneTransition? {
    guard let next = transitions.firstIndex(where: { $0.instant > instant }) else {
      return tailRule?.nextTransition(after: instant, at: final.offset)
    }
    return transitions[next]
  }

  public func priorTransition(before instant: Instant) -> ZoneTransition? {

    if isProjected(instant) {
      return tailRule?.priorTransition(before: instant, at: final.offset) ?? transitions.last
    }

    guard let prior = transitions.last(where: { $0.instant < instant }) else {
      return nil
    }
    return prior
  }

  public func designation(for instant: Instant) -> String {

    if isProjected(instant), let tailRule {
      return tailRule.designation(at: instant)
    }

    if let transition = transitions.last(where: { $0.instant <= instant }) {
      return transition.designation
    }

    // Maps are seeded with an entry that has a key of Instant.min,
    // so the max key ≤ instant gives the correct initial designation.
    let key = designationMap.keys.filter { $0 <= instant }.max()
    return key.flatMap { designationMap[$0] } ?? offset(at: instant).designation
  }
}
