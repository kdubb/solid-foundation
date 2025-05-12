//
//  Period.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//


public struct Period {

  public var years: Int
  public var months: Int
  public var days: Int

  public init(years: Int, months: Int, days: Int) {
    self.years = years
    self.months = months
    self.days = days
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
    ComponentKeyPathLink(.years, to: \.years),
    ComponentKeyPathLink(.months, to: \.months),
    ComponentKeyPathLink(.days, to: \.days),
  ]

  public init(components: some ComponentContainer) {
    self.years = components.value(for: .years)
    self.months = components.value(for: .months)
    self.days = components.value(for: .days)
  }

}

extension Period {

  public func duration(
    since start: some DateTime,
    in calendar: CalendarSystem = .default
  ) throws -> Duration {

    let startInstant = calendar.nearestInstant(from: start)

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
