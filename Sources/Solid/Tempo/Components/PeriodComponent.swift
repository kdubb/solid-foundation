//
//  PeriodComponent.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//


public protocol PeriodComponent<Value>: Component {
  var unit: Unit { get }
}

extension Components {

  public static let years = Integer<Int>(id: .years, unit: .years, max: .max)
  public static let months = Integer<Int>(id: .months, unit: .months, max: .max)
  public static let weeks = Integer<Int>(id: .weeks, unit: .weeks, max: .max)
  public static let days = Integer<Int>(id: .days, unit: .days, max: .max)

}

// MARK: - Common Component Extensions

extension Component where Self == Components.Integer<Int> {

  public static var years: Self { Components.years }
  public static var months: Self { Components.months }
  public static var weeks: Self { Components.weeks }
  public static var days: Self { Components.days }

}

// MARK: - PeriodComponent Extensions

extension PeriodComponent where Self == Components.Integer<Int> {

  public static var years: Self { Components.years }
  public static var months: Self { Components.months }
  public static var weeks: Self { Components.weeks }
  public static var days: Self { Components.days }

}
