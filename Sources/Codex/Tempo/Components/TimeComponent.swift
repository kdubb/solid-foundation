//
//  TimeComponent.swift
//  Codex
//
//  Created by Kevin Wooten on 5/1/25.
//

extension Tempo {

  public protocol TimeComponent<Value>: DateTimeComponent where Value: Equatable & Sendable {
    var unit: Unit { get }
    var min: Value { get }
    var max: Value { get }
  }

}

extension Tempo.Components {

  public static let hourOfDay = Integer<Int>(id: .hourOfDay, unit: .hours, range: 0...23)
  public static let minuteOfHour = Integer<Int>(id: .minuteOfHour, unit: .minutes, range: 0...59)
  public static let secondOfMinute = Integer<Int>(id: .secondOfMinute, unit: .seconds, range: 0...59)
  public static let nanosecondOfSecond = Integer<Int>(
    id: .nanosecondOfSecond,
    unit: .nanoseconds,
    range: 0...999_999_999
  )

  public static let zoneOffset = Integer<Int>(id: .zoneOffset, unit: .hours, range: -12...14)
  public static let hoursOfZoneOffset = Integer<Int>(id: .hoursOfZoneOffset, unit: .hours, range: -18...18)
  public static let minutesOfZoneOffset = Integer<Int>(id: .minutesOfZoneOffset, unit: .minutes, range: 0...59)
  public static let secondsOfZoneOffset = Integer<Int>(id: .secondsOfZoneOffset, unit: .seconds, range: 0...59)

  public static let zoneId = Identifier(id: .zoneId) { zoneId, componentId in
    if (try? Tempo.Zone(identifier: zoneId)) == nil {
      throw Tempo.Error.invalidComponentValue(
        component: componentId.name,
        reason: .invalidZoneId(id: zoneId)
      )
    }
  }

  public static let durationSinceEpoch = Integer<Int128>(
    id: .durationSinceEpoch,
    unit: .nanoseconds,
    range: Int128.min...Int128.max
  )

}

// MARK: - Common Component Extensions

extension Tempo.Component where Self == Tempo.Components.Integer<Int> {

  public static var hourOfDay: Self { Tempo.Components.hourOfDay }
  public static var minuteOfHour: Self { Tempo.Components.minuteOfHour }
  public static var secondOfMinute: Self { Tempo.Components.secondOfMinute }
  public static var nanosecondOfSecond: Self { Tempo.Components.nanosecondOfSecond }

  public static var zoneOffset: Self { Tempo.Components.zoneOffset }
  public static var hoursOfZoneOffset: Self { Tempo.Components.hoursOfZoneOffset }
  public static var minutesOfZoneOffset: Self { Tempo.Components.minutesOfZoneOffset }
  public static var secondsOfZoneOffset: Self { Tempo.Components.secondsOfZoneOffset }

  // Common shorthand

  public static var hour: Self { Tempo.Components.hourOfDay }
  public static var minute: Self { Tempo.Components.minuteOfHour }
  public static var second: Self { Tempo.Components.secondOfMinute }
  public static var nanosecond: Self { Tempo.Components.nanosecondOfSecond }

}

extension Tempo.Component where Self == Tempo.Components.Identifier {

  public static var zoneId: Tempo.Components.Identifier { Tempo.Components.zoneId }

}

extension Tempo.Component where Self == Tempo.Components.Integer<Int128> {

  public static var durationSinceEpoch: Self { Tempo.Components.durationSinceEpoch }

}

// MARK: - TimeComponent Extensions

extension Tempo.TimeComponent where Self == Tempo.Components.Integer<Int> {

  public static var hourOfDay: Self { Tempo.Components.hourOfDay }
  public static var minuteOfHour: Self { Tempo.Components.minuteOfHour }
  public static var secondOfMinute: Self { Tempo.Components.secondOfMinute }
  public static var nanosecondOfSecond: Self { Tempo.Components.nanosecondOfSecond }

  public static var zoneOffset: Self { Tempo.Components.zoneOffset }
  public static var hoursOfZoneOffset: Self { Tempo.Components.hoursOfZoneOffset }
  public static var minutesOfZoneOffset: Self { Tempo.Components.minutesOfZoneOffset }
  public static var secondsOfZoneOffset: Self { Tempo.Components.secondsOfZoneOffset }

  // Common shorthand

  public static var hour: Self { Tempo.Components.hourOfDay }
  public static var minute: Self { Tempo.Components.minuteOfHour }
  public static var second: Self { Tempo.Components.secondOfMinute }
  public static var nanosecond: Self { Tempo.Components.nanosecondOfSecond }

}

extension Tempo.TimeComponent where Self == Tempo.Components.Integer<Int128> {

  public static var durationSinceEpoch: Self { Tempo.Components.durationSinceEpoch }

}
