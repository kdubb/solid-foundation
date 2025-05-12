//
//  ComponentContainer.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/30/25.
//

import SolidCore


public protocol ComponentContainer: Sendable {

  var availableComponentIds: Set<Component.Id> { get }

  func value<C>(for component: C) -> C.Value where C: Component
  func valueIfPresent<C>(for component: C) -> C.Value? where C: Component

  func values(for componentsIds: some Sequence<Component.Id>) -> ComponentArray
  func valuesIfPresent(for componentsIds: some Sequence<Component.Id>) -> ComponentArray

  subscript<C>(_ component: C) -> C.Value? where C: Component { get }
}

public protocol MutableComponentContainer: ComponentContainer {

  mutating func setValue<C>(_ value: C.Value, for component: C) where C: Component

  mutating func removeValue<C>(for component: C) -> C.Value? where C: Component
  mutating func removeValues(for components: some Sequence<Component.Id>) -> ComponentArray

  subscript<C>(_ component: C) -> C.Value? where C: Component { get mutating set }
}


extension ComponentContainer {

  public func value<C>(for component: C) -> C.Value where C: Component {
    guard let value = valueIfPresent(for: component) else {
      fatalError("Component \(component.id) not found in container")
    }
    return value
  }

  public func values(for componentIds: some Sequence<Component.Id>) -> ComponentArray {

    var extracted = ComponentArray()

    func extractAndAppend<C>(_ component: C) where C: Component {
      let value = value(for: component)
      extracted.append(ComponentValue(component: component, value: value))
    }

    for componentId in componentIds {
      extractAndAppend(componentId.component)
    }

    return extracted
  }

  public func valuesIfPresent(for componentIds: some Sequence<Component.Id>) -> ComponentArray {

    var extracted = ComponentArray()

    func extractAndAppend<C>(_ component: C) where C: Component {
      guard let value = self[component] else {
        return
      }
      extracted.append(ComponentValue(component: component, value: value))
    }

    for component in componentIds.map(\.component) {
      extractAndAppend(component)
    }

    return extracted
  }

  public subscript<C>(_ component: C) -> C.Value? where C: Component {
    valueIfPresent(for: component)
  }

  public func matches(other components: some ComponentContainer) -> Bool {
    matches(other: components, comparing: availableComponentIds)
  }

  public func matches(other components: some ComponentContainer, comparing: Set<Component.Id>) -> Bool {
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

    for id in comparing {
      guard compare(component: id.component, in: self, and: components) else {
        return false
      }
    }
    return true
  }

}

extension MutableComponentContainer {

  public mutating func removeValues(for componentIds: some Sequence<Component.Id>) -> ComponentArray {

    var extracted = ComponentArray()

    func removeAndAppend<C>(_ component: C) where C: Component {
      if let value = removeValue(for: component) {
        extracted.append(ComponentValue(component: component, value: value))
      }
    }

    for component in componentIds.map(\.component) {
      removeAndAppend(component)
    }

    return extracted
  }

}

// MARK: - Set Operations

extension ComponentContainer {

  public func union(with other: some ComponentContainer) -> some ComponentContainer {
    return CompositeComponentContainer(containers: [self, other])
  }

  public func union(with array: [ComponentValue]) -> some ComponentContainer {
    let arrayContainer = ComponentArray(array)
    return CompositeComponentContainer(containers: [self, arrayContainer])
  }

  public func union(with array: ComponentValue...) -> some ComponentContainer {
    union(with: array)
  }

}

// MARK: - Arithmentic Conformance

extension ComponentContainer {

  public func adding(_ components: some ComponentContainer) throws -> Self {
    var duration: Duration = .zero
    var hourDelta = 0, minuteDelta = 0, secondDelta = 0, nanoDelta = 0
    var yearDelta = 0, monthDelta = 0, dayDelta = 0

    // Partition once
    for componentId in components.availableComponentIds {
      switch componentId.component {
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

      case let cvComponent as any DateComponent<Int>:
        let cvValue = components.value(for: cvComponent)
        (yearDelta, monthDelta, dayDelta) =
          accumulateDate(
            cvComponent,
            cvValue,
            (yearDelta, monthDelta, dayDelta),
          )

      default:
        throw Error.invalidComponentValue(
          component: componentId.name,
          reason: .unsupportedInContainer("\(self)")
        )
      }
    }

    var result = self

    // Duration first
    if duration != .zero, let durResult = result as? DurationArithmetic {
      result = knownSafeCast(try durResult.adding(duration: duration), to: Self.self)
    }

    // Time second – capture overflow
    var overflow: Duration = .zero
    if (hourDelta | minuteDelta | secondDelta | nanoDelta) != 0, let timeResult = result as? TimeArithmetic {
      let dTimeComps: ComponentArray = [
        .hourOfDay(hourDelta), .minuteOfHour(minuteDelta), .secondOfMinute(secondDelta),
        .nanosecondsOfSecond(nanoDelta),
      ]
      let sum = try timeResult.addingReportingOverflow(time: dTimeComps)
      overflow += sum.overflow
      result = knownSafeCast(sum.partialValue, to: Self.self)
    }

    // Date third
    if (yearDelta | monthDelta | dayDelta) != 0, var dateResult = result as? DateArithmetic {
      let dDateComps: ComponentArray = [
        .yearOfEra(yearDelta), .monthOfYear(monthDelta), .dayOfMonth(dayDelta),
      ]
      try dateResult.add(date: dDateComps)
      result = knownSafeCast(dateResult, to: Self.self)
    }

    return result
  }

  /// Adds one time‑of‑day component into the running h : m : s : ns total.
  ///
  /// Returns the new tuple `(h, m, s, ns)`; callers normalise/carry later.
  @inline(__always)
  private func accumulateTime<C>(
    _ component: C,
    _ value: Int,
    _ time: (hour: Int, minute: Int, second: Int, nanosecond: Int),
  ) -> (hour: Int, minute: Int, second: Int, nanosecond: Int) where C: Component {
    let (hour, minute, second, nanosecond) = time

    switch component.id {
    case .hourOfDay:
      return (hour + value, minute, second, nanosecond)
    case .minuteOfHour:
      return (hour, minute + value, second, nanosecond)
    case .secondOfMinute:
      return (hour, minute, second + value, nanosecond)
    case .nanosecondOfSecond:
      return (hour, minute, second, nanosecond + nanosecond)
    default:
      return (hour, minute, second, nanosecond)
    }
  }

  /// Adds one date component into the running y / mon / day total.
  ///
  /// Returns the new tuple `(y, mon, day)`.  Normalisation happens later.
  @inline(__always)
  private func accumulateDate<C>(
    _ component: C,
    _ value: Int,
    _ date: (year: Int, month: Int, day: Int),
  ) -> (year: Int, month: Int, day: Int) where C: Component {
    let (year, month, day) = date

    switch component.id {
    case .yearOfEra:
      return (year + value, month, day)
    case .monthOfYear:
      return (year, month + value, day)
    case .day, .dayOfMonth, .dayOfYear:
      return (year, month, day + value)
    default:
      return (year, month, day)
    }
  }

  public func rounded(to unit: Unit) throws -> Self {
    // TOOD: Implement truncation logic
    self
  }

}
