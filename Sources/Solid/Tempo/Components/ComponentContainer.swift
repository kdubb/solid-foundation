//
//  ComponentContainer.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/30/25.
//

import SolidCore


/// Any container that can store or provide component values.
///
public protocol ComponentContainer: Sendable {

  /// The set of components that are available in the container.
  ///
  /// - Returns: The set of components that are available in the container.
  ///
  var availableComponents: Set<AnyComponent> { get }

  /// Returns the value for the given component.
  ///
  /// - Parameter component: The component to get the value for.
  ///
  /// - Returns: The value for the given component, or produces a
  /// fatal error if the component is not present.
  ///
  func value<C>(for component: C) -> C.Value where C: Component

  /// Returns the value for the given component if it is present.
  ///
  /// - Returns: The value for the given component, or `nil` if the component is not present.
  func valueIfPresent<C>(for component: C) -> C.Value? where C: Component

  /// Returns a new container with the values for the given components.
  ///
  /// - Parameter components: The components to get the values for.
  ///
  /// - Returns: A container with the values for the given components.
  ///
  func values(for components: some Sequence<any Component>) -> ComponentArray

  /// Returns a new container with the values for the given components that are present.
  ///
  /// - Parameter components: The component to get the values for.
  ///
  /// - Returns: A container with the values for the given components that are present.
  ///
  func valuesIfPresent(for components: some Sequence<any Component>) -> ComponentArray

  /// Returns the value for the given component, if it is present.
  ///
  subscript<C>(_ component: C) -> C.Value? where C: Component { get }
}

public protocol MutableComponentContainer: ComponentContainer {

  /// Sets the value for the given component.
  ///
  /// - Parameters:
  ///   - value: The value to set.
  ///   - component: The component to set the value for.
  ///
  mutating func setValue<C>(_ value: C.Value, for component: C) where C: Component

  /// Sets the value for the given component.
  ///
  /// - Parameters:
  ///   - value: The value to set.
  ///   - component: The component to set the value for.
  /// - Precondition: The value must be a value that can be stored in the component.
  ///
  mutating func setValue<C>(_ value: any Sendable, for component: C) where C: Component

  /// Removes the value for the given component.
  ///
  /// - Parameter component: The component to remove the value for.
  /// - Returns: The value for the given component, or `nil` if the component is not present.
  ///
  mutating func removeValue<C>(for component: C) -> C.Value? where C: Component

  /// Removes the values for the given components.
  ///
  /// - Parameter components: The components to remove the values for.
  /// - Returns: A container with the values for the removed components.
  ///
  mutating func removeValues(for components: some Sequence<any Component>) -> ComponentArray

  /// Returns or updates the value for the given component.
  ///
  subscript<C>(_ component: C) -> C.Value? where C: Component { get mutating set }
}


extension ComponentContainer {

  public func value<C>(for component: C) -> C.Value where C: Component {
    guard let value = valueIfPresent(for: component) else {
      fatalError("Component \(component.id) not found in container")
    }
    return value
  }

  public func values(for components: some Sequence<any Component>) -> ComponentArray {

    var extracted = ComponentArray()

    func extractAndAppend<C>(_ component: C) where C: Component {
      let value = value(for: component)
      extracted.append(ComponentValue(component: component, value: value))
    }

    for component in components {
      extractAndAppend(component)
    }

    return extracted
  }

  public func valuesIfPresent(for components: some Sequence<any Component>) -> ComponentArray {

    var extracted = ComponentArray()

    func extractAndAppend<C>(_ component: C) where C: Component {
      guard let value = self[component] else {
        return
      }
      extracted.append(ComponentValue(component: component, value: value))
    }

    for component in components {
      extractAndAppend(component)
    }

    return extracted
  }

  public subscript<C>(_ component: C) -> C.Value? where C: Component {
    valueIfPresent(for: component)
  }

  public func matches(other components: some ComponentContainer) -> Bool {
    matches(other: components, comparing: availableComponents)
  }

  public func matches(other components: some ComponentContainer, comparing: Set<AnyComponent>) -> Bool {
    func compare(
      component: some Component,
      in lhs: some ComponentContainer,
      and rhs: some ComponentContainer
    ) -> Bool {
      guard
        let lhsValue = lhs[component],
        let rhsValue = rhs[component]
      else { return false }
      return lhsValue == rhsValue
    }

    for component in comparing {
      guard compare(component: component, in: self, and: components) else {
        return false
      }
    }
    return true
  }

}

extension MutableComponentContainer {

  public mutating func setValue<C>(_ value: any Sendable, for component: C) where C: Component {
    guard let value = value as? C.Value else {
      fatalError("Invalid value '\(value)` for component \(component.id)")
    }
    setValue(value, for: component)
  }

  public mutating func removeValues(for components: some Sequence<any Component>) -> ComponentArray {

    var extracted = ComponentArray()

    func removeAndAppend<C>(_ component: C) where C: Component {
      if let value = removeValue(for: component) {
        extracted.append(ComponentValue(component: component, value: value))
      }
    }

    for component in components {
      removeAndAppend(component)
    }

    return extracted
  }

}

// MARK: - Set Operations

extension ComponentContainer {

  public func append(_ other: some ComponentContainer) -> CompositeComponentContainer {
    return CompositeComponentContainer(containers: [self, other])
  }

  public func append(_ array: [ComponentValue]) -> CompositeComponentContainer {
    let arrayContainer = ComponentArray(array)
    return CompositeComponentContainer(containers: [self, arrayContainer])
  }

  public func append(_ array: ComponentValue...) -> CompositeComponentContainer {
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
    for component in components.availableComponents {

      switch component {

      case let cvComponent as any DurationComponent:
        let cvValue = components.value(for: cvComponent)
        duration += Duration(cvValue, unit: cvComponent.unit)

      case let cvComponent as any TimeComponent<Int>:
        let cvValue = components.value(for: cvComponent)
        (hourDelta, minuteDelta, secondDelta, nanoDelta) =
          accumulateTime(
            cvComponent,
            cvValue,
            (hourDelta, minuteDelta, secondDelta, nanoDelta)
          )

      default:
        throw TempoError.invalidComponentValue(
          component: component.name,
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
      let timeComps: ComponentArray = [
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
  private func accumulateTime<C>(
    _ component: C,
    _ value: Int,
    _ time: (hour: Int, minute: Int, second: Int, nanosecond: Int),
  ) -> (hour: Int, minute: Int, second: Int, nanosecond: Int) where C: TimeComponent {
    let (hour, minute, second, nanosecond) = time

    switch component.id {
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
