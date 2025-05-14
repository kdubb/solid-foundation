//
//  PeriodComponent.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//


public protocol PeriodComponent<Value>: Component {}

public protocol IntegerPeriodComponent<Value>: PeriodComponent where Value: SignedInteger {
  var unit: Unit { get }
  var range: ClosedRange<Value> { get }
}

extension Components {

  public static let calendarYears = PeriodInteger<Int>(id: .calendarYears, unit: .years, max: .max)
  public static let calendarMonths = PeriodInteger<Int>(id: .calendarMonths, unit: .months, max: .max)
  public static let calendarWeeks = PeriodInteger<Int>(id: .calendarWeeks, unit: .weeks, max: .max)
  public static let calendarDays = PeriodInteger<Int>(id: .calendarDays, unit: .days, max: .max)

}

// MARK: - Common Component Extensions

extension Component where Self == Components.PeriodInteger<Int> {

  public static var calendarYears: Self { Components.calendarYears }
  public static var calendarMonths: Self { Components.calendarMonths }
  public static var calendarWeeks: Self { Components.calendarWeeks }
  public static var calendarDays: Self { Components.calendarDays }

}

// MARK: - PeriodComponent Extensions

extension PeriodComponent where Self == Components.PeriodInteger<Int> {

  public static var calendarYears: Self { Components.calendarYears }
  public static var calendarMonths: Self { Components.calendarMonths }
  public static var calendarWeeks: Self { Components.calendarWeeks }
  public static var calendarDays: Self { Components.calendarDays }

}

extension Components {

  public struct PeriodInteger<Value>: IntegerPeriodComponent
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

}
