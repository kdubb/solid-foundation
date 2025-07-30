//
//  LocalDateTimeTests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/12/25.
//

@testable import SolidTempo
import Testing
import Foundation


@Suite("LocalDateTime Tests")
struct LocalDateTimeTests {

  @Test("LocalDateTime initialization")
  func testInitialization() throws {
    let dateTime = try LocalDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 30,
      second: 45,
      nanosecond: 123_456_789
    )
    #expect(dateTime.year == 2024)
    #expect(dateTime.month == 4)
    #expect(dateTime.day == 15)
    #expect(dateTime.hour == 14)
    #expect(dateTime.minute == 30)
    #expect(dateTime.second == 45)
    #expect(dateTime.nanosecond == 123_456_789)
  }

  @Test("LocalDateTime static properties")
  func testStaticProperties() {
    #expect(LocalDateTime.min.date == .min)
    #expect(LocalDateTime.min.time == .min)
    #expect(LocalDateTime.max.date == .max)
    #expect(LocalDateTime.max.time == .max)
  }

  @Test("LocalDateTime with() method")
  func testWithMethod() throws {
    let dateTime = try LocalDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 30,
      second: 45,
      nanosecond: 123_456_789
    )

    let newDateTime = try dateTime.with(
      year: 2025,
      hour: 15,
      minute: 45
    )
    #expect(newDateTime.year == 2025)
    #expect(newDateTime.month == 4)
    #expect(newDateTime.day == 15)
    #expect(newDateTime.hour == 15)
    #expect(newDateTime.minute == 45)
    #expect(newDateTime.second == 45)
    #expect(newDateTime.nanosecond == 123_456_789)
  }

  @Test("LocalDateTime comparison")
  func testComparison() throws {
    let dateTime1 = try LocalDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 30,
      second: 45,
      nanosecond: 123_456_789
    )
    let dateTime2 = try LocalDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 30,
      second: 45,
      nanosecond: 123_456_790
    )
    let dateTime3 = try LocalDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 31,
      second: 0,
      nanosecond: 0
    )
    let dateTime4 = try LocalDateTime(
      year: 2024,
      month: 4,
      day: 16,
      hour: 0,
      minute: 0,
      second: 0,
      nanosecond: 0
    )

    #expect(dateTime1 < dateTime2)
    #expect(dateTime2 < dateTime3)
    #expect(dateTime3 < dateTime4)
    #expect(dateTime1 != dateTime2)
    #expect(dateTime1 == dateTime1)
  }

  @Test("LocalDateTime description")
  func testDescription() throws {
    let dateTime = try LocalDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 30,
      second: 45,
      nanosecond: 123_456_789
    )
    #expect(dateTime.description == "2024-04-15 14:30:45.123456789")
  }

  @Test("LocalDateTime component container")
  func testComponentContainer() throws {
    let dateTime = try LocalDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 30,
      second: 45,
      nanosecond: 123_456_789
    )

    #expect(dateTime.value(for: .year) == 2024)
    #expect(dateTime.value(for: .monthOfYear) == 4)
    #expect(dateTime.value(for: .dayOfMonth) == 15)
    #expect(dateTime.value(for: .hourOfDay) == 14)
    #expect(dateTime.value(for: .minuteOfHour) == 30)
    #expect(dateTime.value(for: .secondOfMinute) == 45)
    #expect(dateTime.value(for: .nanosecondOfSecond) == 123_456_789)
  }

  @Test("LocalDateTime invalid initialization")
  func testInvalidInitialization() {
    // Invalid month
    let invMonth = #expect(throws: TempoError.self) {
      try LocalDateTime(
        year: 2024,
        month: 13,
        day: 1,
        hour: 0,
        minute: 0,
        second: 0,
        nanosecond: 0
      )
    }
    #expect(
      invMonth
        == TempoError.invalidComponentValue(
          component: .monthOfYear,
          reason: .outOfRange(value: "13", range: "1 - 12")
        )
    )

    // Invalid hour
    let invHour = #expect(throws: TempoError.self) {
      try LocalDateTime(
        year: 2024,
        month: 4,
        day: 15,
        hour: 24,
        minute: 0,
        second: 0,
        nanosecond: 0
      )
    }
    #expect(
      invHour
        == TempoError.invalidComponentValue(
          component: .hourOfDay,
          reason: .outOfRange(value: "24", range: "0 - 23")
        )
    )

    // Invalid minute
    let invMinute = #expect(throws: TempoError.self) {
      try LocalDateTime(
        year: 2024,
        month: 4,
        day: 15,
        hour: 14,
        minute: 60,
        second: 0,
        nanosecond: 0
      )
    }
    #expect(
      invMinute
        == TempoError.invalidComponentValue(
          component: .minuteOfHour,
          reason: .outOfRange(value: "60", range: "0 - 59")
        )
    )
  }

  @Test("LocalDateTime now")
  func testNow() {
    let now = LocalDateTime.now()

    var calendar = Calendar(identifier: .iso8601)
    calendar.timeZone = .gmt
    let fdComps = calendar.dateComponents(
      [.year, .month, .day, .hour, .minute, .second, .nanosecond],
      from: .now
    )

    #expect(now.year == fdComps.year)
    #expect(now.month == fdComps.month)
    #expect(now.day == fdComps.day)
    #expect(now.hour == fdComps.hour)
    #expect(now.minute == fdComps.minute)
    #expect(now.second == fdComps.second)
    #expect(abs(fdComps.nanosecond! - now.nanosecond) < 100_000_000)
    print(abs(fdComps.nanosecond! - now.nanosecond))
  }
}
