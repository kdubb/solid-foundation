//
//  LocalDate.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

import SolidCore

public struct LocalDate {

  public static let min = LocalDate(storage: (year: -999_999_999, month: 1, day: 1))
  public static let max = LocalDate(storage: (year: 999_999_999, month: 12, day: 31))
  public static let epoch = LocalDate(storage: (year: 1970, month: 1, day: 1))

  internal typealias Storage = (year: Int32, month: UInt8, day: UInt8)

  internal var storage: Storage

  public var year: Int {
    get { Int(storage.year) }
  }

  public var month: Int {
    get { Int(storage.month) }
  }

  public var day: Int {
    get { Int(storage.day) }
  }

  internal init(storage: Storage) {
    self.storage = storage
  }

  internal init(valid: (year: Int, month: Int, day: Int)) {
    // swift-format-ignore: NeverUseForceTry
    try! self.init(
      year: valid.year,
      month: valid.month,
      day: valid.day
    )
  }

  public init(
    @Validated(.year) year: Int,
    @Validated(.monthOfYear) month: Int,
    @Validated(.dayOfMonth) day: Int
  ) throws {
    self.init(
      storage: try (
        year: Int32($year.get()),
        month: UInt8($month.get()),
        day: UInt8($day.get())
      )
    )
  }

  public func with(
    @ValidatedOptional(.year) year: Int? = nil,
    @ValidatedOptional(.monthOfYear) month: Int? = nil,
    @ValidatedOptional(.dayOfMonth) day: Int? = nil,
  ) throws -> Self {
    return Self(
      storage: try (
        year: Int32($year.getOrElse(self.year)),
        month: UInt8($month.getOrElse(self.month)),
        day: UInt8($day.getOrElse(self.day))
      )
    )
  }

  public static func now(clock: some Clock = .system, in calendarSystem: CalendarSystem = .default) -> Self {
    return calendarSystem.components(from: clock.instant, in: clock.zone)
  }
}

extension LocalDate: Sendable {}
extension LocalDate: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(storage.year)
    hasher.combine(storage.month)
    hasher.combine(storage.day)
  }

}
extension LocalDate: Equatable {
  public static func == (lhs: LocalDate, rhs: LocalDate) -> Bool {
    return lhs.storage == rhs.storage
  }
}

extension LocalDate: Comparable {

  public static func < (lhs: LocalDate, rhs: LocalDate) -> Bool {
    if lhs.year != rhs.year {
      return lhs.year < rhs.year
    }
    if lhs.month != rhs.month {
      return lhs.month < rhs.month
    }
    return lhs.day < rhs.day
  }
}

extension LocalDate: CustomStringConvertible {

  private static let yearFormatter = fixedWidthFormat(Int.self, width: 4)
  private static let monthFormatter = fixedWidthFormat(Int.self, width: 2)
  private static let dayFormatter = fixedWidthFormat(Int.self, width: 2)

  public var description: String {
    let yearField = year.formatted(Self.yearFormatter)
    let monthField = month.formatted(Self.monthFormatter)
    let dayField = day.formatted(Self.dayFormatter)
    return "\(yearField)-\(monthField)-\(dayField)"
  }

}

extension LocalDate: LinkedComponentContainer, ComponentBuildable {

  public static let links: [any ComponentLink<Self>] = [
    ComponentKeyPathLink(.year, to: \.year),
    ComponentKeyPathLink(.monthOfYear, to: \.month),
    ComponentKeyPathLink(.dayOfMonth, to: \.day),
  ]

  public init(components: some ComponentContainer) {
    self.init(
      storage: (
        Int32(components.valueIfPresent(for: .year) ?? 0),
        UInt8(components.valueIfPresent(for: .monthOfYear) ?? 0),
        UInt8(components.valueIfPresent(for: .dayOfMonth) ?? 0),
      )
    )
  }

}

// MARK: - Conversion Initializers

extension LocalDate {

  public init(_ dateTime: some DateTime) {
    self = dateTime.date
  }

  /// Initialize a local date from a year and an ordinal day of year.
  ///
  /// - Parameters:
  ///   - year: Proleptic year.
  ///   - ordinalDay: Ordinal day-of-year in range **1...365** (366
  ///   for leap years).
  /// - Throws: `Error.invalidComponentValue` if the
  ///   ordinal is outside the valid range for that year.
  public init(year: Int, ordinalDay: Int) throws {

    let isLeap = (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0)
    let cumDays = isLeap ? Self.cumDaysLeap : Self.cumDaysStd

    let maxOrd = cumDays[12]
    guard ordinalDay >= 1 && ordinalDay <= maxOrd else {
      throw Error.invalidComponentValue(
        component: "ordinalDay",
        reason: .outOfRange(value: "\(ordinalDay)", range: "\(1...maxOrd)")
      )
    }

    // Find month by binary search or linear scan (12 elements)
    var month = 1
    while month <= 12 && ordinalDay > cumDays[month] { month += 1 }

    let day = ordinalDay - cumDays[month - 1]
    try self.init(year: year, month: month, day: day)
  }

  private static let cumDaysLeap: [Int] = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366]
  private static let cumDaysStd: [Int] = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365]

}
