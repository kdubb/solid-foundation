//
//  DateComponent.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//


public protocol DateComponent<Value>: DateTimeComponent {
}

public protocol IntegerDateComponent: DateComponent, IntegerDateTimeComponent where Value: SignedInteger {
  var unit: Unit { get }
  var range: ClosedRange<Value> { get }
}

extension Components {

  public static let era = DateInteger<Int>(id: .era, unit: .eras, range: 0...Int.max)
  public static let year = DateInteger<Int>(id: .year, unit: .years, range: 0...Int.max)
  public static let yearOfEra = DateInteger<Int>(id: .yearOfEra, unit: .years, range: 0...Int.max)
  public static let yearForWeekOfYear = DateInteger<Int>(id: .yearForWeekOfYear, unit: .years, range: 0...Int.max)
  public static let monthOfYear = DateInteger<Int>(id: .monthOfYear, unit: .months, range: 1...12)
  public static let weekOfYear = DateInteger<Int>(id: .weekOfYear, unit: .weeks, range: 1...53)
  public static let weekOfMonth = DateInteger<Int>(id: .weekOfMonth, unit: .weeks, range: 1...5)
  public static let dayOfYear = DateInteger<Int>(id: .dayOfYear, unit: .days, range: 1...366)
  public static let dayOfMonth = DateInteger<Int>(id: .dayOfMonth, unit: .days, range: 1...31)
  public static let dayOfWeek = DateInteger<Int>(id: .dayOfWeek, unit: .days, range: 1...7)
  public static let dayOfWeekForMonth = DateInteger<Int>(id: .dayOfWeekForMonth, unit: .days, range: 1...7)

  public static let isLeapMonth = DateBoolean(id: .isLeapMonth)

}

// MARK: - Common Component Extensions

extension Component where Self == Components.DateInteger<Int> {

  public static var era: Self { Components.era }
  public static var year: Self { Components.year }
  public static var yearOfEra: Self { Components.yearOfEra }
  public static var monthOfYear: Self { Components.monthOfYear }
  public static var weekOfYear: Self { Components.weekOfYear }
  public static var weekOfMonth: Self { Components.weekOfMonth }
  public static var dayOfYear: Self { Components.dayOfYear }
  public static var dayOfMonth: Self { Components.dayOfMonth }
  public static var dayOfWeek: Self { Components.dayOfWeek }

  public static var dayOfWeekForMonth: Self { Components.dayOfWeekForMonth }
  public static var yearForWeekOfYear: Self { Components.yearForWeekOfYear }

  // Common shorthand

  public static var month: Self { Components.monthOfYear }
  public static var day: Self { Components.dayOfMonth }

}

extension Component where Self == Components.DateBoolean {

  public static var isLeapMonth: Self { Components.isLeapMonth }

}

// MARK: - DateComponent Extensions

extension DateComponent where Self == Components.DateInteger<Int> {

  public static var era: Self { Components.era }
  public static var year: Self { Components.year }
  public static var yearOfEra: Self { Components.yearOfEra }
  public static var monthOfYear: Self { Components.monthOfYear }
  public static var weekOfYear: Self { Components.weekOfYear }
  public static var weekOfMonth: Self { Components.weekOfMonth }
  public static var dayOfYear: Self { Components.dayOfYear }
  public static var dayOfMonth: Self { Components.dayOfMonth }
  public static var dayOfWeek: Self { Components.dayOfWeek }

  public static var dayOfWeekForMonth: Self { Components.dayOfWeekForMonth }
  public static var yearForWeekOfYear: Self { Components.yearForWeekOfYear }

  // Common shorthand

  public static var month: Self { Components.monthOfYear }
  public static var day: Self { Components.dayOfMonth }

}

extension DateComponent where Self == Components.DateBoolean {

  public static var isLeapMonth: Self { Components.isLeapMonth }

}

extension Components {

  public struct DateInteger<Value>: IntegerDateComponent
  where Value: SignedInteger & Sendable {

    public typealias Value = Value

    public let id: Id
    public let unit: Unit
    public let range: ClosedRange<Value>

    public init(id: Id, unit: Unit, range: ClosedRange<Value>) {
      self.id = id
      self.unit = unit
      self.range = range
    }

    public init(id: Id, unit: Unit, max: Value) {
      self.id = id
      self.unit = unit
      self.range = 0...max
    }

    public var min: Value { range.lowerBound }
    public var max: Value { range.upperBound }

    public func validate(_ value: Value) throws {
      if !range.contains(value) {
        throw TempoError.invalidComponentValue(
          component: id.name,
          reason: .outOfRange(
            value: "\(value)",
            range: "\(range.lowerBound) - \(range.upperBound)",
          )
        )
      }
    }
  }

  public struct DateBoolean: DateComponent {

    public typealias Value = Bool

    public let id: Id
    public let unit: Unit = .nan

    public func validate(_ value: Bool) throws {}
  }

}
