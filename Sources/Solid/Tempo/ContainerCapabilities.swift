//
//  ContainerCapabilities.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/4/25.
//

public protocol DurationArithmetic: Sendable {

  mutating func add(duration components: some ComponentContainer) throws
  mutating func addReportingOverflow(duration components: some ComponentContainer) throws -> Duration

  func adding(duration components: some ComponentContainer) throws -> Self
  func addingReportingOverflow(
    duration components: some ComponentContainer
  ) throws -> (partialValue: Self, overflow: Duration)
}

public protocol TimeArithmetic: Sendable {

  mutating func add(time components: some ComponentContainer) throws
  mutating func addReportingOverflow(time components: some ComponentContainer) throws -> Duration

  func adding(time components: some ComponentContainer) throws -> Self
  func addingReportingOverflow(
    time components: some ComponentContainer
  ) throws -> (partialValue: Self, overflow: Duration)
}

public protocol DateArithmetic: Sendable {

  mutating func add(date components: some ComponentContainer) throws
  mutating func addReportingOverflow(date components: some ComponentContainer) throws -> Duration

  func adding(date components: some ComponentContainer) throws -> Self
  func addingReportingOverflow(
    date components: some ComponentContainer
  ) throws -> (partialValue: Self, overflow: Duration)
}

extension DurationArithmetic {

  public mutating func add(duration components: some ComponentContainer) throws {
    let (result, overflow) = try addingReportingOverflow(duration: components)
    if overflow != .zero {
      let all: [Component.Id] = [
        .numberOfDays,
        .numberOfHours,
        .numberOfMinutes,
        .numberOfSeconds,
        .nanosecondsOfSecond,
      ]
      let avail = components.availableComponentIds
      let overflowed = all.reversed().drop(while: avail.contains).first ?? .years
      throw Error.invalidComponentValue(component: overflowed.name, reason: .unsupportedInContainer("\(self)"))
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
    var result = self, overflow: Duration = .zero
    (result, overflow) = try result.addingReportingOverflow(duration: components)
    return (result, overflow)
  }

}

extension TimeArithmetic {
  public func adding(time components: some ComponentContainer) -> Self { self }
}

extension DateArithmetic {
  public func adding(date components: some ComponentContainer) -> Self { self }
}
