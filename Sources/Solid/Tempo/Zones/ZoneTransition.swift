//
//  ZoneTransition.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//

/// A transition from one offset to another at a specific point in time.
///
public struct ZoneTransition: Sendable {

  /// Kind of transition, it either creates a skipped time
  /// gap or an ambiguous overlapping period.
  enum Kind: Sendable {
    /// A gap in time, where the offset is skipped.
    case gap
    /// An overlap in time, where the offset is ambiguous.
    case overlap
  }

  /// Kind of transition, either gap or overlap.
  let kind: Kind
  /// The moment in UTC at which the transition occurs.
  let instant: Instant
  /// The offset before the transition occurs.
  ///
  /// - Note: The value is available as both a ``Tempo/ZoneOffset``
  /// and a ``Tempo/Duration`` for convenience in calculations.
  ///
  let before: (offset: ZoneOffset, duration: Duration)
  /// The offset after the transition occurs.
  ///
  /// - Note: The value is available as both a ``Tempo/ZoneOffset``
  /// and a ``Tempo/Duration`` for convenience in calculations.
  ///
  let after: (offset: ZoneOffset, duration: Duration)
  /// The designation for the transition.
  let designation: String
  /// Whether the period after the transition (until the next
  /// transition) is a Daylight Saving Time period.
  ///
  let isDaylightSavingTime: Bool

  let isStandardTime: Bool

  /// Initialize a new transition with an explicit transition
  /// instant, offsets, and other metadata.
  ///
  /// - Note: Transitions are generally created by the system,
  ///   and this initializer is only used for testing.
  ///
  /// - Parameters:
  ///   - instant: The instant in UTC at which the transition occurs.
  ///   - offsetBefore: The total offset before the transition occurs.
  ///   - offsetAfter: The total offset after the transition occurs.
  ///   - designation: The designation for the transition.
  ///   - isDaylightSavingTime: Whether the period is daylight saving time.
  ///   - isStandardTime: Whether the period is standard time.
  ///
  public init(
    instant: Instant,
    offsetBefore: ZoneOffset,
    offsetAfter: ZoneOffset,
    designation: String,
    isDaylightSavingTime: Bool,
    isStandardTime: Bool,
  ) {
    self.instant = instant
    self.before = (offsetBefore, .seconds(offsetBefore.totalSeconds))
    self.after = (offsetAfter, .seconds(offsetAfter.totalSeconds))
    self.designation = designation
    self.isDaylightSavingTime = isDaylightSavingTime
    self.isStandardTime = isStandardTime
    self.kind = offsetBefore < offsetAfter ? .gap : .overlap
  }
}
