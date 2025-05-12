//
//  ZoneRules.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//

import Foundation

/// The valid zone offsets for a specific local date/time.
///
/// The enum provides semantic meaning for the results as well
/// as being a ``Swift/Collection`` of ``ZoneOffset``
/// values.
///
public enum ValidZoneOffsets {
  /// The associated local date/time is in a normal time period with a
  /// single valid offset.
  ///
  case normal(ZoneOffset)
  /// No offsets are valid for the associated local date/time because
  /// it is in a skipped time gap.
  ///
  case skipped
  /// The associated local date/time is in an ambiguous time
  /// period with multiple valid offsets.
  ///
  /// Generally there will be two valid offsets associated with a
  /// zone transition. Although, in some esoteric cases there _could_
  /// be more than two valid offsets. The offsets are ordered from
  /// earliest to latest.
  ///
  case ambiguous([ZoneOffset])
}

/// Rules governing transitions, their offsets, and if/when they occur.
///
public protocol ZoneRules: AnyObject, Sendable {

  /// Returns if the zone rules are fixed, such that the zone's offset never changes.
  ///
  /// - Returns: `true` if the zone rules are fixed, `false` otherwise.
  var isFixed: Bool { get }

  /// Returns whether the zone rules have a fixed offset.
  ///
  /// If the zone rules are fixed, this will always be `true`.
  ///
  /// - Returns: `true` if the zone rules have a fixed offset, `false` otherwise.
  ///
  var isFixedOffset: Bool { get }

  /// Returns the standard offset for the specified ``Instant``.
  ///
  /// - Parameter instant: The instant to determine the standard offset for.
  /// - Returns: The standard offset for the specified `instant`.
  ///
  func standardOffset(at instant: Instant) -> ZoneOffset

  /// Returns the amount of daylight savings time in effect at the specified instant.
  ///
  /// - Parameter instant: The instant to determine the daylight savings time for.
  /// - Returns: The amount of daylight savings time in effect at the specified `instant`.
  ///
  func daylightSavingsTime(at instant: Instant) -> ZoneOffset

  /// Returns whether the specified instant is in daylight savings time.
  /// - Parameter instant: The instant to check for daylight savings time.
  /// - Returns: `true` if the specified `instant` is in daylight savings time, `false` otherwise.
  ///
  func isDaylightSavingsTime(at instant: Instant) -> Bool

  /// Returns the total offset (seconds from UTC) for the given instant.
  ///
  /// - Parameter instant: The instant.
  /// - Returns: The total offset.
  ///
  func offset(at instant: Instant) -> ZoneOffset

  /// Returns the offsets for the given local date/time.
  ///
  /// - Parameter dateTime: The local date/time.
  /// - Returns: The valid zone offsets.
  ///
  func validOffsets(for dateTime: LocalDateTime) -> ValidZoneOffsets

  /// Determines if the given offset is valid for the specified local date/time.
  ///
  /// - Parameters:
  ///  - offset: The offset to check validity for.
  ///  - dateTime: The local date/time to check against.
  func isValidOffset(_ offset: ZoneOffset, for dateTime: LocalDateTime) -> Bool

  /// Returns the applicable transition for the given local date/time.
  ///
  /// - Parameter dateTime: The local date/time.
  /// - Returns: The transition, if any.
  ///
  func applicableTransition(for dateTime: LocalDateTime) -> ZoneTransition?

  /// Returns the offset transition, if any, that occurs after the given instant.
  ///
  /// - Parameter instant: The instant to start the search from.
  /// - Returns: The offset transition, or `nil` if there is no transition after the given instant.
  ///
  func nextTransition(after instant: Instant) -> Instant?

  /// Returns the offset transition, if any, that occurs before the given instant.
  ///
  /// - Parameter instant: The instant to start the search from.
  /// - Returns: The offset transition, or `nil` if there is no transition before the given instant.
  func previousTransition(before instant: Instant) -> Instant?

  /// Returns the designation (e.g., "PDT", "UTC") for the specified instant in the zone, if available.
  ///
  /// - Parameter instant: The instant to get the designation for.
  /// - Returns: The designation for the specified `instant`, or `nil` if unavailable.
  ///
  func designation(for instant: Instant) -> String?
}

extension ValidZoneOffsets: Sendable {}
extension ValidZoneOffsets: Equatable {}
extension ValidZoneOffsets: Hashable {}

extension ValidZoneOffsets: Collection {

  public typealias Element = ZoneOffset
  public typealias Index = Int

  public var startIndex: Int { 0 }

  public var endIndex: Int {
    switch self {
    case .skipped: 0
    case .normal: 1
    case .ambiguous(let offsets): offsets.count
    }
  }

  public var count: Int {
    switch self {
    case .skipped: 0
    case .normal: 1
    case .ambiguous(let offsets): offsets.count
    }
  }

  public func index(after i: Int) -> Int {
    precondition(i >= 0 && i < count, "Index out of bounds")
    return i + 1
  }

  public subscript(index: Int) -> ZoneOffset {
    switch self {
    case .skipped:
      preconditionFailure("No offsets in gap")
    case .normal(let offset):
      precondition(index == 0, "Index out of bounds")
      return offset
    case .ambiguous(let offsets):
      return offsets[index]
    }
  }
}

extension ZoneRules {

  public var isFixedOffset: Bool { isFixed }

}
