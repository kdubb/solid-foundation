//
//  LocalTime.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

import SolidCore


/// Time of day unrelated to any specific date or time zone.
///
public struct LocalTime {

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
    hour: Int? = nil,
    minute: Int? = nil,
    second: Int? = nil,
    nanosecond: Int? = nil,
  ) throws -> Self {
    return try Self(
      hour: hour ?? self.hour,
      minute: minute ?? self.minute,
      second: second ?? self.second,
      nanosecond: nanosecond ?? self.nanosecond
    )
  }

  public var durationSinceMidnight: Duration {
    return .hours(hour) + .minutes(minute) + .seconds(second) + .nanoseconds(nanosecond)
  }

  public static func now(clock: some Clock = .system, in calendar: GregorianCalendarSystem = .default) -> Self {
    let instant = clock.instant
    return Self(durationSinceMidnight: instant.durationSinceEpoch)
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

  public var description: String { description(style: .complete) }

  public enum DescriptionStyle: Int, Equatable, Hashable, Comparable, Sendable {
    case complete
    case `default`
    case minimal

    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
  }

  public func description(style: DescriptionStyle) -> String {
    let hourField =
      style < .default
      ? hour.formatted(Self.hourFormatter)
      : hour.formatted()
    let minuteField =
      minute != 0 || second != 0 || nanosecond != 0 || style < .minimal
      ? ":\(minute.formatted(Self.minuteFormatter))"
      : ""
    let secondField =
      second != 0 || nanosecond != 0 || style < .default
      ? ":\(second.formatted(Self.secondFormatter))"
      : ""
    let nanosecondField =
      nanosecond != 0 || style < .default
      ? (nanosecond != 0 ? "\(nanosecond.formatted(Self.nanosecondFormatter))" : ".0")
      : ""
    return "\(hourField)\(minuteField)\(secondField)\(nanosecondField)"
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

  public init(availableComponents components: some ComponentContainer) {

    if let time = components as? Self {
      self = time
      return
    } else if let time = components as? DateTime {
      self = time.time
      return
    }

    self.init(
      storage: (
        hour: UInt8(components.valueIfPresent(for: .hourOfDay) ?? 0),
        minute: UInt8(components.valueIfPresent(for: .minuteOfHour) ?? 0),
        second: UInt8(components.valueIfPresent(for: .secondOfMinute) ?? 0),
        nanosecond: UInt32(components.valueIfPresent(for: .nanosecondOfSecond) ?? 0),
      )
    )
  }

}

extension LocalTime: ComponentContainerDurationArithmetic {

  public mutating func addReportingOverflow(
    duration components: some ComponentContainer
  ) throws -> Duration {
    let totalNano = Duration(components: self) + Duration(components: components)
    self = try LocalTime(
      hour: totalNano[.hoursOfDay],
      minute: totalNano[.minutesOfHour],
      second: totalNano[.secondsOfMinute],
      nanosecond: totalNano[.nanosecondsOfSecond],
    )
    return totalNano - .nanoseconds(totalNano[.nanosecondsOfDay])
  }

}

extension LocalTime: ComponentContainerTimeArithmetic {

  public mutating func addReportingOverflow(
    time components: some ComponentContainer
  ) throws -> Duration {
    let totalNanos = Duration(components: self) + Duration(components: components)
    self = try LocalTime(
      hour: totalNanos[.hoursOfDay],
      minute: totalNanos[.minutesOfHour],
      second: totalNanos[.secondsOfMinute],
      nanosecond: totalNanos[.nanosecondsOfSecond],
    )
    return totalNanos - .nanoseconds(totalNanos[.nanosecondsOfDay])
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

  public init(durationSinceMidnight duration: Duration) {
    self = neverThrow(
      try Self(
        hour: duration[.hoursOfDay],
        minute: duration[.minutesOfHour],
        second: duration[.secondsOfMinute],
        nanosecond: duration[.nanosecondsOfSecond],
      )
    )
  }

}

extension LocalTime {

  private nonisolated(unsafe) static let parseRegex =
    /^(?<hour>[01]\d|2[0-3]):(?<minute>[0-5]\d):((?<second>[0-5]\d|60)(\.(?<nanosecond>[0-9]{1,9}))?)$/
    .asciiOnlyDigits()
    .asciiOnlyWordCharacters()
    .ignoresCase()

  /// Parses a time string per RFC-3339 (`HH:MM:SS[.sssssssss]`).
  ///
  /// If the time string represents a time in a leap second period (e.g., `23:59:60`), the time is silently rolled
  /// over to `00:00:00.000`.
  ///
  /// - Parameter string: The time string.
  /// - Returns: Parsed time instance if valid; otherwise, nil.
  ///
  public static func parse(string: String) -> Self? {

    guard let time = parseReportingRollver(string: string)?.time else {
      return nil
    }

    return time
  }

  /// Parses a time string per RFC-3339 (`HH:MM:SS[.fraction]`), reporting leap second rollover.
  ///
  /// If the time string represents a time in a leap second period (e.g., `23:59:60`), the time is rolled over to
  /// `00:00:00.000` and the `rollover` flag wil lbe `true`.
  ///
  /// - Parameter string: The full-time string.
  /// - Returns: Parsed time and flag inidicating if leap second rollover occurred.
  ///
  public static func parseReportingRollver(string: String) -> (time: Self, rollover: Bool)? {

    guard let match = string.wholeMatch(of: parseRegex) else {
      return nil
    }

    guard
      var hour = Int(match.output.hour),
      var minute = Int(match.output.minute),
      var second = Int(match.output.second),
      let nanosecond = Int(match.output.nanosecond.map { $0.rightPad(to: 9, with: "0") } ?? "0")
    else {
      return nil
    }

    // Validate second.
    let rollover: Bool
    if second == 60 {
      // Leap seconds are only valid at 23:59:60
      guard hour == 23 && minute == 59 && nanosecond == 0 else {
        return nil
      }

      rollover = true
      hour = 0
      minute = 0
      second = 0

    } else {

      rollover = false
    }

    guard let time = try? Self(hour: hour, minute: minute, second: second, nanosecond: nanosecond) else {
      return nil
    }

    return (time, rollover)
  }

}

extension LocalTime: Codable {

  enum CodingKeys: String, CodingKey {
    case hour
    case minute
    case second
    case nanosecond
  }

  public init(from decoder: any Decoder) throws {
    guard let keyed = try? decoder.container(keyedBy: CodingKeys.self) else {
      guard let values = try? decoder.singleValueContainer().decode([Int].self) else {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Must be a keyed or unkeyed container"
          )
        )
      }
      guard values.count >= 1 else {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "At least one value must be present"
          )
        )
      }
      try self.init(
        hour: values[0],
        minute: values.count > 1 ? values[1] : 0,
        second: values.count > 2 ? values[2] : 0,
        nanosecond: values.count > 3 ? values[3] : 0
      )
      return
    }
    try self.init(
      hour: keyed.decodeIfPresent(Int.self, forKey: .hour) ?? 0,
      minute: keyed.decodeIfPresent(Int.self, forKey: .minute) ?? 0,
      second: keyed.decodeIfPresent(Int.self, forKey: .second) ?? 0,
      nanosecond: keyed.decodeIfPresent(Int.self, forKey: .nanosecond) ?? 0
    )
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(hour, forKey: .hour)
    try container.encode(minute, forKey: .minute)
    try container.encode(second, forKey: .second)
    try container.encode(nanosecond, forKey: .nanosecond)
  }

}
