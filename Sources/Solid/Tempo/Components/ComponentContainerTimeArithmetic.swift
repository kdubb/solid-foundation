//
//  ComponentContainerTimeArithmetic.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/13/25.
//

/// A component container that supports time related arithmetic.
///
public protocol ComponentContainerTimeArithmetic: ComponentContainer {

  mutating func add(time components: some ComponentContainer) throws
  mutating func addReportingOverflow(time components: some ComponentContainer) throws -> Duration

  func adding(time components: some ComponentContainer) throws -> Self
  func addingReportingOverflow(
    time components: some ComponentContainer
  ) throws -> (partialValue: Self, overflow: Duration)
}

extension ComponentContainerTimeArithmetic {

  public mutating func add(time components: some ComponentContainer) throws {
    let (result, overflow) = try addingReportingOverflow(time: components)
    if overflow != .zero {
      let allOverflows: [any ComponentKind] = [
        .hourOfDay,
        .minuteOfHour,
        .secondOfMinute,
        .nanosecondOfSecond,
      ]
      let availOverflows = components.availableComponentKinds
      let overflowed =
        allOverflows
        .map { AnyComponentKind($0) }
        .reversed()
        .drop(while: availOverflows.contains)
        .first?
        .wrapped ?? .dayOfMonth
      throw TempoError.invalidComponentValue(
        component: overflowed.id,
        reason: .unsupportedInContainer("\(self)")
      )
    }
    self = result
  }

  public func adding(time components: some ComponentContainer) throws -> Self {
    var result = self
    try result.add(time: components)
    return result
  }

  public func addingReportingOverflow(
    time components: some ComponentContainer
  ) throws -> (partialValue: Self, overflow: Duration) {
    var result = self
    let overflow = try result.addReportingOverflow(time: components)
    return (result, overflow)
  }
}
