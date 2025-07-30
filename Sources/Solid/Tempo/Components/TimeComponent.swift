//
//  TimeComponent.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//


public protocol TimeComponentKind<Value>: ComponentKind {}

public protocol IntegerTimeComponentKind: TimeComponentKind, IntegerDateTimeComponentKind where Value: SignedInteger {
  var unit: Unit { get }
  var range: ClosedRange<Value> { get }
}

extension ComponentKind where Self == TimeComponentKinds.Integer<Int> {

  public static var hourOfDay: Self { TimeComponentKinds.hourOfDay }
  public static var minuteOfHour: Self { TimeComponentKinds.minuteOfHour }
  public static var secondOfMinute: Self { TimeComponentKinds.secondOfMinute }
  public static var nanosecondOfSecond: Self { TimeComponentKinds.nanosecondOfSecond }

  public static var zoneOffset: Self { TimeComponentKinds.zoneOffset }

}

extension ComponentKind where Self == TimeComponentKinds.Identifier {

  public static var zoneId: Self { TimeComponentKinds.zoneId }

}

public enum TimeComponentKinds {

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
        component: componentId,
        reason: .invalidZoneId(id: zoneId)
      )
    }
  }

  public struct Integer<Value>: IntegerTimeComponentKind where Value: SignedInteger & Sendable {

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

  public struct Identifier: TimeComponentKind {

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
