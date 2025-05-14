//
//  ISO8601Tests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/12/25.
//

@testable import SolidTempo
import Testing


@Suite("ISO 8601 Date and Time Tests")
struct ISO8601ParsingTests {

  @Suite("LocalDate Tests")
  struct LocalDateTests {

    @Test(
      "Valid LocalDate parsing",
      arguments: [
        "2024-04-04",
        "2024-02-29",    // Leap year
        "2023-02-28",    // Non-leap year
        "2024-12-31",
        "2024-01-01",
      ]
    )
    func validLocalDateParsing(dateString: String) throws {
      let date = try #require(LocalDate.parse(string: dateString))
      let components = dateString.split(separator: "-")
      #expect(date.year == Int(components[0]), Comment("Year mismatch for \(dateString)"))
      #expect(date.month == Int(components[1]), Comment("Month mismatch for \(dateString)"))
      #expect(date.day == Int(components[2]), Comment("Day mismatch for \(dateString)"))
    }

    @Test(
      "Invalid LocalDate parsing",
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
    func invalidLocalDateParsing(dateString: String, message: Comment) throws {
      #expect(LocalDate.parse(string: dateString) == nil, message)
    }
  }

  @Suite("LocalTime Tests")
  struct LocalTimeTests {

    @Test(
      "Valid LocalTime parsing",
      arguments: [
        ("00:00:00", 0, 0, 0, 0),
        ("23:59:59", 23, 59, 59, 0),
        ("23:59:60", 0, 0, 0, 0),    // Leap second
        ("12:00:00.123", 12, 0, 0, 123_000_000),
        ("12:00:00.123456789", 12, 0, 0, 123456789),    // High precision
      ]
    )
    func validLocalTimeParsing(
      timeString: String,
      hour: Int,
      minute: Int,
      second: Int,
      nanosecond: Int
    ) throws {
      let time = try #require(LocalTime.parse(string: timeString))
      #expect(time.hour == hour, Comment("Hour mismatch for \(timeString)"))
      #expect(time.minute == minute, Comment("Minute mismatch for \(timeString)"))
      #expect(time.second == second, Comment("Second mismatch for \(timeString)"))
    }

    @Test(
      "Invalid LocalTime parsing",
      arguments: [
        ("24:00:00", Comment("Invalid hour")),
        ("23:60:00", Comment("Invalid minute")),
        ("23:59:61", Comment("Invalid second")),
        ("23:59:59.1234567890Z", Comment("Too many decimal places")),
        ("12:00:00+01:00", Comment("Timezone disallowed")),
        ("23:59:59.123.456Z", Comment("Multiple decimal points")),
      ]
    )
    func invalidLocalTimeParsing(timeString: String, message: Comment) throws {
      #expect(LocalTime.parse(string: timeString) == nil, message)
    }
  }

  @Suite("OffsetTime Tests")
  struct OffsetTimeTests {

    @Test(
      "Valid OffsetTime parsing",
      arguments: [
        ("00:00:00Z", 0, 0, 0, 0, 0),
        ("23:59:59Z", 23, 59, 59, 0, 0),
        ("23:59:60Z", 0, 0, 0, 0, 0),    // Leap second
        ("12:00:00.123Z", 12, 0, 0, 123_000_000, 0),
        ("12:00:00.123456789Z", 12, 0, 0, 123456789, 0),    // High precision
        ("12:00:00+01:00", 12, 0, 0, 0, 3600),
        ("12:00:00-01:00", 12, 0, 0, 0, -3600),
        ("12:00:00+14:00", 12, 0, 0, 0, 50400),
        ("12:00:00-14:00", 12, 0, 0, 0, -50400),
      ]
    )
    func validOffsetTimeParsing(
      timeString: String,
      hour: Int,
      minute: Int,
      second: Int,
      nanosecond: Int,
      tzOffset: Int
    ) throws {
      let time = try #require(OffsetTime.parse(string: timeString))
      #expect(time.hour == hour, Comment("Hour mismatch for \(timeString)"))
      #expect(time.minute == minute, Comment("Minute mismatch for \(timeString)"))
      #expect(time.second == second, Comment("Second mismatch for \(timeString)"))
      #expect(time.offset.totalSeconds == tzOffset, Comment("Timezone offset mismatch for \(timeString)"))
    }

    @Test(
      "Invalid OffsetTime parsing",
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
    func invalidOffsetTimeParsing(timeString: String, message: Comment) throws {
      #expect(OffsetTime.parse(string: timeString) == nil, message)
    }
  }

  @Suite("LocalDateTime Tests")
  struct LocalDateTimeTests {

    @Test(
      "Valid LocalDateTime parsing",
      .serialized,
      arguments: [
        ("2024-04-04T12:00:00", 2024, 4, 4, 12, 0, 0, 0),
        ("2024-02-29T23:59:59", 2024, 2, 29, 23, 59, 59, 0),    // Leap year
        ("2024-02-29T23:59:60", 2024, 3, 1, 0, 0, 0, 0),    // Leap second
        ("2024-12-31T00:00:00.123", 2024, 12, 31, 0, 0, 0, 123_000_000),
        ("2024-01-01T00:00:00.123456789", 2024, 1, 1, 0, 0, 0, 123_456_789),    // High precision
      ]
    )
    func validLocalDateTimeParsing(
      dateTimeString: String,
      year: Int,
      month: Int,
      day: Int,
      hour: Int,
      minute: Int,
      second: Int,
      nanosecond: Int
    ) throws {
      let dateTime = try #require(LocalDateTime.parse(string: dateTimeString))
      #expect(dateTime.date.year == year, Comment("Year mismatch for \(dateTimeString)"))
      #expect(dateTime.date.month == month, Comment("Month mismatch for \(dateTimeString)"))
      #expect(dateTime.date.day == day, Comment("Day mismatch for \(dateTimeString)"))
      #expect(dateTime.time.hour == hour, Comment("Hour mismatch for \(dateTimeString)"))
      #expect(dateTime.time.minute == minute, Comment("Minute mismatch for \(dateTimeString)"))
      #expect(dateTime.time.second == second, Comment("Second mismatch for \(dateTimeString)"))
      #expect(dateTime.time.nanosecond == nanosecond, Comment("Nanosecond mismatch for \(dateTimeString)"))
    }

    @Test(
      "Invalid LocalDateTime parsing",
      arguments: [
        ("2024-04-04", Comment("Missing time")),
        ("12:00:00", Comment("Missing date")),
        ("2024-04-04 12:00:00", Comment("Wrong separator")),
        ("2024-13-04T12:00:00", Comment("Invalid date")),
        ("2024-04-04T24:00:00", Comment("Invalid time")),
        ("2024-04-04T12:00:00Z", Comment("Timezone not allowed")),
        ("2024-04-04T12:00:00+01:00", Comment("Timezone not allowed")),
        ("2024-04-04T12:00:00.123.456", Comment("Multiple decimal points")),
        ("2024-04-04T12:00:00.1234567890", Comment("Too many decimal places")),
      ]
    )
    func invalidLocalDateTimeParsing(dateTimeString: String, message: Comment) throws {
      #expect(LocalDateTime.parse(string: dateTimeString) == nil, message)
    }
  }

  @Suite("OffsetDateTime Tests")
  struct OffsetDateTimeTests {

    @Test(
      "Valid OffsetDateTime parsing",
      .serialized,
      arguments: [
        ("2024-04-04T12:00:00Z", (2024, 4, 4, 12, 0, 0, 0, 0)),
        ("2024-02-29T23:59:59.999Z", (2024, 2, 29, 23, 59, 59, 999_000_000, 0)),    // Leap year
        ("2024-05-06T07:08:09.123456789Z", (2024, 5, 6, 7, 8, 9, 123456789, 0)),    // High precision
        ("2024-02-29T23:59:60Z", (2024, 3, 1, 0, 0, 0, 0, 0)),    // Leap second
        ("2024-12-31T00:00:00+14:00", (2024, 12, 31, 0, 0, 0, 0, 50400)),
        ("2024-01-01T00:00:00-14:00", (2024, 1, 1, 0, 0, 0, 0, -50400)),
      ]
    )
    func validOffsetDateTimeParsing(
      dateTimeString: String,
      parts: (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Int, offset: Int)
    ) throws {
      let dateTime = try #require(OffsetDateTime.parse(string: dateTimeString))

      #expect(dateTime.date.year == parts.year, Comment("Year mismatch for \(dateTimeString)"))
      #expect(dateTime.date.month == parts.month, Comment("Month mismatch for \(dateTimeString)"))
      #expect(dateTime.date.day == parts.day, Comment("Day mismatch for \(dateTimeString)"))
      #expect(dateTime.time.hour == parts.hour, Comment("Hour mismatch for \(dateTimeString)"))
      #expect(dateTime.time.minute == parts.minute, Comment("Minute mismatch for \(dateTimeString)"))
      #expect(dateTime.time.second == parts.second, Comment("Second mismatch for \(dateTimeString)"))
      #expect(dateTime.offset.totalSeconds == parts.offset, Comment("Timezone offset mismatch for \(dateTimeString)"))
    }

    @Test(
      "Invalid OffsetDateTime parsing",
      arguments: [
        ("2024-04-04", Comment("Missing time")),
        ("12:00:00Z", Comment("Missing date")),
        ("2024-04-04 12:00:00Z", Comment("Wrong separator")),
        ("2024-04-04T12:00:00", Comment("Missing timezone")),
        ("2024-13-04T12:00:00Z", Comment("Invalid date")),
        ("2024-04-04T24:00:00Z", Comment("Invalid time")),
      ]
    )
    func invalidOffsetDateTimeParsing(dateTimeString: String, message: Comment) throws {
      #expect(OffsetDateTime.parse(string: dateTimeString) == nil, message)
    }
  }

  @Suite("ZonedDateTime Tests")
  struct ZonedDateTimeTests {

    @Test(
      "Valid ZonedDateTime parsing",
      arguments: [
        ("2024-04-04T12:00:00[UTC]", 2024, 4, 4, 12, 0, 0, 0, "UTC"),
        ("2024-02-29T23:59:59[America/Los_Angeles]", 2024, 2, 29, 23, 59, 59, 0, "America/Los_Angeles"),    // Leap year
        ("2024-02-29T23:59:60[UTC]", 2024, 3, 1, 0, 0, 0, 0, "UTC"),    // Leap second
        ("2024-12-31T00:00:00.123[Europe/London]", 2024, 12, 31, 0, 0, 0, 123_000_000, "Europe/London"),
        ("2024-01-01T00:00:00.123456789[Asia/Baku]", 2024, 1, 1, 0, 0, 0, 123456789, "Asia/Baku"),    // High precision
      ]
    )
    func validZonedDateTimeParsing(
      dateTimeString: String,
      year: Int,
      month: Int,
      day: Int,
      hour: Int,
      minute: Int,
      second: Int,
      nanosecond: Int,
      zoneId: String
    ) throws {
      let dateTime = try #require(ZonedDateTime.parse(string: dateTimeString))
      #expect(dateTime.date.year == year, Comment("Year mismatch for \(dateTimeString)"))
      #expect(dateTime.date.month == month, Comment("Month mismatch for \(dateTimeString)"))
      #expect(dateTime.date.day == day, Comment("Day mismatch for \(dateTimeString)"))
      #expect(dateTime.time.hour == hour, Comment("Hour mismatch for \(dateTimeString)"))
      #expect(dateTime.time.minute == minute, Comment("Minute mismatch for \(dateTimeString)"))
      #expect(dateTime.time.second == second, Comment("Second mismatch for \(dateTimeString)"))
      #expect(dateTime.zone.identifier == zoneId, Comment("Zone ID mismatch for \(dateTimeString)"))
    }

    @Test(
      "Invalid ZonedDateTime parsing",
      arguments: [
        ("2024-04-04T12:00:00", Comment("Missing zone ID")),
        ("2024-04-04T12:00:00Z", Comment("Invalid zone format (Z)")),
        ("2024-04-04T12:00:00+01:00", Comment("Invalid zone format (offset)")),
        ("2024-04-04T12:00:00[Invalid/Zone]", Comment("Invalid zone ID")),
        ("2024-04-04T12:00:00[UTC", Comment("Missing closing bracket")),
        ("2024-04-04T12:00:00UTC]", Comment("Missing opening bracket")),
        ("2024-04-04T12:00:00.123.456[UTC]", Comment("Multiple decimal points")),
        ("2024-04-04T12:00:00.1234567890[UTC]", Comment("Too many decimal places")),
        ("2024-13-04T12:00:00[UTC]", Comment("Invalid date")),
        ("2024-04-04T24:00:00[UTC]", Comment("Invalid time")),
        ("2024-04-04 12:00:00[UTC]", Comment("Wrong separator")),
      ]
    )
    func invalidZonedDateTimeParsing(dateTimeString: String, message: Comment) throws {
      #expect(ZonedDateTime.parse(string: dateTimeString) == nil, message)
    }
  }
}
