//
//  DurationComponent.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//

extension Tempo {

  public protocol DurationComponent<Value>: Component where Value: FixedWidthInteger {
    func extract(from duration: Duration, rolledOver: Bool?) -> Value
  }

}

extension Tempo.Components {

  public static let numberOfDays = DurationInteger<Int>(id: .numberOfDays, unit: .days)
  public static let numberOfHours = DurationInteger<Int>(id: .numberOfHours, unit: .hours)
  public static let numberOfMinutes = DurationInteger<Int>(id: .numberOfMinutes, unit: .minutes)
  public static let numberOfSeconds = DurationInteger<Int>(id: .numberOfSeconds, unit: .seconds)
  public static let numberOfMilliseconds = DurationInteger<Int>(id: .numberOfMilliseconds, unit: .milliseconds)
  public static let numberOfMicroseconds = DurationInteger<Int>(id: .numberOfMicroseconds, unit: .microseconds)
  public static let numberOfNanoseconds = DurationInteger<Int>(id: .numberOfNanoseconds, unit: .nanoseconds)

  public static let totalDays = DurationInteger<Int>(
    id: .totalDays,
    unit: .days,
    rolledOverDefault: false,
    isTotal: true
  )
  public static let totalHours = DurationInteger<Int>(
    id: .totalHours,
    unit: .hours,
    rolledOverDefault: false,
    isTotal: true
  )
  public static let totalMinutes = DurationInteger<Int>(
    id: .totalMinutes,
    unit: .minutes,
    isTotal: true
  )
  public static let totalSeconds = DurationInteger<Int>(
    id: .totalSeconds,
    unit: .seconds,
    isTotal: true
  )
  public static let totalMilliseconds = DurationInteger<Int128>(
    id: .totalMilliseconds,
    unit: .milliseconds,
    isTotal: true
  )
  public static let totalMicroseconds = DurationInteger<Int128>(
    id: .totalMicroseconds,
    unit: .microseconds,
    isTotal: true
  )
  public static let totalNanoseconds = DurationInteger<Int128>(
    id: .totalNanoseconds,
    unit: .nanoseconds,
    isTotal: true
  )
  public static let hoursOfDay = DurationInteger<Int>(
    id: .hoursOfDay,
    unit: .hours,
    parentUnit: .days,
    rolledOverDefault: false
  )
  public static let minutesOfDay = DurationInteger<Int>(
    id: .minutesOfDay,
    unit: .minutes,
    parentUnit: .days,
    rolledOverDefault: false
  )
  public static let secondsOfDay = DurationInteger<Int>(
    id: .secondsOfDay,
    unit: .seconds,
    parentUnit: .days,
    rolledOverDefault: false
  )
  public static let millisecondsOfDay = DurationInteger<Int>(
    id: .millisecondsOfDay,
    unit: .milliseconds,
    parentUnit: .days,
    rolledOverDefault: false
  )
  public static let microsecondsOfDay = DurationInteger<Int>(
    id: .microsecondsOfDay,
    unit: .microseconds,
    parentUnit: .days,
    rolledOverDefault: false
  )
  public static let nanosecondsOfDay = DurationInteger<Int>(
    id: .nanosecondsOfDay,
    unit: .nanoseconds,
    parentUnit: .days,
    rolledOverDefault: false
  )
  public static let minutesOfHour = DurationInteger<Int>(
    id: .minutesOfHour,
    unit: .minutes,
    parentUnit: .hours,
    rolledOverDefault: false
  )
  public static let secondsOfHour = DurationInteger<Int>(
    id: .secondsOfHour,
    unit: .seconds,
    parentUnit: .hours,
    rolledOverDefault: false
  )
  public static let millisecondsOfHour = DurationInteger<Int>(
    id: .millisecondsOfHour,
    unit: .milliseconds,
    parentUnit: .hours,
    rolledOverDefault: false
  )
  public static let microsecondsOfHour = DurationInteger<Int>(
    id: .microsecondsOfHour,
    unit: .microseconds,
    parentUnit: .hours,
    rolledOverDefault: false
  )
  public static let nanosecondsOfHour = DurationInteger<Int>(
    id: .nanosecondsOfHour,
    unit: .nanoseconds,
    parentUnit: .hours,
    rolledOverDefault: false
  )
  public static let secondsOfMinute = DurationInteger<Int>(
    id: .secondsOfMinute,
    unit: .seconds,
    parentUnit: .minutes,
    rolledOverDefault: false
  )
  public static let millisecondsOfMinute = DurationInteger<Int>(
    id: .millisecondsOfMinute,
    unit: .milliseconds,
    parentUnit: .minutes,
    rolledOverDefault: false
  )
  public static let microsecondsOfMinute = DurationInteger<Int>(
    id: .microsecondsOfMinute,
    unit: .microseconds,
    parentUnit: .minutes,
    rolledOverDefault: false
  )
  public static let nanosecondsOfMinute = DurationInteger<Int>(
    id: .nanosecondsOfMinute,
    unit: .nanoseconds,
    parentUnit: .minutes,
    rolledOverDefault: false
  )
  public static let millisecondsOfSecond = DurationInteger<Int>(
    id: .millisecondsOfSecond,
    unit: .milliseconds,
    parentUnit: .seconds,
    rolledOverDefault: false
  )
  public static let microsecondsOfSecond = DurationInteger<Int>(
    id: .microsecondsOfSecond,
    unit: .microseconds,
    parentUnit: .seconds,
    rolledOverDefault: false
  )
  public static let nanosecondsOfSecond = DurationInteger<Int>(
    id: .nanosecondsOfSecond,
    unit: .nanoseconds,
    parentUnit: .seconds,
    rolledOverDefault: false
  )

  public enum DurationUnitSize: UInt128 {
    case days = 86_400_000_000_000
    case hours = 3_600_000_000_000
    case minutes = 60_000_000_000
    case seconds = 1_000_000_000
    case milliseconds = 1_000_000
    case microseconds = 1_000
    case nanoseconds = 1

    var rollover: UInt128? {
      switch self {
      case .days: return nil
      case .hours: return 24
      case .minutes: return 60
      case .seconds: return 60
      case .milliseconds: return 1_000
      case .microseconds: return 1_000
      case .nanoseconds: return 1_000
      }
    }
  }

  public struct DurationInteger<Value: FixedWidthInteger & SignedInteger>: Tempo.DurationComponent {

    public typealias Value = Value

    public let id: Id
    public let unit: Tempo.Unit
    public let unitSize: UInt128
    public let rollover: UInt128?
    public let rolledOverDefault: Bool
    public let parentUnitSize: UInt128?
    public let totalUnitSize: Int128
    public let isTotal: Bool

    public init(
      id: Id,
      unit: Tempo.Unit,
      parentUnit: Tempo.Unit? = nil,
      rolledOverDefault: Bool = true,
      isTotal: Bool = false
    ) {
      let unitSize = unit.unitSize
      self.id = id
      self.unit = unit
      self.unitSize = unitSize.rawValue
      self.rollover = unitSize.rollover
      self.rolledOverDefault = rolledOverDefault
      self.parentUnitSize = parentUnit?.unitSize.rawValue
      self.totalUnitSize = Int128(unitSize.rawValue)
      self.isTotal = isTotal
    }

    public func validate(_ value: Value) throws {}

    public func extract(from duration: Tempo.Duration, rolledOver: Bool?) -> Value {
      if isTotal {
        return Value(duration.nanoseconds / totalUnitSize)
      } else if let parentUnitSize {
        return Value((duration.nanoseconds.magnitude / unitSize) % (parentUnitSize / unitSize))
      } else {
        let rolledOver = rolledOver ?? rolledOverDefault
        let ns = duration.nanoseconds
        let sign = Value(ns.signum())
        let magnitude = ns.magnitude

        let value = magnitude / unitSize
        let reduced =
          if rolledOver, let rollover {
            value % rollover
          } else {
            value
          }

        return sign * Value(reduced)
      }
    }
  }
}

// MARK: - Common Component Extensions

extension Tempo.Component where Self == Tempo.Components.DurationInteger<Int> {

  public static var numberOfDays: Self { Tempo.Components.numberOfDays }
  public static var numberOfHours: Self { Tempo.Components.numberOfHours }
  public static var numberOfMinutes: Self { Tempo.Components.numberOfMinutes }
  public static var numberOfSeconds: Self { Tempo.Components.numberOfSeconds }
  public static var numberOfMilliseconds: Self { Tempo.Components.numberOfMilliseconds }
  public static var numberOfMicroseconds: Self { Tempo.Components.numberOfMicroseconds }
  public static var numberOfNanoseconds: Self { Tempo.Components.numberOfNanoseconds }

  public static var totalDays: Self { Tempo.Components.totalDays }
  public static var totalHours: Self { Tempo.Components.totalHours }
  public static var totalMinutes: Self { Tempo.Components.totalMinutes }
  public static var totalSeconds: Self { Tempo.Components.totalSeconds }

  public static var hoursOfDay: Self { Tempo.Components.hoursOfDay }
  public static var minutesOfDay: Self { Tempo.Components.minutesOfDay }
  public static var secondsOfDay: Self { Tempo.Components.secondsOfDay }
  public static var millisecondsOfDay: Self { Tempo.Components.millisecondsOfSecond }
  public static var microsecondsOfDay: Self { Tempo.Components.microsecondsOfSecond }
  public static var nanosecondsOfDay: Self { Tempo.Components.nanosecondsOfDay }

  public static var minutesOfHour: Self { Tempo.Components.minutesOfHour }
  public static var secondsOfHour: Self { Tempo.Components.secondsOfHour }
  public static var millisecondsOfHour: Self { Tempo.Components.millisecondsOfHour }
  public static var microsecondsOfHour: Self { Tempo.Components.microsecondsOfHour }
  public static var nanosecondsOfHour: Self { Tempo.Components.nanosecondsOfHour }

  public static var secondsOfMinute: Self { Tempo.Components.secondsOfMinute }
  public static var millisecondsOfMinute: Self { Tempo.Components.millisecondsOfMinute }
  public static var microsecondsOfMinute: Self { Tempo.Components.microsecondsOfMinute }
  public static var nanosecondsOfMinute: Self { Tempo.Components.nanosecondsOfMinute }

  public static var millisecondsOfSecond: Self { Tempo.Components.millisecondsOfSecond }
  public static var microsecondsOfSecond: Self { Tempo.Components.microsecondsOfSecond }
  public static var nanosecondsOfSecond: Self { Tempo.Components.nanosecondsOfSecond }

}

extension Tempo.Component where Self == Tempo.Components.DurationInteger<Int128> {

  public static var totalMilliseconds: Self { Tempo.Components.totalMilliseconds }
  public static var totalMicroseconds: Self { Tempo.Components.totalMicroseconds }
  public static var totalNanoseconds: Self { Tempo.Components.totalNanoseconds }

}

// MARK: - DurationComponent Extensions

extension Tempo.DurationComponent where Self == Tempo.Components.DurationInteger<Int> {

  public static var numberOfDays: Self { Tempo.Components.numberOfDays }
  public static var numberOfHours: Self { Tempo.Components.numberOfHours }
  public static var numberOfMinutes: Self { Tempo.Components.numberOfMinutes }
  public static var numberOfSeconds: Self { Tempo.Components.numberOfSeconds }
  public static var numberOfMilliseconds: Self { Tempo.Components.numberOfMilliseconds }
  public static var numberOfMicroseconds: Self { Tempo.Components.numberOfMicroseconds }
  public static var numberOfNanoseconds: Self { Tempo.Components.numberOfNanoseconds }

  public static var totalDays: Self { Tempo.Components.totalDays }
  public static var totalHours: Self { Tempo.Components.totalHours }
  public static var totalMinutes: Self { Tempo.Components.totalMinutes }
  public static var totalSeconds: Self { Tempo.Components.totalSeconds }

  public static var hoursOfDay: Self { Tempo.Components.hoursOfDay }
  public static var minutesOfDay: Self { Tempo.Components.minutesOfDay }
  public static var secondsOfDay: Self { Tempo.Components.secondsOfDay }
  public static var millisecondsOfDay: Self { Tempo.Components.millisecondsOfSecond }
  public static var microsecondsOfDay: Self { Tempo.Components.microsecondsOfSecond }
  public static var nanosecondsOfDay: Self { Tempo.Components.nanosecondsOfDay }

  public static var minutesOfHour: Self { Tempo.Components.minutesOfHour }
  public static var secondsOfHour: Self { Tempo.Components.secondsOfHour }
  public static var millisecondsOfHour: Self { Tempo.Components.millisecondsOfHour }
  public static var microsecondsOfHour: Self { Tempo.Components.microsecondsOfHour }
  public static var nanosecondsOfHour: Self { Tempo.Components.nanosecondsOfHour }

  public static var secondsOfMinute: Self { Tempo.Components.secondsOfMinute }
  public static var millisecondsOfMinute: Self { Tempo.Components.millisecondsOfMinute }
  public static var microsecondsOfMinute: Self { Tempo.Components.microsecondsOfMinute }
  public static var nanosecondsOfMinute: Self { Tempo.Components.nanosecondsOfMinute }

  public static var millisecondsOfSecond: Self { Tempo.Components.millisecondsOfSecond }
  public static var microsecondsOfSecond: Self { Tempo.Components.microsecondsOfSecond }
  public static var nanosecondsOfSecond: Self { Tempo.Components.nanosecondsOfSecond }

}

extension Tempo.DurationComponent where Self == Tempo.Components.DurationInteger<Int128> {

  public static var totalMilliseconds: Self { Tempo.Components.totalMilliseconds }
  public static var totalMicroseconds: Self { Tempo.Components.totalMicroseconds }
  public static var totalNanoseconds: Self { Tempo.Components.totalNanoseconds }

}

private extension Tempo.Unit {

  var unitSize: Tempo.Components.DurationUnitSize {
    switch self {
    case .days: .days
    case .hours: .hours
    case .minutes: .minutes
    case .seconds: .seconds
    case .milliseconds: .milliseconds
    case .microseconds: .microseconds
    case .nanoseconds: .nanoseconds
    default:
      fatalError("Unsupported unit: \(self)")
    }
  }
}
