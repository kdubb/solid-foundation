//
//  DateComponent.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//

extension Tempo {

  public protocol DateComponent<Value>: DateTimeComponent {
    var unit: Unit { get }
  }

}

extension Tempo.Components {

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

extension Tempo.Component where Self == Tempo.Components.Integer<Int> {

  public static var era: Self { Tempo.Components.era }
  public static var year: Self { Tempo.Components.year }
  public static var yearOfEra: Self { Tempo.Components.yearOfEra }
  public static var monthOfYear: Self { Tempo.Components.monthOfYear }
  public static var weekOfYear: Self { Tempo.Components.weekOfYear }
  public static var weekOfMonth: Self { Tempo.Components.weekOfMonth }
  public static var dayOfYear: Self { Tempo.Components.dayOfYear }
  public static var dayOfMonth: Self { Tempo.Components.dayOfMonth }
  public static var dayOfWeek: Self { Tempo.Components.dayOfWeek }

  public static var dayOfWeekForMonth: Self { Tempo.Components.dayOfWeekForMonth }
  public static var yearForWeekOfYear: Self { Tempo.Components.yearForWeekOfYear }

  // Common shorthand

  public static var month: Self { Tempo.Components.monthOfYear }
  public static var day: Self { Tempo.Components.dayOfMonth }

}

extension Tempo.Component where Self == Tempo.Components.Boolean {

  public static var isLeapMonth: Self { Tempo.Components.isLeapMonth }

}

// MARK: - DateComponent Extensions

extension Tempo.DateComponent where Self == Tempo.Components.Integer<Int> {

  public static var era: Self { Tempo.Components.era }
  public static var year: Self { Tempo.Components.year }
  public static var yearOfEra: Self { Tempo.Components.yearOfEra }
  public static var monthOfYear: Self { Tempo.Components.monthOfYear }
  public static var weekOfYear: Self { Tempo.Components.weekOfYear }
  public static var weekOfMonth: Self { Tempo.Components.weekOfMonth }
  public static var dayOfYear: Self { Tempo.Components.dayOfYear }
  public static var dayOfMonth: Self { Tempo.Components.dayOfMonth }
  public static var dayOfWeek: Self { Tempo.Components.dayOfWeek }

  public static var dayOfWeekForMonth: Self { Tempo.Components.dayOfWeekForMonth }
  public static var yearForWeekOfYear: Self { Tempo.Components.yearForWeekOfYear }

  // Common shorthand

  public static var month: Self { Tempo.Components.monthOfYear }
  public static var day: Self { Tempo.Components.dayOfMonth }

}

extension Tempo.DateComponent where Self == Tempo.Components.Boolean {

  public static var isLeapMonth: Self { Tempo.Components.isLeapMonth }

}
