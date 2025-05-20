//
//  ZoneTransition.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//

/// A transition from one offset to another at a specific point in time.
///
public final class ZoneTransition {

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

  /// Zone details before the transition occurs.
  public let before: (offset: ZoneOffset, local: LocalDateTime)

  /// Zone details after the transition occurs.
  public let after: (offset: ZoneOffset, local: LocalDateTime)


  public var localBoundaries: (start: LocalDateTime, end: LocalDateTime) {
    switch kind {
    case .gap:
      return (before.local, after.local)
    case .overlap:
      return (after.local, before.local)
    }
  }

  public var duration: Duration {
    return Duration(after.offset) - Duration(before.offset)
  }

  /// The designation for the transition.
  public let designation: String

  /// Whether the period after the transition (until the next
  /// transition) is a Daylight Saving Time period.
  ///
  public let isDaylightSavingTime: Bool

  /// Whether the period after the transition (until the next
  /// transition) is a Standard Time period.
  ///
  public var isStandardTime: Bool {
    return !isDaylightSavingTime
  }

  /// Initialize a new transition with an explicit transition
  /// instant, offsets, and other metadata.
  ///
  /// - Note: Transitions are generally created by the system,
  ///   and this initializer is only used for testing.
  ///
  /// - Parameters:
  ///   - kind: The kind of transition, either gap or overlap.
  ///   - instant: The instant in UTC at which the transition occurs.
  ///   - offsetBefore: The total offset before the transition occurs.
  ///   - offsetAfter: The total offset after the transition occurs.
  ///   - localBefore: The local time before the transition.
  ///   - localAfter: The local time after the transition.
  ///   - designation: The designation for the transition.
  ///   - isDaylightSavingTime: Whether the period is daylight saving time.
  ///
  public init(
    kind: Kind,
    instant: Instant,
    offsetBefore: ZoneOffset,
    offsetAfter: ZoneOffset,
    localBefore: LocalDateTime,
    localAfter: LocalDateTime,
    designation: String,
    isDaylightSavingTime: Bool
  ) {
    self.kind = kind
    self.instant = instant
    self.before = (offsetBefore, localBefore)
    self.after = (offsetAfter, localAfter)
    self.designation = designation
    self.isDaylightSavingTime = isDaylightSavingTime
  }

  public func contains(_ dateTime: LocalDateTime) -> Bool {
    return dateTime >= localBoundaries.start && dateTime < localBoundaries.end
  }

  public func validOffsets(for dateTime: LocalDateTime) -> ValidZoneOffsets? {

    guard contains(dateTime) else {
      return nil
    }

    switch kind {
    case .gap:
      return .skipped(self)

    case .overlap:
      return .ambiguous([before.offset, after.offset])
    }
  }
}

extension ZoneTransition: Sendable {}

extension ZoneTransition: CustomStringConvertible {

  public var description: String {
    """
    ZoneTransition(\
    \("\(kind)".uppercased()) at \(localBoundaries.start), \
    \(before.offset) to \(after.offset)\
    )
    """
  }

}

extension ZoneTransition {

  internal static func from(
    instant: Instant,
    offsetBefore: ZoneOffset,
    offsetAfter: ZoneOffset,
    designation: String,
    isDaylightSavingTime: Bool,
    in calendarSystem: GregorianCalendarSystem,
  ) -> Self {

    let kind: ZoneTransition.Kind = offsetBefore < offsetAfter ? .gap : .overlap

    let localBefore = calendarSystem.localDateTime(instant: instant, at: offsetBefore)
    let localAfter = calendarSystem.localDateTime(instant: instant, at: offsetAfter)

    return Self(
      kind: kind,
      instant: instant,
      offsetBefore: offsetBefore,
      offsetAfter: offsetAfter,
      localBefore: localBefore,
      localAfter: localAfter,
      designation: designation,
      isDaylightSavingTime: isDaylightSavingTime,
    )
  }

}
