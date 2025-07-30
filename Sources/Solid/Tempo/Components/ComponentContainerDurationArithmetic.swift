//
//  ComponentContainerDurationArithmetic.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/13/25.
//

/// A component container that supports duration related arithmetic.
///
public protocol ComponentContainerDurationArithmetic: ComponentContainer {

  mutating func add(duration components: some ComponentContainer) throws
  mutating func addReportingOverflow(duration components: some ComponentContainer) throws -> Duration

  func adding(duration components: some ComponentContainer) throws -> Self
  func addingReportingOverflow(
    duration components: some ComponentContainer
  ) throws -> (partialValue: Self, overflow: Duration)
}

// MARK: - Default Implementations

extension ComponentContainerDurationArithmetic {

  public mutating func add(duration components: some ComponentContainer) throws {
    let (result, overflow) = try addingReportingOverflow(duration: components)
    if overflow != .zero {
      let overflows: [any ComponentKind] = [
        .numberOfDays,
        .numberOfHours,
        .numberOfMinutes,
        .numberOfSeconds,
        .nanosecondsOfSecond,
      ]
      let availOverflows = components.availableComponentKinds
      let overflowed = overflows.anys.reversed().drop(while: availOverflows.contains).first?.wrapped ?? .calendarYears
      throw TempoError.invalidComponentValue(
        component: overflowed.id,
        reason: .unsupportedInContainer("\(self)")
      )
    }
    self = result
  }

  public func adding(duration components: some ComponentContainer) throws -> Self {
    var result = self
    try result.add(duration: components)
    return result
  }

  public func addingReportingOverflow(
    duration components: some ComponentContainer
  ) throws -> (partialValue: Self, overflow: Duration) {
    var result = self
    let overflow = try result.addReportingOverflow(duration: components)
    return (result, overflow)
  }

}
