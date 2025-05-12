//
//  DateComponent.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//


public protocol DateComponent<Value>: DateTimeComponent {
  var unit: Unit { get }
}

extension Components {

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

}

// MARK: - Common Component Extensions

extension Component where Self == Components.Integer<Int> {

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

extension Component where Self == Components.Boolean {

  public static var isLeapMonth: Self { Components.isLeapMonth }

}

// MARK: - DateComponent Extensions

extension DateComponent where Self == Components.Integer<Int> {

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

extension DateComponent where Self == Components.Boolean {

  public static var isLeapMonth: Self { Components.isLeapMonth }

}
