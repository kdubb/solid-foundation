//
//  LocalTime.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

import SolidCore


public struct LocalTime {

  public static let zero = neverThrow(try LocalTime(hour: 0, minute: 0, second: 0, nanosecond: 0))
  public static let min = neverThrow(try LocalTime(hour: 0, minute: 0, second: 0, nanosecond: 0))
  public static let max = neverThrow(try LocalTime(hour: 23, minute: 59, second: 59, nanosecond: 999_999_999))
  public static let midnight = neverThrow(try LocalTime(hour: 0, minute: 0, second: 0, nanosecond: 0))
  public static let noon = neverThrow(try LocalTime(hour: 12, minute: 0, second: 0, nanosecond: 0))

  internal typealias Storage = (hour: UInt8, minute: UInt8, second: UInt8, nanosecond: UInt32)

  internal var storage: Storage

  public var hour: Int { Int(storage.hour) }
  public var minute: Int { Int(storage.minute) }
  public var second: Int { Int(storage.second) }
  public var nanosecond: Int { Int(storage.nanosecond) }

  internal init(storage: Storage) {
    self.storage = storage
  }

  public init(
    @Validated(.hourOfDay) hour: Int,
    @Validated(.minuteOfHour) minute: Int,
    @Validated(.secondOfMinute) second: Int,
    @Validated(.nanosecondOfSecond) nanosecond: Int
  ) throws {
    self.init(
      storage: try (
        hour: UInt8($hour.get()),
        minute: UInt8($minute.get()),
        second: UInt8($second.get()),
        nanosecond: UInt32($nanosecond.get())
      )
    )
  }

  public func with(
    @ValidatedOptional(.hourOfDay) hour: Int? = nil,
    @ValidatedOptional(.minuteOfHour) minute: Int? = nil,
    @ValidatedOptional(.secondOfMinute) second: Int? = nil,
    @ValidatedOptional(.nanosecondOfSecond) nanosecond: Int? = nil,
  ) throws -> Self {
    return Self(
      storage: try (
        hour: UInt8($hour.getOrElse(self.hour)),
        minute: UInt8($minute.getOrElse(self.minute)),
        second: UInt8($second.getOrElse(self.second)),
        nanosecond: UInt32($nanosecond.getOrElse(self.nanosecond))
      )
    )
  }

  public static func now(clock: some Clock = .system, in calendar: CalendarSystem = .default) -> Self {
    return calendar.components(from: clock.instant, in: clock.zone)
  }
}

extension LocalTime: Sendable {}
extension LocalTime: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(storage.hour)
    hasher.combine(storage.minute)
    hasher.combine(storage.second)
    hasher.combine(storage.nanosecond)
  }

}

extension LocalTime: Equatable {

  public static func == (lhs: LocalTime, rhs: LocalTime) -> Bool {
    return lhs.storage == rhs.storage
  }

}

extension LocalTime: Comparable {

  public static func < (lhs: LocalTime, rhs: LocalTime) -> Bool {
    if lhs.hour != rhs.hour {
      return lhs.hour < rhs.hour
    } else if lhs.minute != rhs.minute {
      return lhs.minute < rhs.minute
    } else if lhs.second != rhs.second {
      return lhs.second < rhs.second
    } else {
      return lhs.nanosecond < rhs.nanosecond
    }
  }

}

extension LocalTime: CustomStringConvertible {

  private static let hourFormatter = fixedWidthFormat(Int.self, width: 2)
  private static let minuteFormatter = fixedWidthFormat(Int.self, width: 2)
  private static let secondFormatter = fixedWidthFormat(Int.self, width: 2)
  private static let nanosecondFormatter = format(Int.self)
    .precision(.integerAndFractionLength(integerLimits: 0...0, fractionLimits: 0...9))
    .scale(Double(1) / 1_000_000_000)
    .grouping(.never)

  public var description: String {
    let hourField = hour.formatted(Self.hourFormatter)
    let minuteField = minute.formatted(Self.minuteFormatter)
    let secondField = second.formatted(Self.secondFormatter)
    let nanosecondField =
      nanosecond != 0
      ? "\(nanosecond.formatted(Self.nanosecondFormatter))"
      : ""
    return "\(hourField):\(minuteField):\(secondField)\(nanosecondField)"
  }

}

extension LocalTime: LinkedComponentContainer, ComponentBuildable {

  public static let links: [any ComponentLink<Self>] = [
    ComponentKeyPathLink(.hourOfDay, to: \.hour),
    ComponentKeyPathLink(.minuteOfHour, to: \.minute),
    ComponentKeyPathLink(.secondOfMinute, to: \.second),
    ComponentKeyPathLink(.nanosecondOfSecond, to: \.nanosecond),
  ]

  public init(components: some ComponentContainer) {

    if let time = components as? Self {
      self = time
      return
    } else if let time = components as? DateTime {
      self = time.time
      return
    }

    self.init(
      storage: (
        hour: UInt8(components.value(for: .hourOfDay)),
        minute: UInt8(components.value(for: .minuteOfHour)),
        second: UInt8(components.value(for: .secondOfMinute)),
        nanosecond: UInt32(components.value(for: .nanosecondOfSecond)),
      )
    )
  }

}

// MARK: - Conversion Initializers

extension LocalTime {

  public init(_ dateTime: some DateTime) {
    self = dateTime.time
  }

  public init(_ duration: Duration) throws {
    self = try Self(
      hour: duration[.numberOfHours],
      minute: duration[.numberOfMinutes],
      second: duration[.numberOfSeconds],
      nanosecond: duration[.nanosecondsOfSecond],
    )
  }

}

// MARK: - Arithmentic Conformance

extension LocalTime: DurationArithmetic {

  public mutating func addReportingOverflow(
    duration components: some ComponentContainer
  ) throws -> Duration {
    let cal: CalendarSystem = .default
    let instant = try cal.instant(from: components, resolution: .default)
    let updatedInstant = instant + Duration(components: components)
    self = cal.components(from: updatedInstant, in: .utc)
    return .zero
  }

}
