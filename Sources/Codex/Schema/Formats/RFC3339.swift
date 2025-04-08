//
//  RFC3339.swift
//  Codex
//
//  Created by Kevin Wooten on 4/4/25.
//

import BigDecimal

/// Namespace for RFC-3339 related types and functions.
///
public struct RFC3339 {

  /// Represents a full date (YYYY-MM-DD).
  public struct FullDate {
    /// Year (YYYY).
    public var year: Int
    /// Month (MM).
    public var month: Int
    /// Day of the month (DD).
    public var day: Int

    /// Initializes a FullDate with the given year, month, and day.
    ///
    /// - Parameters:
    ///   - year: The year (YYYY).
    ///   - month: The month (MM).
    ///   - day: The day of the month (DD).
    public init?(year: Int, month: Int, day: Int) {
      self.year = year
      self.month = month
      self.day = day
    }

    /// Parses a `full-date` string (YYYY-MM-DD) per RFC3339.
    ///
    /// - Parameter string: The full-date string.
    /// - Returns: A FullDate instance if valid; otherwise, nil.
    public static func parse(string: String) -> FullDate? {
      // Swift regex literal for full-date with named capture groups.
      let regex = /^(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})$/
      guard let match = string.wholeMatch(of: regex) else {
        return nil
      }

      guard
        let year = Int(match.output.year),
        let month = Int(match.output.month),
        let day = Int(match.output.day)
      else {
        return nil
      }

      // Validate month range.
      guard (1...12).contains(month) else {
        return nil
      }

      let daysInMonth: Int
      switch month {
      case 1, 3, 5, 7, 8, 10, 12:
        daysInMonth = 31
      case 4, 6, 9, 11:
        daysInMonth = 30
      case 2:
        // Leap year check.
        if (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) {
          daysInMonth = 29
        } else {
          daysInMonth = 28
        }
      default:
        return nil
      }
      guard (1...daysInMonth).contains(day) else {
        return nil
      }

      return FullDate(year: year, month: month, day: day)
    }
  }

  /// Represents a full time (HH:MM:SS[.fraction](Z|(+|-)HH:MM)).
  public struct FullTime {
    /// Hour (HH).
    public var hour: Int
    /// Minute (MM).
    public var minute: Int
    /// Second (SS[.SSSSSSSSS]).
    public var second: BigDecimal
    /// Time offset from UTC in seconds.
    public var tzOffset: Int

    /// Initializes a FullTime with the given hour, minute, second, and timezone offset.
    ///
    /// - Parameters:
    ///  - hour: The hour (HH).
    ///  - minute: The minute (MM).
    ///  - second: The second (SS[.SSSSSSSSS]).
    ///  - tzOffset: The timezone offset from UTC in seconds.
    ///
    public init(hour: Int, minute: Int, second: BigDecimal, tzOffset: Int) {
      self.hour = hour
      self.minute = minute
      self.second = second
      self.tzOffset = tzOffset
    }

    /// Parses a `full-time` string (HH:MM:SS[.fraction](Z|[+-]HH:MM)) per RFC3339.
    ///
    /// - Parameter string: The full-time string.
    /// - Returns: A FullTime instance if valid; otherwise, nil.
    public static func parse(string: String) -> FullTime? {
      // Swift regex literal for full-time with named capture groups.
      // Group "fraction" is optional.
      let regex = /^(?<hour>\d{2}):(?<minute>\d{2}):(?<seconds>\d{2}(\.[0-9]{1,9})?)(?<offset>Z|[+\-]\d{2}:\d{2})$/
      guard let match = string.wholeMatch(of: regex) else {
        return nil
      }

      guard
        let hour = Int(match.output.hour),
        let minute = Int(match.output.minute)
      else {
        return nil
      }
      let second = BigDecimal(String(match.output.seconds))

      let tzOffsetStr = match.output.offset
      var tzOffset: Int = 0
      if tzOffsetStr == "Z" {
        tzOffset = 0
      } else {
        // Parse offset in the format ±HH:MM.
        let tzSign: Int = tzOffsetStr.first == "-" ? -1 : 1
        let tzOffsetBody = tzOffsetStr.dropFirst()    // Remove the sign.
        let tzComponents = tzOffsetBody.split(separator: ":")
        guard
          tzComponents.count == 2,
          let tzOffsetHour = Int(tzComponents[0]),
          let tzOffsetMinute = Int(tzComponents[1]),
          (0...14).contains(tzOffsetHour),
          (0...59).contains(tzOffsetMinute)
        else {
          return nil
        }
        tzOffset = tzSign * (tzOffsetHour * 3600 + tzOffsetMinute * 60)
      }

      // Validate time components.
      guard
        (0...23).contains(hour),
        (0...59).contains(minute)
      else {
        return nil
      }

      // Special handling for leap seconds
      if second == 60 {
        // Leap seconds are only valid at 23:59:60Z
        guard hour == 23 && minute == 59 && tzOffset == 0 else {
          return nil
        }
      } else {
        // Normal seconds must be in range 0-59
        guard second >= 0 && second < 60 else {
          return nil
        }
      }

      return FullTime(hour: hour, minute: minute, second: second, tzOffset: tzOffset)
    }
  }

  /// Represents a complete date-time: full-date, the letter "T", and full-time.
  public struct DateTime {
    /// The full date component.
    public var date: FullDate
    /// The full time component.
    public var time: FullTime

    /// Initializes a DateTime with the given date and time components.
    ///
    /// - Parameters:
    ///   - date: The full date component.
    ///   - time: The full time component.
    ///
    public init(date: FullDate, time: FullTime) {
      self.date = date
      self.time = time
    }

    /// Parses a complete `date-time` string (full-date "T" full-time) per RFC3339.
    ///
    /// - Parameter string: The date-time string.
    /// - Returns: A DateTime instance if valid; otherwise, nil.
    ///
    public static func parse(string: String) -> DateTime? {
      // Split the input at the literal "T" to separate the date and time.
      let parts = string.split(separator: "T", maxSplits: 1)
      guard parts.count == 2 else {
        return nil
      }
      let datePart = String(parts[0])
      let timePart = String(parts[1])

      guard
        let date = FullDate.parse(string: datePart),
        let time = FullTime.parse(string: timePart)
      else {
        return nil
      }

      return DateTime(date: date, time: time)
    }

    public func asValue() -> Value {
      return [
        "date": [
          "year": .number(date.year),
          "month": .number(date.month),
          "day": .number(date.day),
        ],
        "time": [
          "hour": .number(time.hour),
          "minute": .number(time.minute),
          "second": .number(time.second),
          "tzOffset": .number(time.tzOffset),
        ],
      ]
    }
  }

  /// A structure representing an ISO‑8601 duration.
  public struct Duration {
    /// Period as years, months, and days, or weeks.
    public enum Period {
      /// Years, months, and days.
      case date(years: Int?, months: Int?, days: Int?)
      /// Weeks.
      case weeks(Int)
    }

    /// Time as hours, minutes, and seconds.
    public struct Time {
      /// Hours (HH).
      public var hours: Int?
      /// Minutes (MM).
      public var minutes: Int?
      /// Seconds (SS[.SSSSSSSSS]).
      public var seconds: BigDecimal?
    }

    /// The period component of the duration.
    public var period: Period?
    /// The time component of the duration.
    public var time: Time?

    /// Initializes a Duration with the given period and time components.
    ///
    /// - Parameters:
    ///  - period: The period component.
    ///  - time: The time component.
    ///
    public init(period: Period?, time: Time?) {
      self.period = period
      self.time = time
    }

    /// Parses an ISO‑8601 duration string according to the RFC's ABNF.
    ///
    /// Supported formats include:
    /// - Weeks: `"P4W"`
    /// - Standard form: `"P3Y6M4DT12H30M5S"`, `"PT20M"`, `"P23DT23H"`, etc.
    ///
    /// - Parameter string: The duration string to parse.
    /// - Returns: A Duration instance if the input is valid; otherwise, nil.
    public static func parse(string: String) -> Duration? {
      // This regex uses named capture groups to extract each component.
      // It has two alternatives for the date part:
      // 1. A weeks-only duration: one or more digits followed by "W".
      // 2. A standard duration with optional years, months, days, and an optional time part.
      //
      // Lookahead (?=(?:\d+[YMD]|T(?:\d+[HMS]))
      // ensures that if the weeks alternative is not taken, at least one designator is present.
      let regex =
        /^P(?:(?<weeks>\d+)W|(?=(?:\d+[YMD]|T(?:\d+[HMS])))(?:(?<years>\d+)Y)?(?:(?<months>\d+)M)?(?:(?<days>\d+)D)?(?:T(?:(?<hours>\d+)H)?(?:(?<minutes>\d+)M)?(?:(?<seconds>\d+(?:\.\d+)?)S)?)?)$/

      guard let match = string.wholeMatch(of: regex) else {
        return nil
      }

      let output = match.output


      // If a weeks component is provided, that is the sole date field.
      let period: Period?
      if let weeksStr = output.weeks {
        period = .weeks(Int(weeksStr) ?? 0)
      } else {
        let years: Int? =
          if let yearsStr = output.years {
            Int(yearsStr)
          } else {
            nil
          }
        let months: Int? =
          if let monthsStr = output.months {
            Int(monthsStr)
          } else {
            nil
          }
        let days: Int? =
          if let daysStr = output.days {
            Int(daysStr)
          } else {
            nil
          }

        period =
          if years != nil || months != nil || days != nil {
            // If any date component is provided, create a Period instance.
            .date(years: years, months: months, days: days)
          } else {
            nil
          }
      }

      var hours: Int?
      if let hoursStr = output.hours {
        hours = Int(hoursStr) ?? 0
      }
      var minutes: Int?
      if let minutesStr = output.minutes {
        minutes = Int(minutesStr) ?? 0
      }
      var seconds: BigDecimal?
      if let secondsStr = output.seconds {
        seconds = BigDecimal(String(secondsStr))
      }

      // If any time component is provided, create a Time instance.
      let time: Time? =
        if hours != nil || minutes != nil || seconds != nil {
          Time(hours: hours, minutes: minutes, seconds: seconds)
        } else {
          nil
        }

      return Duration(period: period, time: time)
    }
  }
}
