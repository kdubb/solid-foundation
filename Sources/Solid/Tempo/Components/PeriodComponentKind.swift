//
//  PeriodComponentKind.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//


public protocol PeriodComponentKind<Value>: ComponentKind {}

public protocol IntegerPeriodComponentKind<Value>: PeriodComponentKind where Value: SignedInteger {
  var unit: Unit { get }
  var range: ClosedRange<Value> { get }
}

extension ComponentKind where Self == PeriodComponentKinds.Integer<Int> {

  public static var calendarYears: Self { PeriodComponentKinds.calendarYears }
  public static var calendarMonths: Self { PeriodComponentKinds.calendarMonths }
  public static var calendarWeeks: Self { PeriodComponentKinds.calendarWeeks }
  public static var calendarDays: Self { PeriodComponentKinds.calendarDays }

}

public enum PeriodComponentKinds {

  public static let calendarYears = Integer<Int>(id: .calendarYears, unit: .years, max: .max)
  public static let calendarMonths = Integer<Int>(id: .calendarMonths, unit: .months, max: .max)
  public static let calendarWeeks = Integer<Int>(id: .calendarWeeks, unit: .weeks, max: .max)
  public static let calendarDays = Integer<Int>(id: .calendarDays, unit: .days, max: .max)

  public struct Integer<Value>: IntegerPeriodComponentKind
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
          component: id,
          reason: .outOfRange(
            value: "\(value)",
            range: "\(range.lowerBound) - \(range.upperBound)",
          )
        )
      }
    }
  }

}
