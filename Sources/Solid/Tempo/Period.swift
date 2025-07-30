//
//  Period.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//


public struct Period {

  public static let zero = Period(years: 0, months: 0, days: 0)

  public var years: Int
  public var months: Int
  public var weeks: Int
  public var days: Int

  public init(years: Int, months: Int, days: Int) {
    self.years = years
    self.months = months
    self.days = days
    self.weeks = 0
  }

  public init(weeks: Int) {
    self.weeks = weeks
    self.years = 0
    self.months = 0
    self.days = 0
  }

}

extension Period: Sendable {}
extension Period: Equatable {}
extension Period: Hashable {}

extension Period: CustomStringConvertible {

  public var description: String {
    guard years != 0, months != 0, days != 0 else {
      return "P0D"
    }
    let years = years != 0 ? "\(years)Y" : ""
    let months = months != 0 ? "\(months)M" : ""
    let days = days != 0 ? "\(days)D" : ""
    return "P\(years)\(months)\(days)"
  }
}

extension Period: LinkedComponentContainer, ComponentBuildable {

  public static let links: [any ComponentLink<Self>] = [
    ComponentKeyPathLink(.calendarYears, to: \.years),
    ComponentKeyPathLink(.calendarMonths, to: \.months),
    ComponentKeyPathLink(.calendarWeeks, to: \.weeks),
    ComponentKeyPathLink(.calendarDays, to: \.days),
  ]

  public init(components: some ComponentContainer) {
    self.years = components.valueIfPresent(for: .calendarYears) ?? 0
    self.months = components.valueIfPresent(for: .calendarMonths) ?? 0
    self.weeks = components.valueIfPresent(for: .calendarWeeks) ?? 0
    self.days = components.valueIfPresent(for: .calendarDays) ?? 0
  }

}

extension Period {

  public func adding<each C>(
    _ components: repeat (each C, (each C).Value)
  ) -> Period where repeat each C: IntegerPeriodComponentKind {
    var result = self
    for (component, value) in repeat each components {
      switch component {
      case .calendarYears:
        result.years += Int(value)
      case .calendarMonths:
        result.months += Int(value)
      case .calendarDays:
        result.days += Int(value)
      case .calendarWeeks:
        if (result.years | result.months | result.days) == 0 {
          result.weeks += Int(value)
        } else {
          result.days = Int(value) * 7
        }
      default:
        fatalError("Invalid Period Component")
      }
    }
    return result
  }

  public func duration(
    since start: some DateTime,
    resolving: ResolutionStrategy.Options = [],
    in calendar: CalendarSystem = .default
  ) throws -> Duration {

    let startInstant = try calendar.instant(from: start, resolution: resolving.strategy)

    return try duration(since: startInstant, in: calendar)
  }

  public func duration(
    since start: Instant,
    in calendar: CalendarSystem = .default
  ) throws -> Duration {

    let end = try start.adding(self)

    return end - start
  }

}
