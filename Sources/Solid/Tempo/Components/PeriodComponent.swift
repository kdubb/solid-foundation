//
//  PeriodComponent.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//

extension Tempo {

  public protocol PeriodComponent<Value>: Component {
    var unit: Unit { get }
  }

}

extension Tempo.Components {

  public static let years = Integer<Int>(id: .years, unit: .years, max: .max)
  public static let months = Integer<Int>(id: .months, unit: .months, max: .max)
  public static let weeks = Integer<Int>(id: .weeks, unit: .weeks, max: .max)
  public static let days = Integer<Int>(id: .days, unit: .days, max: .max)

}

// MARK: - Common Component Extensions

extension Tempo.Component where Self == Tempo.Components.Integer<Int> {

  public static var years: Self { Tempo.Components.years }
  public static var months: Self { Tempo.Components.months }
  public static var weeks: Self { Tempo.Components.weeks }
  public static var days: Self { Tempo.Components.days }

}

// MARK: - PeriodComponent Extensions

extension Tempo.PeriodComponent where Self == Tempo.Components.Integer<Int> {

  public static var years: Self { Tempo.Components.years }
  public static var months: Self { Tempo.Components.months }
  public static var weeks: Self { Tempo.Components.weeks }
  public static var days: Self { Tempo.Components.days }

}
