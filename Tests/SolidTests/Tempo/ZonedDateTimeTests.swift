//
//  ZonedDateTimeTests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

@testable import SolidTempo
import Foundation
import Testing


@Suite("ZonedDateTime Tests")
struct ZonedDateTimeTests {

  public typealias ZDT = Tempo.ZonedDateTime
  public typealias LDT = Tempo.LocalDateTime
  public typealias RSO = Tempo.ResolutionStrategy.Options
  public typealias Zone = Tempo.Zone

  public typealias ZDTT =
    (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nano: Int, zone: Zone)
  public typealias LDTT =
    (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nano: Int)

  public static let LAZone: Tempo.Zone = "America/Los_Angeles"
  public static let skoDefault: RSO = [.skipped(.nextValid)]

  @Test(
    "Skipped Time Resolution",
    .serialized,
    arguments: [
      (
        "Typical",
        (year: 2024, month: 3, day: 10, hour: 2, minute: 29, second: 17, nano: 123456789, zone: LAZone),
        (year: 2024, month: 3, day: 10, hour: 3, minute: 29, second: 17, nano: 123456789),
        skoDefault
      ),
      (
        "Start of Transition",
        (year: 2024, month: 3, day: 10, hour: 2, minute: 0, second: 0, nano: 0, zone: LAZone),
        (year: 2024, month: 3, day: 10, hour: 3, minute: 0, second: 0, nano: 0),
        skoDefault
      ),
      (
        "End of Transition",
        (year: 2024, month: 3, day: 10, hour: 2, minute: 59, second: 59, nano: 999_999_999, zone: LAZone),
        (year: 2024, month: 3, day: 10, hour: 3, minute: 59, second: 59, nano: 999_999_999),
        skoDefault
      ),
      (
        "Immediately After Transition",
        (year: 2024, month: 3, day: 10, hour: 3, minute: 0, second: 0, nano: 0, zone: LAZone),
        (year: 2024, month: 3, day: 10, hour: 3, minute: 0, second: 0, nano: 0),
        skoDefault
      ),
    ] as [(String, ZDTT, LDTT, Tempo.ResolutionStrategy.Options)]
  )
  func testInstantResolution(
    testing: String,
    dateTimeTuple: ZDTT,
    expectedLocalTime: LDTT,
    resolutionOptions: RSO
  ) throws {
    let zonedDateTime = try ZDT(dateTimeTuple)
    expectEqual(zonedDateTime, expectedLocalTime)
  }

  func expectEqual(
    _ left: ZDT,
    _ right: LDTT,
  ) {
    #expect(left.date.year == right.year)
    #expect(left.date.month == right.month)
    #expect(left.date.day == right.day)
    #expect(left.time.hour == right.hour)
    #expect(left.time.minute == right.minute)
    #expect(left.time.second == right.second)
    #expect(left.time.nanosecond == right.nano)
  }

  func printDate(_ date: Date, in timeZoneID: String) {
    let dateStyle =
      Date.VerbatimFormatStyle(
        format:
          "\(year: .padded(4))-\(month: .twoDigits)-\(day: .twoDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .oneBased)):\(minute: .twoDigits):\(second: .twoDigits).\(secondFraction: .fractional(9)) \(timeZone: .iso8601(.long)) [\(timeZone: .identifier(.long))]",
        timeZone: TimeZone(identifier: timeZoneID).neverNil(),
        calendar: Calendar(
          identifier: .iso8601
        )
      )
    print(date.formatted(dateStyle))
  }
}

extension Tempo.ZonedDateTime {

  init(_ tuple: ZonedDateTimeTests.ZDTT) throws {
    try self.init(
      year: tuple.year,
      month: tuple.month,
      day: tuple.day,
      hour: tuple.hour,
      minute: tuple.minute,
      second: tuple.second,
      nanosecond: tuple.nano,
      zone: tuple.zone
    )
  }

}
