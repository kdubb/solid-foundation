//
//  DurationComponent.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//


public protocol DurationComponent<Value>: Component where Value: SignedInteger {
  func extract(from duration: Duration, rolledOver: Bool?) -> Value
}

extension Component where Self == DurationComponents.Integer<Int> {

  public static var numberOfDays: Self { DurationComponents.numberOfDays }
  public static var numberOfHours: Self { DurationComponents.numberOfHours }
  public static var numberOfMinutes: Self { DurationComponents.numberOfMinutes }
  public static var numberOfSeconds: Self { DurationComponents.numberOfSeconds }
  public static var numberOfMilliseconds: Self { DurationComponents.numberOfMilliseconds }
  public static var numberOfMicroseconds: Self { DurationComponents.numberOfMicroseconds }
  public static var numberOfNanoseconds: Self { DurationComponents.numberOfNanoseconds }

  public static var totalDays: Self { DurationComponents.totalDays }
  public static var totalHours: Self { DurationComponents.totalHours }
  public static var totalMinutes: Self { DurationComponents.totalMinutes }
  public static var totalSeconds: Self { DurationComponents.totalSeconds }

  public static var hoursOfDay: Self { DurationComponents.hoursOfDay }
  public static var minutesOfDay: Self { DurationComponents.minutesOfDay }
  public static var secondsOfDay: Self { DurationComponents.secondsOfDay }
  public static var millisecondsOfDay: Self { DurationComponents.millisecondsOfSecond }
  public static var microsecondsOfDay: Self { DurationComponents.microsecondsOfSecond }
  public static var nanosecondsOfDay: Self { DurationComponents.nanosecondsOfDay }

  public static var minutesOfHour: Self { DurationComponents.minutesOfHour }
  public static var secondsOfHour: Self { DurationComponents.secondsOfHour }
  public static var millisecondsOfHour: Self { DurationComponents.millisecondsOfHour }
  public static var microsecondsOfHour: Self { DurationComponents.microsecondsOfHour }
  public static var nanosecondsOfHour: Self { DurationComponents.nanosecondsOfHour }

  public static var secondsOfMinute: Self { DurationComponents.secondsOfMinute }
  public static var millisecondsOfMinute: Self { DurationComponents.millisecondsOfMinute }
  public static var microsecondsOfMinute: Self { DurationComponents.microsecondsOfMinute }
  public static var nanosecondsOfMinute: Self { DurationComponents.nanosecondsOfMinute }

  public static var millisecondsOfSecond: Self { DurationComponents.millisecondsOfSecond }
  public static var microsecondsOfSecond: Self { DurationComponents.microsecondsOfSecond }
  public static var nanosecondsOfSecond: Self { DurationComponents.nanosecondsOfSecond }

}

extension Component where Self == DurationComponents.Integer<Int128> {

  public static var totalMilliseconds: Self { DurationComponents.totalMilliseconds }
  public static var totalMicroseconds: Self { DurationComponents.totalMicroseconds }
  public static var totalNanoseconds: Self { DurationComponents.totalNanoseconds }

}

public enum DurationComponents {

  public static let numberOfDays = Integer<Int>(id: .numberOfDays, unit: .days)
  public static let numberOfHours = Integer<Int>(id: .numberOfHours, unit: .hours)
  public static let numberOfMinutes = Integer<Int>(id: .numberOfMinutes, unit: .minutes)
  public static let numberOfSeconds = Integer<Int>(id: .numberOfSeconds, unit: .seconds)
  public static let numberOfMilliseconds = Integer<Int>(id: .numberOfMilliseconds, unit: .milliseconds)
  public static let numberOfMicroseconds = Integer<Int>(id: .numberOfMicroseconds, unit: .microseconds)
  public static let numberOfNanoseconds = Integer<Int>(id: .numberOfNanoseconds, unit: .nanoseconds)

  public static let totalDays = Integer<Int>(
    id: .totalDays,
    unit: .days,
    rolledOverDefault: false,
    isTotal: true
  )
  public static let totalHours = Integer<Int>(
    id: .totalHours,
    unit: .hours,
    rolledOverDefault: false,
    isTotal: true
  )
  public static let totalMinutes = Integer<Int>(
    id: .totalMinutes,
    unit: .minutes,
    isTotal: true
  )
  public static let totalSeconds = Integer<Int>(
    id: .totalSeconds,
    unit: .seconds,
    isTotal: true
  )
  public static let totalMilliseconds = Integer<Int128>(
    id: .totalMilliseconds,
    unit: .milliseconds,
    isTotal: true
  )
  public static let totalMicroseconds = Integer<Int128>(
    id: .totalMicroseconds,
    unit: .microseconds,
    isTotal: true
  )
  public static let totalNanoseconds = Integer<Int128>(
    id: .totalNanoseconds,
    unit: .nanoseconds,
    isTotal: true
  )
  public static let hoursOfDay = Integer<Int>(
    id: .hoursOfDay,
    unit: .hours,
    parentUnit: .days,
    rolledOverDefault: false
  )
  public static let minutesOfDay = Integer<Int>(
    id: .minutesOfDay,
    unit: .minutes,
    parentUnit: .days,
    rolledOverDefault: false
  )
  public static let secondsOfDay = Integer<Int>(
    id: .secondsOfDay,
    unit: .seconds,
    parentUnit: .days,
    rolledOverDefault: false
  )
  public static let millisecondsOfDay = Integer<Int>(
    id: .millisecondsOfDay,
    unit: .milliseconds,
    parentUnit: .days,
    rolledOverDefault: false
  )
  public static let microsecondsOfDay = Integer<Int>(
    id: .microsecondsOfDay,
    unit: .microseconds,
    parentUnit: .days,
    rolledOverDefault: false
  )
  public static let nanosecondsOfDay = Integer<Int>(
    id: .nanosecondsOfDay,
    unit: .nanoseconds,
    parentUnit: .days,
    rolledOverDefault: false
  )
  public static let minutesOfHour = Integer<Int>(
    id: .minutesOfHour,
    unit: .minutes,
    parentUnit: .hours,
    rolledOverDefault: false
  )
  public static let secondsOfHour = Integer<Int>(
    id: .secondsOfHour,
    unit: .seconds,
    parentUnit: .hours,
    rolledOverDefault: false
  )
  public static let millisecondsOfHour = Integer<Int>(
    id: .millisecondsOfHour,
    unit: .milliseconds,
    parentUnit: .hours,
    rolledOverDefault: false
  )
  public static let microsecondsOfHour = Integer<Int>(
    id: .microsecondsOfHour,
    unit: .microseconds,
    parentUnit: .hours,
    rolledOverDefault: false
  )
  public static let nanosecondsOfHour = Integer<Int>(
    id: .nanosecondsOfHour,
    unit: .nanoseconds,
    parentUnit: .hours,
    rolledOverDefault: false
  )
  public static let secondsOfMinute = Integer<Int>(
    id: .secondsOfMinute,
    unit: .seconds,
    parentUnit: .minutes,
    rolledOverDefault: false
  )
  public static let millisecondsOfMinute = Integer<Int>(
    id: .millisecondsOfMinute,
    unit: .milliseconds,
    parentUnit: .minutes,
    rolledOverDefault: false
  )
  public static let microsecondsOfMinute = Integer<Int>(
    id: .microsecondsOfMinute,
    unit: .microseconds,
    parentUnit: .minutes,
    rolledOverDefault: false
  )
  public static let nanosecondsOfMinute = Integer<Int>(
    id: .nanosecondsOfMinute,
    unit: .nanoseconds,
    parentUnit: .minutes,
    rolledOverDefault: false
  )
  public static let millisecondsOfSecond = Integer<Int>(
    id: .millisecondsOfSecond,
    unit: .milliseconds,
    parentUnit: .seconds,
    rolledOverDefault: false
  )
  public static let microsecondsOfSecond = Integer<Int>(
    id: .microsecondsOfSecond,
    unit: .microseconds,
    parentUnit: .seconds,
    rolledOverDefault: false
  )
  public static let nanosecondsOfSecond = Integer<Int>(
    id: .nanosecondsOfSecond,
    unit: .nanoseconds,
    parentUnit: .seconds,
    rolledOverDefault: false
  )

  public struct Integer<Value>: DurationComponent where Value: SignedInteger {

    public typealias Value = Value

    public let id: Id
    public let unit: Unit
    public let unitSize: UInt128
    public let rollover: Int128?
    public let rolledOverDefault: Bool
    public let parentUnitSize: UInt128?
    public let totalUnitSize: Int128
    public let isTotal: Bool

    public init(
      id: Id,
      unit: Unit,
      parentUnit: Unit? = nil,
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

    public func extract(from duration: Duration, rolledOver: Bool?) -> Value {
      if isTotal {
        return Value(duration.nanoseconds / totalUnitSize)
      } else if let parentUnitSize {
        let ns = duration.nanoseconds
        let pus = Int128(parentUnitSize)
        let normalizedNs = ((ns % pus) + pus) % pus
        return Value((normalizedNs.magnitude / unitSize) % (parentUnitSize / unitSize))
      } else {
        let rolledOver = rolledOver ?? rolledOverDefault
        let q = floorDiv(duration.nanoseconds, unitSize)

        let reduced =
          if rolledOver, let rollover {
            q % rollover
          } else {
            q
          }

        return Value(reduced)
      }
    }

    @inline(__always)
    private func floorDiv(_ a: Int128, _ b: UInt128) -> Int128 {
      let q = a / Int128(b)
      let r = a % Int128(b)
      return (a < 0 && r != 0) ? q - 1 : q
    }
  }

  internal enum UnitSize: UInt128 {
    case days = 86_400_000_000_000
    case hours = 3_600_000_000_000
    case minutes = 60_000_000_000
    case seconds = 1_000_000_000
    case milliseconds = 1_000_000
    case microseconds = 1_000
    case nanoseconds = 1

    var rollover: Int128? {
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

}

private extension Unit {

  var unitSize: DurationComponents.UnitSize {
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
