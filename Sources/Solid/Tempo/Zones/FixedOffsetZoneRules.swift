//
//  FixedOffsetZoneRules.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//

extension Tempo {

  /// Fixed offset zone rules for zones that do not change over time.
  ///
  public final class FixedOffsetZoneRules: ZoneRules, Sendable {

    let offset: ZoneOffset

    public init(offset: ZoneOffset) {
      self.offset = offset
    }

    public var isFixed: Bool {
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
}
