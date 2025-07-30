//
//  ComponentContainer.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/30/25.
//

import SolidCore

/// Any container that can store or provide component.
///
public protocol ComponentContainer: Sendable {

  /// The set of component kinds that are available in the container.
  ///
  /// - Returns: The set of component kinds that are available in the container.
  ///
  var availableComponentKinds: Set<AnyComponentKind> { get }

  /// Returns the value for the given component kind.
  ///
  /// - Parameter kind: The component kind to get the value for.
  ///
  /// - Returns: The value for the given component kind, or produces a
  /// fatal error if the component kind is not present.
  ///
  func value<K>(for kind: K) -> K.Value where K: ComponentKind

  /// Returns the value for the given component kind if it is present.
  ///
  /// - Returns: The value for the given component kind, or `nil` if the component kind is not present.
  func valueIfPresent<K>(for kind: K) -> K.Value? where K: ComponentKind

  /// Returns a new container with the values for the given component kinds.
  ///
  /// - Parameter kinds: The component kinds to get the values for.
  ///
  /// - Returns: A container with the values for the given component kinds.
  ///
  func values(for kinds: some Sequence<any ComponentKind>) -> ComponentSet

  /// Returns a new container with the values for the given component kinds that are present.
  ///
  /// - Parameter kinds: The component kinds to get the values for.
  ///
  /// - Returns: A container with the values for the given component kinds that are present.
  ///
  func valuesIfPresent(for kinds: some Sequence<any ComponentKind>) -> ComponentSet

  /// Returns the value for the given component kind, if it is present.
  ///
  subscript<K>(_ kind: K) -> K.Value? where K: ComponentKind { get }
}

public protocol MutableComponentContainer: ComponentContainer {

  /// Sets the value for the given component kind.
  ///
  /// - Parameters:
  ///   - value: The value to set.
  ///   - kind: The component kind to set the value for.
  ///
  mutating func setValue<K>(_ value: K.Value, for kind: K) where K: ComponentKind

  /// Sets the value for the given component kind.
  ///
  /// - Parameters:
  ///   - value: The value to set.
  ///   - kind: The component kind to set the value for.
  /// - Precondition: The value must be a value that can be stored in the component kind.
  ///
  mutating func setValue<K>(_ value: any Sendable, for kind: K) where K: ComponentKind

  /// Removes the value for the given component kind.
  ///
  /// - Parameter kind: The component kind to remove the value for.
  /// - Returns: The value for the given component kind, or `nil` if the component kind is not present.
  ///
  mutating func removeValue<K>(for kind: K) -> K.Value? where K: ComponentKind

  /// Removes the values for the given component kinds.
  ///
  /// - Parameter kinds: The component kinds to remove the values for.
  /// - Returns: A container with the values for the removed component kinds.
  ///
  mutating func removeValues(for kinds: some Sequence<any ComponentKind>) -> ComponentSet

  /// Returns or updates the value for the given component kind.
  ///
  subscript<K>(_ kind: K) -> K.Value? where K: ComponentKind { get mutating set }
}


extension ComponentContainer {

  public func value<K>(for kind: K) -> K.Value where K: ComponentKind {
    guard let value = valueIfPresent(for: kind) else {
      fatalError("Component \(kind.id) not found in container")
    }
    return value
  }

  public func values(for kinds: some Sequence<any ComponentKind>) -> ComponentSet {

    var extracted = ComponentSet()

    func extractAndAppend<K>(_ kind: K) where K: ComponentKind {
      let value = value(for: kind)
      extracted.setValue(value, for: kind)
    }

    for kind in kinds {
      extractAndAppend(kind)
    }

    return extracted
  }

  public func valuesIfPresent(for kinds: some Sequence<any ComponentKind>) -> ComponentSet {

    var extracted = ComponentSet()

    func extractAndAppend<K>(_ kind: K) where K: ComponentKind {
      guard let value = self[kind] else {
        return
      }
      extracted.setValue(value, for: kind)
    }

    for kind in kinds {
      extractAndAppend(kind)
    }

    return extracted
  }

  public subscript<K>(_ kind: K) -> K.Value? where K: ComponentKind {
    valueIfPresent(for: kind)
  }

  public func matches(other components: some ComponentContainer) -> Bool {
    matches(other: components, comparing: availableComponentKinds)
  }

  public func matches(other components: some ComponentContainer, comparing: some Sequence<AnyComponentKind>) -> Bool {
    func compare(
      kind: some ComponentKind,
      in lhs: some ComponentContainer,
      and rhs: some ComponentContainer
    ) -> Bool {
      guard
        let lhsValue = lhs[kind],
        let rhsValue = rhs[kind]
      else { return false }
      return lhsValue == rhsValue
    }

    for kind in comparing {
      guard compare(kind: kind, in: self, and: components) else {
        return false
      }
    }
    return true
  }

}

extension MutableComponentContainer {

  public mutating func setValue<K>(_ value: any Sendable, for kind: K) where K: ComponentKind {
    guard let value = value as? K.Value else {
      fatalError("Invalid value '\(value)` for component kind \(kind.id)")
    }
    setValue(value, for: kind)
  }

  public mutating func removeValues(for kinds: some Sequence<any ComponentKind>) -> ComponentSet {

    var extracted = ComponentSet()

    func removeAndAppend<K>(_ kind: K) where K: ComponentKind {
      if let value = removeValue(for: kind) {
        extracted.setValue(value, for: kind)
      }
    }

    for kind in kinds {
      removeAndAppend(kind)
    }

    return extracted
  }

}

// MARK: - Set Operations

extension ComponentContainer {

  public func append(_ other: some ComponentContainer) -> CompositeComponentContainer {
    return CompositeComponentContainer(containers: [self, other])
  }

  public func append(_ array: [Component]) -> CompositeComponentContainer {
    return CompositeComponentContainer(containers: [self, array])
  }

  public func append(_ array: Component...) -> CompositeComponentContainer {
    append(array)
  }

}

// MARK: - Arithmentic Conformance

extension ComponentContainer {

  public func adding(_ components: some ComponentContainer) throws -> Self {
    let (result, overflow) = try addingReportingOverflow(components)
    if overflow != .zero {
      throw TempoError.unhandledOverflow
    }
    return result
  }

  public func addingReportingOverflow(
    _ components: some ComponentContainer
  ) throws -> (partialValue: Self, overflow: Duration) {

    var duration: Duration = .zero
    var hourDelta = 0, minuteDelta = 0, secondDelta = 0, nanoDelta = 0

    // Partition once
    for componentKind in components.availableComponentKinds {
      switch componentKind.wrapped {

      case let durationKind as any DurationComponentKind:
        let durationValue = components.value(for: durationKind)
        duration += Duration(durationValue, unit: durationKind.unit)

      case let timeKind as any TimeComponentKind<Int>:
        let timeValue = components.value(for: timeKind)
        (hourDelta, minuteDelta, secondDelta, nanoDelta) =
          accumulateTime(
            timeKind,
            timeValue,
            (hourDelta, minuteDelta, secondDelta, nanoDelta)
          )

      default:
        throw TempoError.invalidComponentValue(
          component: componentKind.id,
          reason: .unsupportedInContainer("\(self)")
        )
      }
    }

    var result = self

    // Duration first
    if duration != .zero, let durResult = result as? ComponentContainerDurationArithmetic {
      result = knownSafeCast(try durResult.adding(duration: duration), to: Self.self)
    }

    // Time second – capture overflow
    let timeChanged = (hourDelta + minuteDelta + secondDelta + nanoDelta) != 0
    var overflow: Duration = .zero
    if timeChanged, let timeResult = result as? ComponentContainerTimeArithmetic {
      let timeComps: ComponentSet = [
        .hourOfDay(hourDelta),
        .minuteOfHour(minuteDelta),
        .secondOfMinute(secondDelta),
        .nanosecondsOfSecond(nanoDelta),
      ]
      let sum = try timeResult.addingReportingOverflow(time: timeComps)
      overflow += sum.overflow
      result = knownSafeCast(sum.partialValue, to: Self.self)
    }

    return (result, overflow)
  }

  /// Adds one time‑of‑day component into the running h : m : s : ns total.
  ///
  /// Returns the new tuple `(h, m, s, ns)`; callers normalise/carry later.
  @inline(__always)
  private func accumulateTime<K>(
    _ componentKind: K,
    _ value: Int,
    _ time: (hour: Int, minute: Int, second: Int, nanosecond: Int),
  ) -> (hour: Int, minute: Int, second: Int, nanosecond: Int) where K: TimeComponentKind {
    let (hour, minute, second, nanosecond) = time

    switch componentKind.id {
    case .hourOfDay:
      return (hour + value, minute, second, nanosecond)
    case .minuteOfHour:
      return (hour, minute + value, second, nanosecond)
    case .secondOfMinute:
      return (hour, minute, second + value, nanosecond)
    case .nanosecondOfSecond:
      return (hour, minute, second, nanosecond + value)
    default:
      return (hour, minute, second, nanosecond)
    }
  }

}
