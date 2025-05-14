//
//  FixedOffsetZoneRules.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//

/// Fixed offset zone rules for zones that do not change over time.
///
/// ``FixedOffsetZoneRules`` is a concrete implementation of the ``ZoneRules`` protocol that
/// can easily construct a ``ZoneRules`` instance for a fixed offset time without relying on
/// an existing zone definition being available via a ``ZoneRulesLoader``.
///
public final class FixedOffsetZoneRules: ZoneRules, Sendable {

  let offset: ZoneOffset

  public init(offset: ZoneOffset) {
    self.offset = offset
  }

  public var isFixedOffset: Bool {
    return true
  }

  public func standardOffset(at instant: Instant) -> ZoneOffset {
    return offset
  }

  public func daylightSavingsTime(at instant: Instant) -> ZoneOffset {
    return .zero
  }

  public func isDaylightSavingsTime(at instant: Instant) -> Bool {
    return false
  }

  public func offset(at instant: Instant) -> ZoneOffset {
    return offset
  }

  public func offset(for dateTime: LocalDateTime) -> ZoneOffset {
    return offset
  }

  public func validOffsets(for dateTime: LocalDateTime) -> ValidZoneOffsets {
    return .normal(offset)
  }

  public func isValidOffset(_ offset: ZoneOffset, for dateTime: LocalDateTime) -> Bool {
    return offset == self.offset
  }

  public func applicableTransition(for dateTime: LocalDateTime) -> ZoneTransition? {
    return nil
  }

  public func nextTransition(after instant: Instant) -> Instant? {
    return nil
  }

  public func previousTransition(before instant: Instant) -> Instant? {
    return nil
  }

  public func designation(for instant: Instant) -> String? {
    return nil
  }
}
