//
//  ZoneOffsetComponent.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/23/25.
//


public protocol ZoneOffsetComponent<Value>: Component {}

public protocol IntegerZoneOffsetComponent<Value>: PeriodComponent where Value: SignedInteger {
  var unit: Unit { get }
  var range: ClosedRange<Value> { get }
}

extension Component where Self == ZoneOffsetComponents.Integer {

  public static var hoursOfZoneOffset: Self { ZoneOffsetComponents.hours }
  public static var minutesOfZoneOffset: Self { ZoneOffsetComponents.minutes }
  public static var secondsOfZoneOffset: Self { ZoneOffsetComponents.seconds }

}

public enum ZoneOffsetComponents {

  public static let hours = Integer(id: .hoursOfZoneOffset, unit: .hours, range: -23...23)
  public static let minutes = Integer(id: .minutesOfZoneOffset, unit: .minutes, range: -59...59)
  public static let seconds = Integer(id: .secondsOfZoneOffset, unit: .seconds, range: -59...59)

  public struct Integer: ZoneOffsetComponent {

    public typealias Value = Int

    public let id: Id
    public let unit: Unit
    public let range: ClosedRange<Int>

    public init(id: Id, unit: Unit, range: ClosedRange<Int>) {
      self.id = id
      self.unit = unit
      self.range = range
    }

    public func validate(_ value: Int) throws {
      guard !range.contains(value) else { return }
      throw TempoError.invalidComponentValue(component: name, reason: .outOfRange(value: "\(value)", range: "\(range)"))
    }

  }

}
