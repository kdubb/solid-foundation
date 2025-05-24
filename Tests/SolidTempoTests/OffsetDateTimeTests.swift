//
//  OffsetDateTimeTests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/12/25.
//

@testable import SolidTempo
import Testing
import Foundation


@Suite("OffsetDateTime Tests")
struct OffsetDateTimeTests {

  @Test("OffsetDateTime initialization")
  func testInitialization() throws {
    let dateTime = try OffsetDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 30,
      second: 45,
      nanosecond: 123_456_789,
      offset: .hours(2)
    )
    #expect(dateTime.year == 2024)
    #expect(dateTime.month == 4)
    #expect(dateTime.day == 15)
    #expect(dateTime.hour == 14)
    #expect(dateTime.minute == 30)
    #expect(dateTime.second == 45)
    #expect(dateTime.nanosecond == 123_456_789)
    #expect(dateTime.offset.totalSeconds == 7200)    // 2 hours in seconds
  }

  @Test("OffsetDateTime with() method")
  func testWithMethod() throws {
    let dateTime = try OffsetDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 30,
      second: 45,
      nanosecond: 123_456_789,
      offset: .hours(2)
    )

    let newDateTime = try dateTime.with(
      year: 2025,
      hour: 15,
      minute: 45,
      offset: .hours(3)
    )
    #expect(newDateTime.year == 2025)
    #expect(newDateTime.month == 4)
    #expect(newDateTime.day == 15)
    #expect(newDateTime.hour == 15)
    #expect(newDateTime.minute == 45)
    #expect(newDateTime.second == 45)
    #expect(newDateTime.nanosecond == 123_456_789)
    #expect(newDateTime.offset.totalSeconds == 10800)    // 3 hours in seconds
  }

  @Test("OffsetDateTime comparison")
  func testComparison() throws {
    let dateTime1 = try OffsetDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 30,
      second: 45,
      nanosecond: 123_456_789,
      offset: .hours(2)
    )
    let dateTime2 = try OffsetDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 30,
      second: 45,
      nanosecond: 123_456_790,
      offset: .hours(2)
    )
    let dateTime3 = try OffsetDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 31,
      second: 0,
      nanosecond: 0,
      offset: .hours(2)
    )
    let dateTime4 = try OffsetDateTime(
      year: 2024,
      month: 4,
      day: 16,
      hour: 0,
      minute: 0,
      second: 0,
      nanosecond: 0,
      offset: .hours(2)
    )

    #expect(dateTime1 < dateTime2)
    #expect(dateTime2 < dateTime3)
    #expect(dateTime3 < dateTime4)
    #expect(dateTime1 != dateTime2)
    #expect(dateTime1 == dateTime1)
  }

  @Test("OffsetDateTime description")
  func testDescription() throws {
    let dateTime = try OffsetDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 30,
      second: 45,
      nanosecond: 123_456_789,
      offset: .hours(2)
    )
    #expect(dateTime.description == "2024-04-15 14:30:45.123456789+02:00")
  }

  @Test("OffsetDateTime component container")
  func testComponentContainer() throws {
    let dateTime = try OffsetDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 30,
      second: 45,
      nanosecond: 123_456_789,
      offset: .hours(2)
    )

    #expect(dateTime.value(for: .year) == 2024)
    #expect(dateTime.value(for: .monthOfYear) == 4)
    #expect(dateTime.value(for: .dayOfMonth) == 15)
    #expect(dateTime.value(for: .hourOfDay) == 14)
    #expect(dateTime.value(for: .minuteOfHour) == 30)
    #expect(dateTime.value(for: .secondOfMinute) == 45)
    #expect(dateTime.value(for: .nanosecondOfSecond) == 123_456_789)
    #expect(dateTime.value(for: .zoneOffset) == 7200)    // 2 hours in seconds
  }

  @Test("OffsetDateTime invalid initialization")
  func testInvalidInitialization() {
    // Invalid month
    let invMonth = #expect(throws: TempoError.self) {
      try OffsetDateTime(
        year: 2024,
        month: 13,
        day: 1,
        hour: 0,
        minute: 0,
        second: 0,
        nanosecond: 0,
        offset: .zero
      )
    }
    #expect(
      invMonth
        == TempoError.invalidComponentValue(
          component: "monthOfYear",
          reason: .outOfRange(value: "13", range: "1 - 12")
        )
    )

    // Invalid hour
    let invHour = #expect(throws: TempoError.self) {
      try OffsetDateTime(
        year: 2024,
        month: 4,
        day: 15,
        hour: 24,
        minute: 0,
        second: 0,
        nanosecond: 0,
        offset: .zero
      )
    }
    #expect(
      invHour
        == TempoError.invalidComponentValue(
          component: "hourOfDay",
          reason: .outOfRange(value: "24", range: "0 - 23")
        )
    )

    // Invalid minute
    let invMinute = #expect(throws: TempoError.self) {
      try OffsetDateTime(
        year: 2024,
        month: 4,
        day: 15,
        hour: 14,
        minute: 60,
        second: 0,
        nanosecond: 0,
        offset: .zero
      )
    }
    #expect(
      invMinute
        == TempoError.invalidComponentValue(
          component: "minuteOfHour",
          reason: .outOfRange(value: "60", range: "0 - 59")
        )
    )
  }

  @Test("OffsetDateTime now")
  func testNow() {
    let now = OffsetDateTime.now()

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
  }

  @Test("OffsetDateTime withOffset")
  func testWithOffset() throws {
    let dateTime = try OffsetDateTime(
      year: 2024,
      month: 4,
      day: 15,
      hour: 14,
      minute: 30,
      second: 45,
      nanosecond: 123_456_789,
      offset: .hours(2)
    )

    // Test same instant
    let newDateTime1 = try dateTime.with(offset: .hours(3), anchor: .sameInstant)
    #expect(newDateTime1.offset.totalSeconds == 10800)    // 3 hours in seconds
    #expect(newDateTime1.hour == 15)    // Time adjusted for new offset

    // Test same local time
    let newDateTime2 = try dateTime.with(offset: .hours(3), anchor: .sameLocalTime)
    #expect(newDateTime2.offset.totalSeconds == 10800)    // 3 hours in seconds
    #expect(newDateTime2.hour == 14)    // Time remains the same
  }
}
