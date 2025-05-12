//
//  RFC3339Tests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/12/25.
//

@testable import SolidFormat
@testable import SolidNumeric
import Testing


@Suite("RFC3339 ISO 8601 Date and Time Tests")
struct RFC3339ISO8601DateAndTimeTests {

  @Suite("FullDate Tests")
  struct FullDateTests {

    @Test(
      "Valid full-date parsing",
      arguments: [
        "2024-04-04",
        "2024-02-29",    // Leap year
        "2023-02-28",    // Non-leap year
        "2024-12-31",
        "2024-01-01",
      ]
    )
    func validFullDateParsing(dateString: String) throws {
      let date = try #require(RFC3339.FullDate.parse(string: dateString))
      let components = dateString.split(separator: "-")
      #expect(date.year == Int(components[0]), Comment("Year mismatch for \(dateString)"))
      #expect(date.month == Int(components[1]), Comment("Month mismatch for \(dateString)"))
      #expect(date.day == Int(components[2]), Comment("Day mismatch for \(dateString)"))
    }

    @Test(
      "Invalid full-date parsing",
      arguments: [
        ("2024-13-01", Comment("Invalid month")),
        ("2024-00-01", Comment("Invalid month")),
        ("2024-01-32", Comment("Invalid day")),
        ("2024-02-30", Comment("Invalid day for February")),
        ("2023-02-29", Comment("Invalid day for non-leap year")),
        ("2024-04-31", Comment("Invalid day for April")),
        ("2024-04-4", Comment("Invalid format (single digit day)")),
        ("2024-4-04", Comment("Invalid format (single digit month)")),
        ("24-04-04", Comment("Invalid format (2-digit year)")),
        ("2024/04/04", Comment("Invalid separator")),
        ("2024-04-04T", Comment("Contains time separator")),
        ("2024-04-04Z", Comment("Contains timezone")),
      ]
    )
    func invalidFullDateParsing(dateString: String, message: Comment) throws {
      #expect(RFC3339.FullDate.parse(string: dateString) == nil, message)
    }
  }

  @Suite("FullTime Tests")
  struct FullTimeTests {

    @Test(
      "Valid full-time parsing",
      arguments: [
        ("00:00:00Z", 0, 0, BigDecimal("0"), 0),
        ("23:59:59Z", 23, 59, BigDecimal("59"), 0),
        ("23:59:60Z", 23, 59, BigDecimal("60"), 0),    // Leap second
        ("12:00:00.123Z", 12, 0, BigDecimal("0.123"), 0),
        ("12:00:00.123456789Z", 12, 0, BigDecimal("0.123456789"), 0),    // High precision
        ("12:00:00+01:00", 12, 0, BigDecimal("0"), 3600),
        ("12:00:00-01:00", 12, 0, BigDecimal("0"), -3600),
        ("12:00:00+14:00", 12, 0, BigDecimal("0"), 50400),
        ("12:00:00-14:00", 12, 0, BigDecimal("0"), -50400),
      ]
    )
    func validFullTimeParsing(timeString: String, hour: Int, minute: Int, second: BigDecimal, tzOffset: Int) throws {
      let time = try #require(RFC3339.FullTime.parse(string: timeString))
      #expect(time.hour == hour, Comment("Hour mismatch for \(timeString)"))
      #expect(time.minute == minute, Comment("Minute mismatch for \(timeString)"))
      #expect(time.second == second, Comment("Second mismatch for \(timeString)"))
      #expect(time.tzOffset == tzOffset, Comment("Timezone offset mismatch for \(timeString)"))
    }

    @Test(
      "Invalid full-time parsing",
      arguments: [
        ("24:00:00Z", Comment("Invalid hour")),
        ("23:60:00Z", Comment("Invalid minute")),
        ("23:59:61Z", Comment("Invalid second")),
        ("23:59:59.1234567890Z", Comment("Too many decimal places")),
        ("23:59:59+24:00", Comment("Invalid timezone offset")),
        ("23:59:59-24:00", Comment("Invalid timezone offset")),
        ("23:59:59+01:60", Comment("Invalid timezone minute")),
        ("23:59:59+01:0", Comment("Invalid timezone format")),
        ("23:59:59", Comment("Missing timezone")),
        ("23:59:59.123", Comment("Missing timezone")),
        ("23:59:59+0100", Comment("Invalid timezone format")),
        ("23:59:59+01", Comment("Invalid timezone format")),
        ("23:59:59.123.456Z", Comment("Multiple decimal points")),
      ]
    )
    func invalidFullTimeParsing(timeString: String, message: Comment) throws {
      #expect(RFC3339.FullTime.parse(string: timeString) == nil, message)
    }
  }

  @Suite("DateTime Tests")
  struct DateTimeTests {

    @Test(
      "Valid date-time parsing",
      arguments: [
        "2024-04-04T12:00:00Z",
        "2024-02-29T23:59:59.999Z",
        "2024-02-29T23:59:60Z",    // Leap second
        "2024-12-31T00:00:00+14:00",
        "2024-01-01T00:00:00-14:00",
      ]
    )
    func validDateTimeParsing(dateTimeString: String) throws {
      let dateTime = try #require(RFC3339.DateTime.parse(string: dateTimeString))
      let parts = dateTimeString.split(separator: "T")
      let date = try #require(RFC3339.FullDate.parse(string: String(parts[0])))
      let time = try #require(RFC3339.FullTime.parse(string: String(parts[1])))

      #expect(dateTime.date.year == date.year, Comment("Year mismatch for \(dateTimeString)"))
      #expect(dateTime.date.month == date.month, Comment("Month mismatch for \(dateTimeString)"))
      #expect(dateTime.date.day == date.day, Comment("Day mismatch for \(dateTimeString)"))
      #expect(dateTime.time.hour == time.hour, Comment("Hour mismatch for \(dateTimeString)"))
      #expect(dateTime.time.minute == time.minute, Comment("Minute mismatch for \(dateTimeString)"))
      #expect(dateTime.time.second == time.second, Comment("Second mismatch for \(dateTimeString)"))
      #expect(dateTime.time.tzOffset == time.tzOffset, Comment("Timezone offset mismatch for \(dateTimeString)"))
    }

    @Test(
      "Invalid date-time parsing",
      arguments: [
        ("2024-04-04", Comment("Missing time")),
        ("12:00:00Z", Comment("Missing date")),
        ("2024-04-04 12:00:00Z", Comment("Wrong separator")),
        ("2024-04-04T12:00:00", Comment("Missing timezone")),
        ("2024-13-04T12:00:00Z", Comment("Invalid date")),
        ("2024-04-04T24:00:00Z", Comment("Invalid time")),
      ]
    )
    func invalidDateTimeParsing(dateTimeString: String, message: Comment) throws {
      #expect(RFC3339.DateTime.parse(string: dateTimeString) == nil, message)
    }
  }
}
