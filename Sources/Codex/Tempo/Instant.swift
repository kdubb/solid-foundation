//
//  Instant.swift
//  Codex
//
//  Created by Kevin Wooten on 4/26/25.
//

extension Tempo {

  /// A specific point in time on a specific time scale.
  ///
  public struct Instant: Equatable, Hashable, Sendable {

    public static let epoch: Self = .init(durationSinceEpoch: .zero)
    public static let zero: Self = .init(durationSinceEpoch: .zero)
    public static let min: Self = .init(durationSinceEpoch: .min)
    public static let max: Self = .init(durationSinceEpoch: .max)

    /// The duration since the epoch represnted by this instant.
    public private(set) var durationSinceEpoch: Duration

    /// Initializes an ``Instant`` with a given duration since the epoch.
    ///
    /// - Parameter durationSinceEpoch: The duration since the epoch.
    ///
    public init(durationSinceEpoch: Duration) {
      self.durationSinceEpoch = durationSinceEpoch
    }

    /// Returns the current instant for a given clock.
    ///
    /// - Parameter clock: The clock to use for the current instant. Defaults to the ``Tempo/Clock/system`` clock.
    /// - Returns: The current instant for the provided `clock`.
    ///
    public static func now(clock: some Clock = .system) -> Self {
      return clock.instant
    }

  }

}

extension Tempo.Instant: Comparable {

  public static func < (lhs: Self, rhs: Self) -> Bool {
    return lhs.durationSinceEpoch < rhs.durationSinceEpoch
  }

}

extension Tempo.Instant {

  public static func - (lhs: Self, rhs: Self) -> Tempo.Duration {
    return lhs.durationSinceEpoch - rhs.durationSinceEpoch
  }

  public static func + (lhs: Self, rhs: Tempo.Duration) -> Self {
    return Self(durationSinceEpoch: lhs.durationSinceEpoch + rhs)
  }

  public static func += (lhs: inout Self, rhs: Tempo.Duration) {
    lhs.durationSinceEpoch += rhs
  }

  public static func - (lhs: Self, rhs: Tempo.Duration) -> Self {
    return Self(durationSinceEpoch: lhs.durationSinceEpoch - rhs)
  }

  public static func -= (lhs: inout Self, rhs: Tempo.Duration) {
    lhs.durationSinceEpoch -= rhs
  }

}

extension Tempo.Instant: CustomStringConvertible {

  public var description: String {
    return "\(durationSinceEpoch)"
  }
}

extension Tempo.Instant: Tempo.LinkedComponentContainer, Tempo.ComponentBuildable {

  public static let links: [any Tempo.ComponentLink<Self>] = [
    Tempo.ComponentKeyPathLink(.durationSinceEpoch, to: \.durationSinceEpoch.nanoseconds)
  ]

  public init(components: some Tempo.ComponentContainer) {
    let durationSinceEpoch = components.value(for: .durationSinceEpoch)
    self.init(durationSinceEpoch: Tempo.Duration(nanoseconds: durationSinceEpoch))
  }
}

// MARK: - Conversion Initializers

extension Tempo.Instant {

  /// Initializes an ``Tempo/Instant`` by converting an instance of the ``Tempo/DateTime`` protocol.
  ///
  /// - Parameters:
  ///   - dateTime: The ``Tempo/OffsetDateTime`` to convert.
  ///   - resolving: The resolution strategy to use for converting the date-time.
  ///   - calendar: The calendar system to use for the conversion.
  /// - Throws: A ``Tempo/Error`` if the conversion fails due to an unresolvable local-time.
  ///
  public init(
    _ dateTime: Tempo.DateTime,
    resolving: Tempo.ResolutionStrategy.Options = [],
    in calendar: Tempo.CalendarSystem = .default
  ) throws {
    self = try calendar.instant(from: dateTime, resolution: resolving.strategy)
  }

}
