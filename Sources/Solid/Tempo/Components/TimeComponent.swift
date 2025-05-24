//
//  TimeComponent.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//


public protocol TimeComponent<Value>: Component {}

public protocol IntegerTimeComponent: TimeComponent, IntegerDateTimeComponent where Value: SignedInteger {
  var unit: Unit { get }
  var range: ClosedRange<Value> { get }
}

extension Component where Self == TimeComponents.Integer<Int> {

  public static var hourOfDay: Self { TimeComponents.hourOfDay }
  public static var minuteOfHour: Self { TimeComponents.minuteOfHour }
  public static var secondOfMinute: Self { TimeComponents.secondOfMinute }
  public static var nanosecondOfSecond: Self { TimeComponents.nanosecondOfSecond }

  public static var zoneOffset: Self { TimeComponents.zoneOffset }

}

extension Component where Self == TimeComponents.Identifier {

  public static var zoneId: Self { TimeComponents.zoneId }

}

public enum TimeComponents {

  public static let hourOfDay = Integer<Int>(id: .hourOfDay, unit: .hours, range: 0...23)
  public static let minuteOfHour = Integer<Int>(id: .minuteOfHour, unit: .minutes, range: 0...59)
  public static let secondOfMinute = Integer<Int>(id: .secondOfMinute, unit: .seconds, range: 0...59)
  public static let nanosecondOfSecond = Integer<Int>(
    id: .nanosecondOfSecond,
    unit: .nanoseconds,
    range: 0...999_999_999
  )

  public static let zoneOffset = Integer<Int>(id: .zoneOffset, unit: .hours, range: -12...14)

  public static let zoneId = Identifier(id: .zoneId) { zoneId, componentId in
    if (try? Zone(identifier: zoneId)) == nil {
      throw TempoError.invalidComponentValue(
        component: componentId.name,
        reason: .invalidZoneId(id: zoneId)
      )
    }
  }

  public struct Integer<Value>: IntegerTimeComponent where Value: SignedInteger & Sendable {

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

  public struct Identifier: TimeComponent {

    public typealias Value = String

    public let id: Id
    public let unit: Unit = .nan
    public let validator: (@Sendable (String, Id) throws -> Void)?

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
