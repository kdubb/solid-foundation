//
//  ZoneOffset.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

extension Tempo {

  public struct ZoneOffset {

    public static let zero = neverThrow(try ZoneOffset(totalSeconds: 0))
    public static let utc = zero

    internal typealias Storage = Int32

    internal var storage: Storage

    public var totalSeconds: Int {
      get { Int(storage) }
      set { storage = Storage(newValue) }
    }

    internal var hours: Int {
      return Int(totalSeconds / 3600)
    }

    internal var minutes: Int {
      return Int((totalSeconds / 60) % 60)
    }

    internal var seconds: Int {
      return Int(totalSeconds % 60)
    }

    internal init(storage: Storage) {
      self.storage = storage
    }

    internal init(valid totalSeconds: Int) {
      // swift-format-ignore: NeverUseForceTry
      try! self.init(totalSeconds: totalSeconds)
    }

    internal init(valid duration: Duration) {
      self.init(valid: duration[.totalSeconds])
    }

    public init(totalSeconds: Int) throws {
      guard totalSeconds.magnitude <= 18 * 3600 else {
        throw
          Error
          .invalidComponentValue(
            component: "totalSeconds",
            reason: .unknown(reason: "Total offset must be less than 18 hours")
          )
      }
      self.init(storage: Storage(totalSeconds))
    }

    public init(
      @Validated(.hoursOfZoneOffset) hours: Int,
      @Validated(.minutesOfZoneOffset) minutes: Int,
      @Validated(.secondsOfZoneOffset) seconds: Int
    ) throws {
      let totalSeconds = try $hours.get() * 3600 + $minutes.get() * 60 + $seconds.get()
      if hours > 0 {
        try _minutes.assert(minutes >= 0, "Minutes must be positive when the hour is positive")
        try _seconds.assert(seconds >= 0, "Seconds must be positive when the hour is positive")
      } else if hours < 0 {
        try _minutes.assert(minutes <= 0, "Minutes must be negative when the hour is negative")
        try _seconds.assert(seconds <= 0, "Seconds must be negative when the hour is negative")
      } else if minutes > 0 {
        try _seconds.assert(seconds >= 0, "Seconds must be positive when the minutes is positive")
      } else if minutes < 0 {
        try _seconds.assert(seconds <= 0, "Seconds must be negative when the minutes is negative")
      }
      try self.init(totalSeconds: totalSeconds)
    }

    public func with(
      @ValidatedOptional(.hoursOfZoneOffset) hours: Int?,
      @ValidatedOptional(.minutesOfZoneOffset) minutes: Int?,
      @ValidatedOptional(.secondsOfZoneOffset) seconds: Int?
    ) throws -> Self {
      return try Self(
        hours: $hours.getOrElse(self.hours),
        minutes: $minutes.getOrElse(self.minutes),
        seconds: $seconds.getOrElse(self.seconds)
      )
    }
  }

}

extension Tempo.ZoneOffset: Hashable {}
extension Tempo.ZoneOffset: Equatable {}
extension Tempo.ZoneOffset: Sendable {}

extension Tempo.ZoneOffset: CustomStringConvertible {

  private static let hourFormatter = fixedWidthFormat(Int.self, width: 2)
  private static let minuteFormatter = fixedWidthFormat(Int.self, width: 2)
  private static let secondFormatter = fixedWidthFormat(Int.self, width: 2)

  /// Returns a human-readable description of the zone offset.
  ///
  /// - Note: The _current_ format is equivalent to the ISO 8601 format,
  /// but this is not guaranteed and may change in the future.
  ///
  public var description: String {
    let sign = totalSeconds >= 0 ? "+" : "-"
    let hoursField = hours.magnitude.formatted(Self.hourFormatter)
    let minutesField = minutes.magnitude.formatted(Self.minuteFormatter)
    let secondsField =
      seconds != 0
      ? ":\(seconds.magnitude.formatted(Self.secondFormatter))"
      : ""
    return "\(sign)\(hoursField):\(minutesField)\(secondsField)"
  }

}

extension Tempo.ZoneOffset: Comparable {

  public static func < (lhs: Self, rhs: Self) -> Bool {
    return lhs.totalSeconds < rhs.totalSeconds
  }

}

extension Tempo.ZoneOffset: Tempo.LinkedComponentContainer, Tempo.ComponentBuildable {

  public static let links: [any Tempo.ComponentLink<Self>] = [
    Tempo.ComponentKeyPathLink(.hoursOfZoneOffset, to: \.hours),
    Tempo.ComponentKeyPathLink(.minutesOfZoneOffset, to: \.minutes),
    Tempo.ComponentKeyPathLink(.secondsOfZoneOffset, to: \.seconds),
  ]

  public init(components: some Tempo.ComponentContainer) {
    let hours = components.valueIfPresent(for: .hoursOfZoneOffset) ?? 0
    let minutes = components.valueIfPresent(for: .minutesOfZoneOffset) ?? 0
    let seconds = components.valueIfPresent(for: .secondsOfZoneOffset) ?? 0
    let totalSeconds = hours * 3600 + minutes * 60 + seconds
    self.init(storage: Storage(totalSeconds))
  }

}
