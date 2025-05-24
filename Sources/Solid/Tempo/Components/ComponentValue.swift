//
//  ComponentValue.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/30/25.
//


public struct ComponentValue {

  public let component: any Component
  public let value: any (Sendable & Equatable)

  private let isEqualTo: @Sendable (any Sendable & Equatable) -> Bool
  private let hashValue: @Sendable (inout Hasher) -> Void

  public init<C>(component: C, value: C.Value) where C: Component {
    self.component = component
    self.value = value
    self.isEqualTo = { other in
      guard let otherValue = other as? C.Value else {
        return false
      }
      return value == otherValue
    }
    self.hashValue = { hasher in
      hasher.combine(value)
    }
  }

  public func value<C>(forExpected component: C) -> C.Value where C: Component {
    precondition(component.id == self.component.id, "Component ID mismatch")
    guard let value = self.value as? C.Value else {
      fatalError("Value type mismatch")
    }
    return value
  }
}


extension ComponentValue {

  public static func era(_ value: Int) -> Self {
    return Self(component: .era, value: value)
  }

  public static func year(_ value: Int) -> Self {
    return Self(component: .year, value: value)
  }

  public static func yearOfEra(_ value: Int) -> Self {
    return Self(component: .yearOfEra, value: value)
  }

  public static func monthOfYear(_ value: Int) -> Self {
    return Self(component: .monthOfYear, value: value)
  }

  public static func weekOfYear(_ value: Int) -> Self {
    return Self(component: .weekOfYear, value: value)
  }

  public static func weekOfMonth(_ value: Int) -> Self {
    return Self(component: .weekOfMonth, value: value)
  }

  public static func dayOfYear(_ value: Int) -> Self {
    return Self(component: .dayOfYear, value: value)
  }

  public static func dayOfMonth(_ value: Int) -> Self {
    return Self(component: .dayOfMonth, value: value)
  }

  public static func dayOfWeek(_ value: Int) -> Self {
    return Self(component: .dayOfWeek, value: value)
  }

  public static func dayOfWeekForMonth(_ value: Int) -> Self {
    return Self(component: .dayOfWeekForMonth, value: value)
  }

  public static func yearForWeekOfYear(_ value: Int) -> Self {
    return Self(component: .yearForWeekOfYear, value: value)
  }

  public static func isLeapMonth(_ value: Bool) -> Self {
    return Self(component: .isLeapMonth, value: value)
  }

  public static func hourOfDay(_ value: Int) -> Self {
    return Self(component: .hourOfDay, value: value)
  }

  public static func minuteOfHour(_ value: Int) -> Self {
    return Self(component: .minuteOfHour, value: value)
  }

  public static func secondOfMinute(_ value: Int) -> Self {
    return Self(component: .secondOfMinute, value: value)
  }

  public static func nanosecondOfSecond(_ value: Int) -> Self {
    return Self(component: .nanosecondOfSecond, value: value)
  }

  public static func zoneOffset(_ value: Int) -> Self {
    return Self(component: .zoneOffset, value: value)
  }

  public static func zoneId(_ value: String) -> Self {
    return Self(component: .zoneId, value: value)
  }

  public static func calendarYears(_ value: Int) -> Self {
    return Self(component: .calendarYears, value: value)
  }

  public static func calendarMonths(_ value: Int) -> Self {
    return Self(component: .calendarMonths, value: value)
  }

  public static func calendarWeeks(_ value: Int) -> Self {
    return Self(component: .calendarWeeks, value: value)
  }

  public static func calendarDays(_ value: Int) -> Self {
    return Self(component: .calendarDays, value: value)
  }

  public static func numberOfDays(_ value: Int) -> Self {
    return Self(component: .numberOfDays, value: value)
  }

  public static func numberOfHours(_ value: Int) -> Self {
    return Self(component: .numberOfHours, value: value)
  }

  public static func numberOfMinutes(_ value: Int) -> Self {
    return Self(component: .numberOfMinutes, value: value)
  }

  public static func numberOfSeconds(_ value: Int) -> Self {
    return Self(component: .numberOfSeconds, value: value)
  }

  public static func numberOfMilliseconds(_ value: Int) -> Self {
    return Self(component: .numberOfMilliseconds, value: value)
  }

  public static func numberOfMicroseconds(_ value: Int) -> Self {
    return Self(component: .numberOfMicroseconds, value: value)
  }

  public static func numberOfNanoseconds(_ value: Int) -> Self {
    return Self(component: .numberOfNanoseconds, value: value)
  }

  public static func totalDays(_ value: Int) -> Self {
    return Self(component: .totalDays, value: value)
  }

  public static func totalHours(_ value: Int) -> Self {
    return Self(component: .totalHours, value: value)
  }

  public static func totalMinutes(_ value: Int) -> Self {
    return Self(component: .totalMinutes, value: value)
  }

  public static func totalSeconds(_ value: Int) -> Self {
    return Self(component: .totalSeconds, value: value)
  }

  public static func totalMilliseconds(_ value: Int128) -> Self {
    return Self(component: .totalMilliseconds, value: value)
  }

  public static func totalMicroseconds(_ value: Int128) -> Self {
    return Self(component: .totalMicroseconds, value: value)
  }

  public static func totalNanoseconds(_ value: Int128) -> Self {
    return Self(component: .totalNanoseconds, value: value)
  }

  public static func millisecondsOfSecond(_ value: Int) -> Self {
    return Self(component: .millisecondsOfSecond, value: value)
  }

  public static func microsecondsOfSecond(_ value: Int) -> Self {
    return Self(component: .microsecondsOfSecond, value: value)
  }

  public static func nanosecondsOfSecond(_ value: Int) -> Self {
    return Self(component: .nanosecondsOfSecond, value: value)
  }

}

extension ComponentValue: Equatable {

  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.component.id == rhs.component.id && lhs.isEqualTo(rhs.value)
  }
}

extension ComponentValue: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(component.id)
    hashValue(&hasher)
  }
}

extension ComponentValue: Sendable {}
