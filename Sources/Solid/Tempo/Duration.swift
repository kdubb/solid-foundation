//
//  Duration.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/26/25.
//

import SolidCore
import Foundation

/// A duration of time with nanosecond precision.
///
public struct Duration {

  public static let zero = Duration(nanoseconds: 0)
  public static let min = Duration(nanoseconds: .min)
  public static let max = Duration(nanoseconds: .max)

  public private(set) var nanoseconds: Int128

  /// Initializes a `Duration` with the given number of nanoseconds.
  ///
  /// - Parameter nanoseconds: The number of nanoseconds.
  ///
  public init(nanoseconds: Int128) {
    self.nanoseconds = nanoseconds
  }

  /// Initializes a `Duration` with the given number of seconds and nanoseconds.
  ///
  /// - Parameters:
  ///  - seconds: The number of seconds.
  ///  - nanoseconds: The number of nanoseconds.
  ///
  public init(seconds: Int64, nanoseconds: Int) {
    self.nanoseconds = Int128(seconds) * 1_000_000_000 + Int128(nanoseconds)
  }

  /// Initializes a `Duration` with the given number of fractional seconds.
  ///
  /// - Parameter seconds: The number of seconds.
  ///
  public init(seconds: Double) {
    self.nanoseconds = Int128(seconds * 1_000_000_000)
  }

  internal var integerComponents: (hi: Int64, lo: Int64) {
    let hi = nanoseconds >> Int64.bitWidth
    let lo = nanoseconds & Int128(Int64.max)
    return (hi: Int64(hi), lo: Int64(lo))
  }
}

extension Duration: Sendable {}
extension Duration: Hashable {}
extension Duration: Equatable {}

extension Duration: Comparable {

  public static func < (lhs: Self, rhs: Self) -> Bool {
    return lhs.nanoseconds < rhs.nanoseconds
  }

}

extension Duration: CustomStringConvertible {

  public var description: String {
    let days = self[.numberOfDays]
    let daysField = days > 0 ? "\(days) day\(days == 1 ? "" : "s")" : ""
    let hours = self[.numberOfHours, rolledOver: true]
    let hoursField = hours > 0 ? "\(hours) hour\(hours == 1 ? "" : "s")" : ""
    let minutes = self[.numberOfMinutes]
    let minutesField = minutes > 0 ? "\(minutes) minute\(minutes == 1 ? "" : "s")" : ""
    let seconds = self[.numberOfSeconds]
    let secondsField = seconds > 0 ? "\(seconds) second\(seconds == 1 ? "" : "s")" : ""
    let nanoseconds = self[.nanosecondsOfSecond]
    let nanosecondsField = nanoseconds > 0 ? "\(nanoseconds) nanoseconds" : ""
    return [daysField, hoursField, minutesField, secondsField, nanosecondsField]
      .filter { !$0.isEmpty }
      .joined(separator: ", ")
  }

}

extension Duration: LinkedComponentContainer, ComponentBuildable {

  public static let links: [any ComponentLink<Self>] = [
    ComponentKeyPathLink(.totalNanoseconds, to: \.nanoseconds)
  ]

  public init(components: some ComponentContainer) {

    if let duration = components as? Self {
      self = duration
      return
    }

    var duration: Self = .nanoseconds(0)

    if let totalNanoseconds = components[.totalNanoseconds] {
      duration += .nanoseconds(totalNanoseconds)
    }
    if let totalMicroseconds = components[.totalMicroseconds] {
      duration += .microseconds(totalMicroseconds)
    }
    if let totalMilliseconds = components[.totalMilliseconds] {
      duration += .milliseconds(totalMilliseconds)
    }
    if let totalSeconds = components[.totalSeconds] {
      duration += .seconds(totalSeconds)
    }
    if let totalMinutes = components[.totalMinutes] {
      duration += .minutes(totalMinutes)
    }
    if let totalHours = components[.totalHours] {
      duration += .hours(totalHours)
    }
    if let totalDays = components[.totalDays] {
      duration += .days(totalDays)
    }
    if let numberOfNanoseconds = components[.numberOfNanoseconds] {
      duration += .nanoseconds(numberOfNanoseconds)
    }
    if let numberOfMicroseconds = components[.numberOfMicroseconds] {
      duration += .microseconds(numberOfMicroseconds)
    }
    if let numberOfMilliseconds = components[.numberOfMilliseconds] {
      duration += .milliseconds(numberOfMilliseconds)
    }
    if let numberOfSeconds = components[.numberOfSeconds] {
      duration += .seconds(numberOfSeconds)
    }
    if let numberOfMinutes = components[.numberOfMinutes] {
      duration += .minutes(numberOfMinutes)
    }
    if let numberOfHours = components[.numberOfHours] {
      duration += .hours(numberOfHours)
    }
    if let numberOfDays = components[.numberOfDays] {
      duration += .days(numberOfDays)
    }
    if let nanosecondsOfSecond = components[.nanosecondsOfSecond] {
      duration += .nanoseconds(nanosecondsOfSecond)
    }
    if let microsecondsOfSecond = components[.microsecondsOfSecond] {
      duration += .microseconds(microsecondsOfSecond)
    }
    if let millisecondsOfSecond = components[.millisecondsOfSecond] {
      duration += .milliseconds(millisecondsOfSecond)
    }
    if let nanoosecondOfSecond = components[.nanosecondOfSecond] {
      duration += .nanoseconds(nanoosecondOfSecond)
    }
    if let secondOfMinute = components[.secondOfMinute] {
      duration += .seconds(secondOfMinute)
    }
    if let minuteOfHour = components[.minuteOfHour] {
      duration += .minutes(minuteOfHour)
    }
    if let hourOfDay = components[.hourOfDay] {
      duration += .hours(hourOfDay)
    }
    if let zoneOffset = components[.zoneOffset] {
      duration += .seconds(zoneOffset)
    }

    self = duration
  }
}

extension Duration: ComponentContainerDurationArithmetic {

  public mutating func addReportingOverflow(duration components: some ComponentContainer) throws -> Duration {
    self = self + Duration(components: components)
    return .zero
  }

}

extension Duration: ComponentContainerTimeArithmetic {

  public mutating func addReportingOverflow(time components: some ComponentContainer) throws -> Duration {
    self = self + Duration(components: components)
    return .zero
  }
}

// MARK: - Conversion Initializers

extension Duration {

  /// Initialize a `Duration` from an integer and a ``Unit``.
  ///
  /// - Parameters:
  ///   - value: The value in `unit`s.
  ///   - unit: The unit of `value`.
  ///
  public init<I>(_ value: I, unit: Unit) where I: SignedInteger {
    switch unit {
    case .days:
      self = .days(value)
    case .hours:
      self = .hours(value)
    case .minutes:
      self = .minutes(value)
    case .seconds:
      self = .seconds(value)
    case .milliseconds:
      self = .milliseconds(value)
    case .microseconds:
      self = .microseconds(value)
    case .nanoseconds:
      self = .nanoseconds(value)
    case .eras, .centuries, .millenia, .decades, .years, .months, .weeks, .nan:
      preconditionFailure("Invalid unit for duration value: \(unit)")
    }
  }

  public init(_ componentValue: ComponentValue) {
    guard let durationComponent = componentValue.component as? any DurationComponent else {
      preconditionFailure("Invalid component value for initializing Duration: \(componentValue)")
    }

    func unwrapInit<C>(_ component: C, value: some Sendable) -> Self where C: DurationComponent {
      let typedValue = knownSafeCast(value, to: C.Value.self)
      return Self(typedValue, unit: component.unit)
    }

    self = unwrapInit(durationComponent, value: componentValue.value)
  }

  public init(_ zoneOffset: ZoneOffset) {
    self = .seconds(zoneOffset.totalSeconds)
  }

}

// MARK: - Accessors

extension Duration {

  public func valueIfPresent<C>(for component: C) -> C.Value? where C: Component {
    guard let durationComponent = component as? any DurationComponent else {
      return nil
    }
    return durationComponent.extract(from: self, rolledOver: nil) as? C.Value
  }

  public subscript<C>(_ component: C, rolledOver rolledOver: Bool? = nil) -> C.Value where C: DurationComponent {
    component.extract(from: self, rolledOver: rolledOver)
  }

}

// MARK: - Mathematical Operators

private let twoToThe64thDouble = pow(2.0, 64.0)

extension Duration {

  public static func + (lhs: Self, rhs: Self) -> Self {
    let (sum, overflow) = Int128(lhs.nanoseconds).addingReportingOverflow(rhs.nanoseconds)
    assert(!overflow, "\(String(describing: self)) overflow")
    return Self(nanoseconds: sum)
  }

  public static func += (lhs: inout Self, rhs: Self) {
    lhs = lhs + rhs
  }

  public static func - (lhs: Self, rhs: Self) -> Self {
    let (difference, overflow) = Int128(lhs.nanoseconds).subtractingReportingOverflow(rhs.nanoseconds)
    assert(!overflow, "\(String(describing: self)) overflow")
    return Self(nanoseconds: difference)
  }

  public static func -= (lhs: inout Self, rhs: Self) {
    lhs = lhs - rhs
  }

  public static prefix func - (lhs: Self) -> Self {
    return Self(nanoseconds: -lhs.nanoseconds)
  }

  public static func * (lhs: Self, rhs: Self) -> Self {
    let (product, overflow) = Int128(lhs.nanoseconds).multipliedReportingOverflow(by: rhs.nanoseconds)
    assert(!overflow, "\(String(describing: self)) overflow")
    return Self(nanoseconds: product)
  }

  public static func *= (lhs: inout Self, rhs: Self) {
    lhs = lhs * rhs
  }

  public static func * <I>(lhs: I, rhs: Self) -> Self where I: SignedInteger {
    let (product, overflow) = Int128(lhs).multipliedReportingOverflow(by: rhs.nanoseconds)
    assert(!overflow, "\(String(describing: self)) overflow")
    return Self(nanoseconds: product)
  }

  public static func * <I>(lhs: Self, rhs: I) -> Self where I: SignedInteger {
    return rhs * lhs
  }

  public static func *= <I>(lhs: inout Self, rhs: I) where I: SignedInteger {
    lhs = lhs * rhs
  }

  public static func * <F>(lhs: F, rhs: Self) -> Self where F: BinaryFloatingPoint {
    // Split rhs into two 64-bit integers
    let (rhsHi, rhsLo) = rhs.integerComponents

    // Convert to Double separately to maintain maximum precision
    let highProduct = Double(rhsHi) * Double(lhs)
    let lowProduct = Double(rhsLo) * Double(lhs)

    // Recombine & round explicitly
    let combinedProduct = highProduct * twoToThe64thDouble + lowProduct
    let product = combinedProduct.rounded(.toNearestOrAwayFromZero)

    return Self(nanoseconds: Int128(product))
  }

  public static func * <F>(lhs: Self, rhs: F) -> Self where F: BinaryFloatingPoint {
    return rhs * lhs
  }

  public static func *= <F>(lhs: inout Self, rhs: F) where F: BinaryFloatingPoint {
    lhs = lhs * rhs
  }

  public static func / (lhs: Self, rhs: Self) -> Self {
    let (quotient, overflow) = Int128(lhs.nanoseconds).dividedReportingOverflow(by: rhs.nanoseconds)
    assert(!overflow, "\(String(describing: self)) overflow")
    return Self(nanoseconds: quotient)
  }

  public static func /= (lhs: inout Self, rhs: Self) {
    lhs = lhs / rhs
  }

  public static func / <I>(lhs: Self, rhs: I) -> Self where I: SignedInteger {
    let (quotient, overflow) = Int128(lhs.nanoseconds).dividedReportingOverflow(by: Int128(rhs))
    assert(!overflow, "\(String(describing: self)) overflow")
    return Self(nanoseconds: quotient)
  }

  public static func / <F>(lhs: Self, rhs: F) -> Self where F: BinaryFloatingPoint {
    // Split lhs into two 64-bit integers
    let (lhsHi, lhsLo) = lhs.integerComponents

    // Convert to Double separately to maintain maximum precision
    let lhsDouble = Double(lhsHi) * twoToThe64thDouble + Double(lhsLo)

    // Divide & round explicitly
    let quotientDouble = lhsDouble / Double(rhs)
    let quotient = quotientDouble.rounded(.toNearestOrAwayFromZero)

    return Self(nanoseconds: Int128(quotient))
  }

  public static func /= <I>(lhs: inout Self, rhs: I) where I: SignedInteger {
    lhs = lhs / rhs
  }

}

// MARK: - Factory Methods

extension Duration {

  public static func days<I>(_ days: I) -> Self where I: SignedInteger {
    return days * Self.hours(24)
  }

  public static func days<F>(_ days: F) -> Self where F: BinaryFloatingPoint {
    return days * Self.hours(24)
  }

  public static func hours<I>(_ hours: I) -> Self where I: SignedInteger {
    return hours * Self.minutes(60)
  }

  public static func hours<F>(_ hours: F) -> Self where F: BinaryFloatingPoint {
    return hours * Self.minutes(60)
  }

  public static func minutes<I>(_ minutes: I) -> Self where I: SignedInteger {
    return minutes * Self.seconds(60)
  }

  public static func minutes<F>(_ minutes: F) -> Self where F: BinaryFloatingPoint {
    return minutes * Self.seconds(60)
  }

  public static func seconds<I>(_ seconds: I) -> Self where I: SignedInteger {
    return seconds * Self.nanoseconds(1_000_000_000)
  }

  public static func seconds<F>(_ seconds: F) -> Self where F: BinaryFloatingPoint {
    return Self(seconds: Double(seconds))
  }

  public static func milliseconds<I>(_ milliseconds: I) -> Self where I: SignedInteger {
    return Self(nanoseconds: Int128(milliseconds) * 1_000_000)
  }

  public static func microseconds<I>(_ microseconds: I) -> Self where I: SignedInteger {
    return Self(nanoseconds: Int128(microseconds) * 1_000)
  }

  public static func nanoseconds<I>(_ nanoseconds: I) -> Self where I: SignedInteger {
    return Self(nanoseconds: Int128(nanoseconds))
  }
}
