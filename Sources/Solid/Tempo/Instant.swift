//
//  Instant.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/26/25.
//

/// A specific point in time on a specific time scale.
///
public struct Instant: Equatable, Hashable, Sendable {

  public static let epoch: Self = .init(durationSinceEpoch: .zero)
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
  /// - Parameter clock: The clock to use for the current instant. Defaults to the ``Clock/system`` clock.
  /// - Returns: The current instant for the provided `clock`.
  ///
  public static func now(clock: some Clock = .system) -> Self {
    return clock.instant
  }

}

extension Instant: Comparable {

  public static func < (lhs: Self, rhs: Self) -> Bool {
    return lhs.durationSinceEpoch < rhs.durationSinceEpoch
  }

}

extension Instant {

  public static func - (lhs: Self, rhs: Self) -> Duration {
    return lhs.durationSinceEpoch - rhs.durationSinceEpoch
  }

  public static func + (lhs: Self, rhs: Duration) -> Self {
    return Self(durationSinceEpoch: lhs.durationSinceEpoch + rhs)
  }

  public static func += (lhs: inout Self, rhs: Duration) {
    lhs.durationSinceEpoch += rhs
  }

  public static func - (lhs: Self, rhs: Duration) -> Self {
    return Self(durationSinceEpoch: lhs.durationSinceEpoch - rhs)
  }

  public static func -= (lhs: inout Self, rhs: Duration) {
    lhs.durationSinceEpoch -= rhs
  }

}

extension Instant: CustomStringConvertible {

  public var description: String {
    return "\(durationSinceEpoch)"
  }
}

extension Instant: LinkedComponentContainer, ComponentBuildable {

  public static let links: [any ComponentLink<Self>] = [
    ComponentKeyPathLink(.totalNanoseconds, to: \.durationSinceEpoch.nanoseconds)
  ]

  public init(components: some ComponentContainer) {
    let durationSinceEpoch = components.value(for: .totalNanoseconds)
    self.init(durationSinceEpoch: Duration(nanoseconds: durationSinceEpoch))
  }

}

extension Instant: ComponentContainerDurationArithmetic {

  public mutating func addReportingOverflow(duration components: some ComponentContainer) -> Duration {
    let duration = Duration(components: components)
    self = self + duration
    return .zero
  }

}

extension Instant: ComponentContainerTimeArithmetic {

  public mutating func addReportingOverflow(time components: some ComponentContainer) throws -> Duration {
    let duration = Duration(components: components)
    self = self + duration
    return .zero
  }

}

// MARK: - Conversion Initializers

extension Instant {

  /// Initializes an ``Instant`` by converting an instance of the ``DateTime`` protocol.
  ///
  /// - Parameters:
  ///   - dateTime: The ``OffsetDateTime`` to convert.
  ///   - resolving: The resolution strategy to use for converting the date-time.
  ///   - calendar: The calendar system to use for the conversion.
  /// - Throws: A ``Error`` if the conversion fails due to an unresolvable local-time.
  ///
  public init(
    _ dateTime: DateTime,
    resolving: ResolutionStrategy.Options = [],
    in calendar: CalendarSystem = .default
  ) throws {
    self = try calendar.instant(from: dateTime, resolution: resolving.strategy)
  }

}

extension Instant: Codable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.init(durationSinceEpoch: try container.decode(Duration.self))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(durationSinceEpoch)
  }

}
