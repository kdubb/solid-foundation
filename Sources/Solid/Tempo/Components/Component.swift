//
//  Component.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/30/25.
//


public struct Component {

  public let kind: any ComponentKind
  public let value: any Equatable & Hashable & Sendable

  private let isEqualTo: @Sendable (any Sendable & Equatable) -> Bool
  private let hashValue: @Sendable (inout Hasher) -> Void

  public init<C>(kind: C, value: C.Value) where C: ComponentKind {
    self.kind = kind
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

  public func value<C>(forExpected kind: C) -> C.Value where C: ComponentKind {
    precondition(kind.id == self.kind.id, "Component ID mismatch")
    guard let value = self.value as? C.Value else {
      fatalError("Value type mismatch")
    }
    return value
  }
}


extension Component {

  public static func era(_ value: Int) -> Self {
    return Self(kind: .era, value: value)
  }

  public static func year(_ value: Int) -> Self {
    return Self(kind: .year, value: value)
  }

  public static func yearOfEra(_ value: Int) -> Self {
    return Self(kind: .yearOfEra, value: value)
  }

  public static func monthOfYear(_ value: Int) -> Self {
    return Self(kind: .monthOfYear, value: value)
  }

  public static func weekOfYear(_ value: Int) -> Self {
    return Self(kind: .weekOfYear, value: value)
  }

  public static func weekOfMonth(_ value: Int) -> Self {
    return Self(kind: .weekOfMonth, value: value)
  }

  public static func dayOfYear(_ value: Int) -> Self {
    return Self(kind: .dayOfYear, value: value)
  }

  public static func dayOfMonth(_ value: Int) -> Self {
    return Self(kind: .dayOfMonth, value: value)
  }

  public static func dayOfWeek(_ value: Int) -> Self {
    return Self(kind: .dayOfWeek, value: value)
  }

  public static func dayOfWeekForMonth(_ value: Int) -> Self {
    return Self(kind: .dayOfWeekForMonth, value: value)
  }

  public static func yearForWeekOfYear(_ value: Int) -> Self {
    return Self(kind: .yearForWeekOfYear, value: value)
  }

  public static func isLeapMonth(_ value: Bool) -> Self {
    return Self(kind: .isLeapMonth, value: value)
  }

  public static func hourOfDay(_ value: Int) -> Self {
    return Self(kind: .hourOfDay, value: value)
  }

  public static func minuteOfHour(_ value: Int) -> Self {
    return Self(kind: .minuteOfHour, value: value)
  }

  public static func secondOfMinute(_ value: Int) -> Self {
    return Self(kind: .secondOfMinute, value: value)
  }

  public static func nanosecondOfSecond(_ value: Int) -> Self {
    return Self(kind: .nanosecondOfSecond, value: value)
  }

  public static func zoneOffset(_ value: Int) -> Self {
    return Self(kind: .zoneOffset, value: value)
  }

  public static func zoneId(_ value: String) -> Self {
    return Self(kind: .zoneId, value: value)
  }

  public static func calendarYears(_ value: Int) -> Self {
    return Self(kind: .calendarYears, value: value)
  }

  public static func calendarMonths(_ value: Int) -> Self {
    return Self(kind: .calendarMonths, value: value)
  }

  public static func calendarWeeks(_ value: Int) -> Self {
    return Self(kind: .calendarWeeks, value: value)
  }

  public static func calendarDays(_ value: Int) -> Self {
    return Self(kind: .calendarDays, value: value)
  }

  public static func numberOfDays(_ value: Int) -> Self {
    return Self(kind: .numberOfDays, value: value)
  }

  public static func numberOfHours(_ value: Int) -> Self {
    return Self(kind: .numberOfHours, value: value)
  }

  public static func numberOfMinutes(_ value: Int) -> Self {
    return Self(kind: .numberOfMinutes, value: value)
  }

  public static func numberOfSeconds(_ value: Int) -> Self {
    return Self(kind: .numberOfSeconds, value: value)
  }

  public static func numberOfMilliseconds(_ value: Int) -> Self {
    return Self(kind: .numberOfMilliseconds, value: value)
  }

  public static func numberOfMicroseconds(_ value: Int) -> Self {
    return Self(kind: .numberOfMicroseconds, value: value)
  }

  public static func numberOfNanoseconds(_ value: Int) -> Self {
    return Self(kind: .numberOfNanoseconds, value: value)
  }

  public static func totalDays(_ value: Int) -> Self {
    return Self(kind: .totalDays, value: value)
  }

  public static func totalHours(_ value: Int) -> Self {
    return Self(kind: .totalHours, value: value)
  }

  public static func totalMinutes(_ value: Int) -> Self {
    return Self(kind: .totalMinutes, value: value)
  }

  public static func totalSeconds(_ value: Int) -> Self {
    return Self(kind: .totalSeconds, value: value)
  }

  public static func totalMilliseconds(_ value: Int128) -> Self {
    return Self(kind: .totalMilliseconds, value: value)
  }

  public static func totalMicroseconds(_ value: Int128) -> Self {
    return Self(kind: .totalMicroseconds, value: value)
  }

  public static func totalNanoseconds(_ value: Int128) -> Self {
    return Self(kind: .totalNanoseconds, value: value)
  }

  public static func millisecondsOfSecond(_ value: Int) -> Self {
    return Self(kind: .millisecondsOfSecond, value: value)
  }

  public static func microsecondsOfSecond(_ value: Int) -> Self {
    return Self(kind: .microsecondsOfSecond, value: value)
  }

  public static func nanosecondsOfSecond(_ value: Int) -> Self {
    return Self(kind: .nanosecondsOfSecond, value: value)
  }

}

extension Component: Equatable {

  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.kind.id == rhs.kind.id && lhs.isEqualTo(rhs.value)
  }
}

extension Component: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(kind.id)
    hashValue(&hasher)
  }
}

extension Component: Sendable {}
