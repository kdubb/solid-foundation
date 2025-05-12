//
//  CalendarSystem.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/29/25.
//

/// An immutable computation engine for a specific type of calender
/// (e.g., Gregorian, Islamic, etc.).
///
/// The major purpose of a ``CalendarSystem`` is to convert between
/// ``Instant`` values and ``DateTime`` values (e.g.,
/// ``ZonedDateTime`` and ``OffsetDateTime``) as well as to provide
/// calendar-specific components.
///
public protocol CalendarSystem {

  /// Converts the given `Instant` to a set of components in the specified time zone.
  ///
  /// - Parameters:
  ///   - instant: The instant to convert.
  ///   - zone: The time zone of instant.
  ///   - type: The type of container to convert to.
  /// - Returns: A set of components representing the instant in the specified time zone.
  ///
  func components<C>(from instant: Instant, in zone: Zone, as type: C.Type) -> C where C: ComponentBuildable

  /// Resolves the given components to a valid set of components.
  ///
  /// - Parameters:
  ///   - components: The components to resolve.
  ///   - resolution: The resolution strategy to use.
  /// - Returns: A valid set of components.
  /// - Throws: An error if the components cannot be resolved.
  ///
  func resolve<C, S>(
    components: S,
    resolution: ResolutionStrategy
  ) throws -> C where S: ComponentContainer, C: ComponentBuildable

  func resolve<C, S>(
    _ component: C,
    from components: S,
    resolution: ResolutionStrategy
  ) throws -> C.Value where C: DateTimeComponent, S: ComponentContainer

  /// Converts the given components to an `Instant` in the specified time zone.
  ///
  /// - Parameters:
  ///   - components: The components to convert.
  ///   - resolution: The resolution strategy to use.
  /// - Returns: The instant corresponding to the components.
  /// - Throws: An error if the components cannot be converted.
  ///
  func instant(from components: some ComponentContainer, resolution: ResolutionStrategy) throws -> Instant

  func nearestInstant(from components: some ComponentContainer) -> Instant

  func range<C>(
    of component: C,
    at instant: Instant
  ) -> Range<C.Value> where C: DateTimeComponent, C.Value: FixedWidthInteger
}

extension CalendarSystem {

  /// Converts the given `Instant` to a set of components in the specified time zone.
  ///
  /// - Parameters:
  ///   - instant: The instant to convert.
  ///   - zone: The time zone of instant.
  /// - Returns: A set of components representing the instant in the specified time zone.
  ///
  public func components<C>(
    from instant: Instant,
    in zone: Zone
  ) -> C where C: ComponentBuildable {
    return components(from: instant, in: zone, as: C.self)
  }

}

extension CalendarSystem where Self == GregorianCalendarSystem {

  public static var `default`: Self {
    return .system
  }

}
