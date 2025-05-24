//
//  ZoneRules.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//

import Foundation


/// Rules governing transitions, their offsets, and if/when they occur.
///
public protocol ZoneRules: AnyObject, Sendable {

  /// Returns whether the zone rules have a fixed offset, such that the zone's offset never changes
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
  func daylightSavingsTime(at instant: Instant) -> Duration

  /// Returns whether the specified instant is in daylight savings time.
  /// - Parameter instant: The instant to check for daylight savings time.
  /// - Returns: `true` if the specified `instant` is in daylight savings time, `false` otherwise.
  ///
  func isDaylightSavingsTime(at instant: Instant) -> Bool

  /// Returns the zone offset for the given instant.
  ///
  /// - Parameter instant: The instant to get the offset for.
  /// - Returns: The zone offset for the specified `instant`.
  ///
  func offset(at instant: Instant) -> ZoneOffset

  /// Returns the zone offset for the given local date/time.
  ///
  /// Determining the offset for a local date/time can be ambiguous when it occurs during a gap
  /// or overlap. This method returns the best available value, for normal cases the only valid
  /// offset is returned for ambiguous cases the offset **before** the transition is returned.
  ///
  /// - Note: If exact values are required, the ``validOffsets(for:)`` method should
  /// be used along with the appropriate handlign of gap/overlap periods.
  ///
  /// - Parameter dateTime: Local date/time to determine offset for.
  /// - Returns: The specific offset for normal date/time values and the offset before for ambiguous
  /// date/time values.
  ///
  func offset(for dateTime: LocalDateTime) -> ZoneOffset

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
  /// - Returns: The transition after to the specified instant, or nil, if none.
  ///
  func nextTransition(after instant: Instant) -> ZoneTransition?

  /// Returns the offset transition, if any, that occurs before the given instant.
  ///
  /// - Parameter instant: The instant to start the search from.
  /// - Returns: The transition prior to the specified instant, or nil, if none.
  ///
  func priorTransition(before instant: Instant) -> ZoneTransition?

  /// Returns the designation (e.g., "PDT", "UTC") for the specified instant in the zone.
  ///
  /// If a designation string is not available, the offset at the instant is returned.
  ///
  /// - Parameter instant: The instant to get the designation for.
  /// - Returns: The designation for the specified `instant`.
  ///
  func designation(for instant: Instant) -> String
}
