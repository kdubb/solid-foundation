//
//  Period.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

extension Tempo {

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

}

extension Tempo.Period: Sendable {}
extension Tempo.Period: Equatable {}
extension Tempo.Period: Hashable {}

extension Tempo.Period: CustomStringConvertible {

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

extension Tempo.Period: Tempo.LinkedComponentContainer, Tempo.ComponentBuildable {

  public static let links: [any Tempo.ComponentLink<Self>] = [
    Tempo.ComponentKeyPathLink(.years, to: \.years),
    Tempo.ComponentKeyPathLink(.months, to: \.months),
    Tempo.ComponentKeyPathLink(.days, to: \.days),
  ]

  public init(components: some Tempo.ComponentContainer) {
    self.years = components.value(for: .years)
    self.months = components.value(for: .months)
    self.days = components.value(for: .days)
  }

}

extension Tempo.Period {

  public func duration(
    since start: some Tempo.DateTime,
    in calendar: Tempo.CalendarSystem = .default
  ) throws -> Tempo.Duration {

    let startInstant = calendar.nearestInstant(from: start)

    return try duration(since: startInstant, in: calendar)
  }

  public func duration(
    since start: Tempo.Instant,
    in calendar: Tempo.CalendarSystem = .default
  ) throws -> Tempo.Duration {

    let end = try start.adding(self)

    return end - start
  }

}
