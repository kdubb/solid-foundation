//
//  ZoneTransition.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//

/// A transition from one offset to another at a specific point in time.
///
public struct ZoneTransition {

  /// Kind of transition, it either creates a skipped time
  /// gap or an ambiguous overlapping period.
  public enum Kind: Sendable {
    /// A gap in time, where the offset is skipped.
    case gap
    /// An overlap in time, where the offset is ambiguous.
    case overlap
  }

  /// Kind of transition, either gap or overlap.
  public let kind: Kind

  /// The moment in UTC at which the transition occurs.
  public let instant: Instant

  /// Local time at which the transition starts and ends.
  ///
  public let local: (start: LocalDateTime, end: LocalDateTime)

  /// The offset before the transition occurs.
  ///
  /// - Note: The value is available as both a ``ZoneOffset``
  /// and a ``Duration`` for convenience in calculations.
  ///
  public let before: (offset: ZoneOffset, duration: Duration)

  /// The offset after the transition occurs.
  ///
  /// - Note: The value is available as both a ``ZoneOffset``
  /// and a ``Duration`` for convenience in calculations.
  ///
  public let after: (offset: ZoneOffset, duration: Duration)

  /// The designation for the transition.
  public let designation: String

  /// Whether the period after the transition (until the next
  /// transition) is a Daylight Saving Time period.
  ///
  public let isDaylightSavingTime: Bool

  public let isStandardTime: Bool

  /// Initialize a new transition with an explicit transition
  /// instant, offsets, and other metadata.
  ///
  /// - Note: Transitions are generally created by the system,
  ///   and this initializer is only used for testing.
  ///
  /// - Parameters:
  ///   - kind: The kind of transition, either gap or overlap.
  ///   - instant: The instant in UTC at which the transition occurs.
  ///   - local: The local start and end time of the transition.
  ///   - offsetBefore: The total offset before the transition occurs.
  ///   - offsetAfter: The total offset after the transition occurs.
  ///   - designation: The designation for the transition.
  ///   - isDaylightSavingTime: Whether the period is daylight saving time.
  ///   - isStandardTime: Whether the period is standard time.
  ///
  public init(
    kind: Kind,
    instant: Instant,
    local: (start: LocalDateTime, end: LocalDateTime),
    offsetBefore: ZoneOffset,
    offsetAfter: ZoneOffset,
    designation: String,
    isDaylightSavingTime: Bool,
    isStandardTime: Bool,
  ) {
    self.kind = kind
    self.instant = instant
    self.local = local
    self.before = (offsetBefore, .seconds(offsetBefore.totalSeconds))
    self.after = (offsetAfter, .seconds(offsetAfter.totalSeconds))
    self.designation = designation
    self.isDaylightSavingTime = isDaylightSavingTime
    self.isStandardTime = isStandardTime
  }

  public var duration: Duration {
    switch kind {
    case .gap:
      return after.duration - before.duration
    case .overlap:
      return before.duration - after.duration
    }
  }
}

extension ZoneTransition: Sendable {}
extension ZoneTransition: Equatable {

  public static func == (lhs: ZoneTransition, rhs: ZoneTransition) -> Bool {
    lhs.instant == rhs.instant && lhs.before.offset == rhs.before.offset && lhs.before.duration == rhs.before.duration
      && lhs.after.offset == rhs.after.offset && lhs.after.duration == rhs.after.duration
      && lhs.designation == rhs.designation && lhs.isDaylightSavingTime == rhs.isDaylightSavingTime
      && lhs.isStandardTime == rhs.isStandardTime
  }

}
extension ZoneTransition: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(instant)
    hasher.combine(before.offset)
    hasher.combine(before.duration)
    hasher.combine(after.offset)
    hasher.combine(after.duration)
    hasher.combine(designation)
    hasher.combine(isDaylightSavingTime)
    hasher.combine(isStandardTime)
  }

}
