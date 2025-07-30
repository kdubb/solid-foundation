//
//  DurationComponentKind.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//


public protocol DurationComponentKind<Value>: ComponentKind where Value: SignedInteger {
  func extract(from duration: Duration, forceRollOver: Bool?) -> Value
}

extension ComponentKind where Self == DurationComponentKinds.Integer<Int> {

  public static var numberOfDays: Self { DurationComponentKinds.numberOfDays }
  public static var numberOfHours: Self { DurationComponentKinds.numberOfHours }
  public static var numberOfMinutes: Self { DurationComponentKinds.numberOfMinutes }
  public static var numberOfSeconds: Self { DurationComponentKinds.numberOfSeconds }
  public static var numberOfMilliseconds: Self { DurationComponentKinds.numberOfMilliseconds }
  public static var numberOfMicroseconds: Self { DurationComponentKinds.numberOfMicroseconds }
  public static var numberOfNanoseconds: Self { DurationComponentKinds.numberOfNanoseconds }

  public static var totalDays: Self { DurationComponentKinds.totalDays }
  public static var totalHours: Self { DurationComponentKinds.totalHours }
  public static var totalMinutes: Self { DurationComponentKinds.totalMinutes }
  public static var totalSeconds: Self { DurationComponentKinds.totalSeconds }

  public static var hoursOfDay: Self { DurationComponentKinds.hoursOfDay }
  public static var minutesOfDay: Self { DurationComponentKinds.minutesOfDay }
  public static var secondsOfDay: Self { DurationComponentKinds.secondsOfDay }
  public static var millisecondsOfDay: Self { DurationComponentKinds.millisecondsOfDay }
  public static var microsecondsOfDay: Self { DurationComponentKinds.microsecondsOfDay }
  public static var nanosecondsOfDay: Self { DurationComponentKinds.nanosecondsOfDay }

  public static var minutesOfHour: Self { DurationComponentKinds.minutesOfHour }
  public static var secondsOfHour: Self { DurationComponentKinds.secondsOfHour }
  public static var millisecondsOfHour: Self { DurationComponentKinds.millisecondsOfHour }
  public static var microsecondsOfHour: Self { DurationComponentKinds.microsecondsOfHour }
  public static var nanosecondsOfHour: Self { DurationComponentKinds.nanosecondsOfHour }

  public static var secondsOfMinute: Self { DurationComponentKinds.secondsOfMinute }
  public static var millisecondsOfMinute: Self { DurationComponentKinds.millisecondsOfMinute }
  public static var microsecondsOfMinute: Self { DurationComponentKinds.microsecondsOfMinute }
  public static var nanosecondsOfMinute: Self { DurationComponentKinds.nanosecondsOfMinute }

  public static var millisecondsOfSecond: Self { DurationComponentKinds.millisecondsOfSecond }
  public static var microsecondsOfSecond: Self { DurationComponentKinds.microsecondsOfSecond }
  public static var nanosecondsOfSecond: Self { DurationComponentKinds.nanosecondsOfSecond }

}

extension ComponentKind where Self == DurationComponentKinds.Integer<Int128> {

  public static var totalMilliseconds: Self { DurationComponentKinds.totalMilliseconds }
  public static var totalMicroseconds: Self { DurationComponentKinds.totalMicroseconds }
  public static var totalNanoseconds: Self { DurationComponentKinds.totalNanoseconds }

}

public enum DurationComponentKinds {

  public static let numberOfDays = Integer<Int>(
    id: .numberOfDays,
    unit: .days,
    style: .unit
  )
  public static let numberOfHours = Integer<Int>(
    id: .numberOfHours,
    unit: .hours,
    style: .rolledOver
  )
  public static let numberOfMinutes = Integer<Int>(
    id: .numberOfMinutes,
    unit: .minutes,
    style: .rolledOver
  )
  public static let numberOfSeconds = Integer<Int>(
    id: .numberOfSeconds,
    unit: .seconds,
    style: .rolledOver
  )
  public static let numberOfMilliseconds = Integer<Int>(
    id: .numberOfMilliseconds,
    unit: .milliseconds,
    style: .rolledOver
  )
  public static let numberOfMicroseconds = Integer<Int>(
    id: .numberOfMicroseconds,
    unit: .microseconds,
    style: .rolledOver
  )
  public static let numberOfNanoseconds = Integer<Int>(
    id: .numberOfNanoseconds,
    unit: .nanoseconds,
    style: .rolledOver
  )

  public static let totalDays = Integer<Int>(
    id: .totalDays,
    unit: .days,
    style: .total
  )
  public static let totalHours = Integer<Int>(
    id: .totalHours,
    unit: .hours,
    style: .total
  )
  public static let totalMinutes = Integer<Int>(
    id: .totalMinutes,
    unit: .minutes,
    style: .total
  )
  public static let totalSeconds = Integer<Int>(
    id: .totalSeconds,
    unit: .seconds,
    style: .total
  )
  public static let totalMilliseconds = Integer<Int128>(
    id: .totalMilliseconds,
    unit: .milliseconds,
    style: .total
  )
  public static let totalMicroseconds = Integer<Int128>(
    id: .totalMicroseconds,
    unit: .microseconds,
    style: .total
  )
  public static let totalNanoseconds = Integer<Int128>(
    id: .totalNanoseconds,
    unit: .nanoseconds,
    style: .total
  )
  public static let hoursOfDay = Integer<Int>(
    id: .hoursOfDay,
    unit: .hours,
    style: .nested(in: .days),
  )
  public static let minutesOfDay = Integer<Int>(
    id: .minutesOfDay,
    unit: .minutes,
    style: .nested(in: .days),
  )
  public static let secondsOfDay = Integer<Int>(
    id: .secondsOfDay,
    unit: .seconds,
    style: .nested(in: .days),
  )
  public static let millisecondsOfDay = Integer<Int>(
    id: .millisecondsOfDay,
    unit: .milliseconds,
    style: .nested(in: .days),
  )
  public static let microsecondsOfDay = Integer<Int>(
    id: .microsecondsOfDay,
    unit: .microseconds,
    style: .nested(in: .days),
  )
  public static let nanosecondsOfDay = Integer<Int>(
    id: .nanosecondsOfDay,
    unit: .nanoseconds,
    style: .nested(in: .days),
  )
  public static let minutesOfHour = Integer<Int>(
    id: .minutesOfHour,
    unit: .minutes,
    style: .nested(in: .hours),
  )
  public static let secondsOfHour = Integer<Int>(
    id: .secondsOfHour,
    unit: .seconds,
    style: .nested(in: .hours),
  )
  public static let millisecondsOfHour = Integer<Int>(
    id: .millisecondsOfHour,
    unit: .milliseconds,
    style: .nested(in: .hours),
  )
  public static let microsecondsOfHour = Integer<Int>(
    id: .microsecondsOfHour,
    unit: .microseconds,
    style: .nested(in: .hours),
  )
  public static let nanosecondsOfHour = Integer<Int>(
    id: .nanosecondsOfHour,
    unit: .nanoseconds,
    style: .nested(in: .hours),
  )
  public static let secondsOfMinute = Integer<Int>(
    id: .secondsOfMinute,
    unit: .seconds,
    style: .nested(in: .minutes),
  )
  public static let millisecondsOfMinute = Integer<Int>(
    id: .millisecondsOfMinute,
    unit: .milliseconds,
    style: .nested(in: .minutes),
  )
  public static let microsecondsOfMinute = Integer<Int>(
    id: .microsecondsOfMinute,
    unit: .microseconds,
    style: .nested(in: .minutes),
  )
  public static let nanosecondsOfMinute = Integer<Int>(
    id: .nanosecondsOfMinute,
    unit: .nanoseconds,
    style: .nested(in: .minutes),
  )
  public static let millisecondsOfSecond = Integer<Int>(
    id: .millisecondsOfSecond,
    unit: .milliseconds,
    style: .nested(in: .seconds),
  )
  public static let microsecondsOfSecond = Integer<Int>(
    id: .microsecondsOfSecond,
    unit: .microseconds,
    style: .nested(in: .seconds),
  )
  public static let nanosecondsOfSecond = Integer<Int>(
    id: .nanosecondsOfSecond,
    unit: .nanoseconds,
    style: .nested(in: .seconds),
  )

  public struct Integer<Value>: DurationComponentKind where Value: SignedInteger {

    public enum ComputeStyle: Sendable {
      case total
      case nested(in: Unit)
      case unit(rolledOver: Bool)

      public static var unit: Self { .unit(rolledOver: false) }
      public static var rolledOver: Self { .unit(rolledOver: true) }

      func method(for unitSize: UnitSize) -> ComputeMethod {
        switch self {
        case .total:
          .total(totalUnitSize: .init(unitSize.rawValue))
        case .nested(in: let parentUnit):
          .nested(parentUnitSize: parentUnit.unitSize.rawValue)
        case .unit(let rolledOver):
          .unit(rolledOver: rolledOver, rollOver: unitSize.rollOver)
        }
      }
    }

    public enum ComputeMethod: Sendable {
      case total(totalUnitSize: Int128)
      case nested(parentUnitSize: UInt128)
      case unit(rolledOver: Bool, rollOver: Int128)
    }

    public typealias Value = Value

    public let id: Id
    public let unit: Unit
    public let unitSize: UInt128
    public let method: ComputeMethod

    public init(
      id: Id,
      unit: Unit,
      style: ComputeStyle,
    ) {
      let unitSize = unit.unitSize
      self.id = id
      self.unit = unit
      self.unitSize = unitSize.rawValue
      self.method = style.method(for: unitSize)
    }

    public func validate(_ value: Value) throws {}

    public func extract(from duration: Duration, forceRollOver: Bool?) -> Value {
      switch method {
      case .total(totalUnitSize: let totalUnitSize):
        return Value(duration.nanoseconds / totalUnitSize)

      case .nested(parentUnitSize: let parentUnitSize):
        let ns = duration.nanoseconds
        let pus = Int128(parentUnitSize)
        let normalizedNs = ((ns % pus) + pus) % pus
        return Value((normalizedNs.magnitude / unitSize) % (parentUnitSize / unitSize))

      case .unit(rolledOver: let rolledOver, rollOver: let rollOver):
        let q = floorDiv(duration.nanoseconds, unitSize)
        let rolled =
          if forceRollOver ?? rolledOver {
            q % rollOver
          } else {
            q
          }
        return Value(rolled)
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

    var rollOver: Int128 {
      switch self {
      case .days: return 365
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

  var unitSize: DurationComponentKinds.UnitSize {
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
