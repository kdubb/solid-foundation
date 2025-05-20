//
//  InstantTests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/12/25.
//

@testable import SolidTempo
import Testing
import Foundation


@Suite("LocalDate Tests")
struct LocalDateTests {

  @Test("LocalDate initialization")
  func testInitialization() throws {
    let date = try LocalDate(year: 2024, month: 4, day: 15)
    #expect(date.year == 2024)
    #expect(date.month == 4)
    #expect(date.day == 15)
  }

  @Test("LocalDate static properties")
  func testStaticProperties() {
    #expect(LocalDate.epoch.year == 1970)
    #expect(LocalDate.epoch.month == 1)
    #expect(LocalDate.epoch.day == 1)

    #expect(LocalDate.min.year == -999_999_999)
    #expect(LocalDate.min.month == 1)
    #expect(LocalDate.min.day == 1)

    #expect(LocalDate.max.year == 999_999_999)
    #expect(LocalDate.max.month == 12)
    #expect(LocalDate.max.day == 31)
  }

  @Test("LocalDate with() method")
  func testWithMethod() throws {
    let date = try LocalDate(year: 2024, month: 4, day: 15)

    let newDate = try date.with(year: 2025)
    #expect(newDate.year == 2025)
    #expect(newDate.month == 4)
    #expect(newDate.day == 15)

    let newDate2 = try date.with(month: 5, day: 20)
    #expect(newDate2.year == 2024)
    #expect(newDate2.month == 5)
    #expect(newDate2.day == 20)
  }

  @Test("LocalDate comparison")
  func testComparison() {
    let date1 = try! LocalDate(year: 2024, month: 4, day: 15)
    let date2 = try! LocalDate(year: 2024, month: 4, day: 16)
    let date3 = try! LocalDate(year: 2024, month: 5, day: 15)
    let date4 = try! LocalDate(year: 2025, month: 4, day: 15)
    let date5 = try! LocalDate(year: 2024, month: 4, day: 15)

    #expect(date1 < date2)
    #expect(date2 < date3)
    #expect(date3 < date4)
    #expect(date1 != date2)
    #expect(date1 == date5)
  }

  @Test("LocalDate description")
  func testDescription() throws {
    let date = try LocalDate(year: 2024, month: 4, day: 15)
    #expect(date.description == "2024-04-15")
  }

  @Test("LocalDate component container")
  func testComponentContainer() throws {
    let date = try LocalDate(year: 2024, month: 4, day: 15)

    #expect(date.value(for: .year) == 2024)
    #expect(date.value(for: .monthOfYear) == 4)
    #expect(date.value(for: .dayOfMonth) == 15)
  }

  @Test("LocalDate ordinal day initialization")
  func testOrdinalDayInitialization() throws {
    let date = try LocalDate(year: 2024, ordinalDay: 106)    // April 15, 2024
    #expect(date.year == 2024)
    #expect(date.month == 4)
    #expect(date.day == 15)

    // Test leap year
    let leapDate = try LocalDate(year: 2024, ordinalDay: 366)    // December 31, 2024
    #expect(leapDate.year == 2024)
    #expect(leapDate.month == 12)
    #expect(leapDate.day == 31)

    // Test non-leap year
    let nonLeapDate = try LocalDate(year: 2023, ordinalDay: 365)    // December 31, 2023
    #expect(nonLeapDate.year == 2023)
    #expect(nonLeapDate.month == 12)
    #expect(nonLeapDate.day == 31)
  }

  @Test("LocalDate invalid initialization")
  func testInvalidInitialization() {
    // Invalid month
    let invMonth1 = #expect(throws: TempoError.self) { try LocalDate(year: 2024, month: 13, day: 1) }
    #expect(
      invMonth1
        == TempoError.invalidComponentValue(
          component: "monthOfYear",
          reason: .outOfRange(value: "13", range: "1 - 12")
        )
    )
    let invMonth2 = #expect(throws: TempoError.self) { try LocalDate(year: 2024, month: 0, day: 1) }
    #expect(
      invMonth2
        == TempoError.invalidComponentValue(
          component: "monthOfYear",
          reason: .outOfRange(value: "0", range: "1 - 12")
        )
    )

    // Invalid day
    let invDay1 = #expect(throws: TempoError.self) { try LocalDate(year: 2024, month: 4, day: 31) }
    #expect(
      invDay1
        == TempoError.invalidComponentValue(
          component: "dayOfMonth",
          reason: .outOfRange(value: "31", range: "Invalid day for month '4' of year '2024' (1...30)")
        )
    )
    let invDay2 = #expect(throws: TempoError.self) { try LocalDate(year: 2024, month: 2, day: 30) }
    #expect(
      invDay2
        == TempoError.invalidComponentValue(
          component: "dayOfMonth",
          reason: .outOfRange(value: "30", range: "Invalid day for month '2' of year '2024' (1...29)")
        )
    )
    let invDay3 = #expect(throws: TempoError.self) { try LocalDate(year: 2023, month: 2, day: 29) }
    #expect(
      invDay3
        == TempoError.invalidComponentValue(
          component: "dayOfMonth",
          reason: .outOfRange(value: "29", range: "Invalid day for month '2' of year '2023' (1...28)")
        )
    )

    // Invalid ordinal day
    let invOrdDay1 = #expect(throws: TempoError.self) { try LocalDate(year: 2024, ordinalDay: 367) }
    #expect(
      invOrdDay1
        == TempoError.invalidComponentValue(
          component: "ordinalDay",
          reason: .outOfRange(value: "367", range: "Invalid ordinal day for year '2024' (1...366)")
        )
    )
    let invOrdDay2 = #expect(throws: TempoError.self) { try LocalDate(year: 2023, ordinalDay: 366) }
    #expect(
      invOrdDay2
        == TempoError.invalidComponentValue(
          component: "ordinalDay",
          reason: .outOfRange(value: "366", range: "Invalid ordinal day for year '2023' (1...365)")
        )
    )
    let invOrdDay3 = #expect(throws: TempoError.self) { try LocalDate(year: 2024, ordinalDay: 0) }
    #expect(
      invOrdDay3
        == TempoError.invalidComponentValue(
          component: "ordinalDay",
          reason: .outOfRange(value: "0", range: "Invalid ordinal day for year '2024' (1...366)")
        )
    )
  }

  @Test("LocalDate now")
  func testNow() {
    var cal = Calendar(identifier: .iso8601)
    cal.timeZone = .gmt
    let fdComps = cal.dateComponents([.year, .month, .day], from: .now)
    let now = LocalDate.now()
    #expect(now.year == fdComps.year)
    #expect(now.month == fdComps.month)
    #expect(now.day == fdComps.day)
  }
}
