//
//  TimeComponent.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//


public protocol TimeComponent<Value>: DateTimeComponent {}

public protocol IntegerTimeComponent: TimeComponent, IntegerDateTimeComponent where Value: SignedInteger {
  var unit: Unit { get }
  var range: ClosedRange<Value> { get }
}

extension Components {

  public static let hourOfDay = TimeInteger<Int>(id: .hourOfDay, unit: .hours, range: 0...23)
  public static let minuteOfHour = TimeInteger<Int>(id: .minuteOfHour, unit: .minutes, range: 0...59)
  public static let secondOfMinute = TimeInteger<Int>(id: .secondOfMinute, unit: .seconds, range: 0...59)
  public static let nanosecondOfSecond = TimeInteger<Int>(
    id: .nanosecondOfSecond,
    unit: .nanoseconds,
    range: 0...999_999_999
  )

  public static let zoneOffset = TimeInteger<Int>(id: .zoneOffset, unit: .hours, range: -12...14)
  public static let hoursOfZoneOffset = TimeInteger<Int>(id: .hoursOfZoneOffset, unit: .hours, range: -23...23)
  public static let minutesOfZoneOffset = TimeInteger<Int>(id: .minutesOfZoneOffset, unit: .minutes, range: -59...59)
  public static let secondsOfZoneOffset = TimeInteger<Int>(id: .secondsOfZoneOffset, unit: .seconds, range: -59...59)

  public static let zoneId = TimeIdentifier(id: .zoneId) { zoneId, componentId in
    if (try? Zone(identifier: zoneId)) == nil {
      throw TempoError.invalidComponentValue(
        component: componentId.name,
        reason: .invalidZoneId(id: zoneId)
      )
    }
  }

}

// MARK: - Common Component Extensions

extension Component where Self == Components.TimeInteger<Int> {

  public static var hourOfDay: Self { Components.hourOfDay }
  public static var minuteOfHour: Self { Components.minuteOfHour }
  public static var secondOfMinute: Self { Components.secondOfMinute }
  public static var nanosecondOfSecond: Self { Components.nanosecondOfSecond }

  public static var zoneOffset: Self { Components.zoneOffset }
  public static var hoursOfZoneOffset: Self { Components.hoursOfZoneOffset }
  public static var minutesOfZoneOffset: Self { Components.minutesOfZoneOffset }
  public static var secondsOfZoneOffset: Self { Components.secondsOfZoneOffset }

  // Common shorthand

  public static var hour: Self { Components.hourOfDay }
  public static var minute: Self { Components.minuteOfHour }
  public static var second: Self { Components.secondOfMinute }
  public static var nanosecond: Self { Components.nanosecondOfSecond }

}

extension Component where Self == Components.TimeIdentifier {

  public static var zoneId: Self { Components.zoneId }

}

// MARK: - TimeComponent Extensions

extension TimeComponent where Self == Components.TimeInteger<Int> {

  public static var hourOfDay: Self { Components.hourOfDay }
  public static var minuteOfHour: Self { Components.minuteOfHour }
  public static var secondOfMinute: Self { Components.secondOfMinute }
  public static var nanosecondOfSecond: Self { Components.nanosecondOfSecond }

  public static var zoneOffset: Self { Components.zoneOffset }
  public static var hoursOfZoneOffset: Self { Components.hoursOfZoneOffset }
  public static var minutesOfZoneOffset: Self { Components.minutesOfZoneOffset }
  public static var secondsOfZoneOffset: Self { Components.secondsOfZoneOffset }

  // Common shorthand

  public static var hour: Self { Components.hourOfDay }
  public static var minute: Self { Components.minuteOfHour }
  public static var second: Self { Components.secondOfMinute }
  public static var nanosecond: Self { Components.nanosecondOfSecond }

}

extension TimeComponent where Self == Components.TimeIdentifier {

  public static var zoneId: Self { Components.zoneId }
}

extension Components {

  public struct TimeInteger<Value>: IntegerTimeComponent
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

  public struct TimeIdentifier: TimeComponent {

    public typealias Value = String

    public let id: Id
    public let unit: Unit = .nan
    public let validator: (@Sendable (String, Component.Id) throws -> Void)?

    public func validate(_ value: String) throws {
      try validator?(value, id)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
  }

}
