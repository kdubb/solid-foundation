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

extension Component where Self == DateComponents.Integer<Int> {

  public static var era: Self { DateComponents.era }
  public static var year: Self { DateComponents.year }
  public static var yearOfEra: Self { DateComponents.yearOfEra }
  public static var monthOfYear: Self { DateComponents.monthOfYear }
  public static var weekOfYear: Self { DateComponents.weekOfYear }
  public static var weekOfMonth: Self { DateComponents.weekOfMonth }
  public static var dayOfYear: Self { DateComponents.dayOfYear }
  public static var dayOfMonth: Self { DateComponents.dayOfMonth }
  public static var dayOfWeek: Self { DateComponents.dayOfWeek }

  public static var dayOfWeekForMonth: Self { DateComponents.dayOfWeekForMonth }
  public static var yearForWeekOfYear: Self { DateComponents.yearForWeekOfYear }

}

extension Component where Self == DateComponents.Boolean {

  public static var isLeapMonth: Self { DateComponents.isLeapMonth }

}

public enum DateComponents {

  public static let era = Integer<Int>(id: .era, unit: .eras, range: 0...Int.max)
  public static let year = Integer<Int>(id: .year, unit: .years, range: 0...Int.max)
  public static let yearOfEra = Integer<Int>(id: .yearOfEra, unit: .years, range: 0...Int.max)
  public static let yearForWeekOfYear = Integer<Int>(id: .yearForWeekOfYear, unit: .years, range: 0...Int.max)
  public static let monthOfYear = Integer<Int>(id: .monthOfYear, unit: .months, range: 1...12)
  public static let weekOfYear = Integer<Int>(id: .weekOfYear, unit: .weeks, range: 1...53)
  public static let weekOfMonth = Integer<Int>(id: .weekOfMonth, unit: .weeks, range: 1...5)
  public static let dayOfYear = Integer<Int>(id: .dayOfYear, unit: .days, range: 1...366)
  public static let dayOfMonth = Integer<Int>(id: .dayOfMonth, unit: .days, range: 1...31)
  public static let dayOfWeek = Integer<Int>(id: .dayOfWeek, unit: .days, range: 1...7)
  public static let dayOfWeekForMonth = Integer<Int>(id: .dayOfWeekForMonth, unit: .days, range: 1...7)

  public static let isLeapMonth = Boolean(id: .isLeapMonth)

  public struct Integer<Value>: IntegerDateComponent where Value: SignedInteger & Sendable {

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

  public struct Boolean: DateComponent {

    public typealias Value = Bool

    public let id: Id
    public let unit: Unit = .nan

    public func validate(_ value: Bool) throws {}
  }

}
