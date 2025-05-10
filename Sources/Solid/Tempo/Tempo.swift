//
//  Tempo.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/26/25.
//

/// Tempo is a Java Time / JS Temporal style date and time library for Swift.
///
/// Tempo is a collection of types and functions for working with date and time in a way that is
/// consistent with the Java Time and JS Temporal libraries. It provides a set of types for
/// representing dates, times, durations, and instants, as well as functions for parsing and formatting
/// these types.
///
/// ### Component Coverage Matrix
///
/// This table shows which types support each temporal component in Tempo.
/// Group headers are embedded to support continuous table rendering.
///
/// | Group             | Component             | LocalDate | LocalTime | LocalDateTime | ZonedDateTime | OffsetDateTime | Instant | Period | Duration |
///|--------------------|------------------------|-----------|-----------|----------------|----------------|----------------|---------|--------|----------|
///| 📅 Date Components | `era`                  | ✅        |           | ✅             | ✅             |                |         |        |          |
///|                    | `year`                 | ✅        |           | ✅             | ✅             | ✅              |         |        |          |
///|                    | `yearOfEra`            | ✅        |           | ✅             | ✅             | ✅              |         |        |          |
///|                    | `monthOfYear`          | ✅        |           | ✅             | ✅             | ✅              |         |        |          |
///|                    | `weekOfYear`           | ✅        |           | ✅             | ✅             | ✅              |         |        |          |
///|                    | `weekOfMonth`          | ✅        |           | ✅             | ✅             | ✅              |         |        |          |
///|                    | `dayOfYear`            | ✅        |           | ✅             | ✅             | ✅              |         |        |          |
///|                    | `dayOfMonth`           | ✅        |           | ✅             | ✅             | ✅              |         |        |          |
///|                    | `dayOfWeek`            | ✅        |           | ✅             | ✅             | ✅              |         |        |          |
///|                    | `dayOfWeekForMonth`    | ✅        |           | ✅             | ✅             | ✅              |         |        |          |
///|                    | `yearForWeekOfYear`    | ✅        |           | ✅             | ✅             | ✅              |         |        |          |
///|                    | `isLeapMonth`          | ✅        |           | ✅             | ✅             | ✅              |         |        |          |
///| ⏰ Time Components  | `hourOfDay`            |           | ✅        | ✅             | ✅             | ✅              |         |        |          |
///|                    | `minuteOfHour`         |           | ✅        | ✅             | ✅             | ✅              |         |        |          |
///|                    | `secondOfMinute`       |           | ✅        | ✅             | ✅             | ✅              |         |        |          |
///|                    | `nanosecondOfSecond`   |           | ✅        | ✅             | ✅             | ✅              |         |        |          |
///| 🌐 Zone Info       | `zoneOffset`           |           |           |                | ✅             | ✅              |         |        |          |
///|                    | `zoneId`               |           |           |                | ✅             |                |         |        |          |
///|                    | `hoursOfZoneOffset`    |           |           |                | ✅             | ✅              |         |        |          |
///|                    | `minutesOfZoneOffset`  |           |           |                | ✅             | ✅              |         |        |          |
///|                    | `secondsOfZoneOffset`  |           |           |                | ✅             | ✅              |         |        |          |
///| 🕓 Epoch-based     | `durationSinceEpoch`   |           |           |                |                |                | ✅      |        |          |
///| 📐 Period Fields   | `numberOfYears`        |           |           |                |                |                |         | ✅     |          |
///|                    | `numberOfMonths`       |           |           |                |                |                |         | ✅     |          |
///|                    | `numberOfWeeks`        |           |           |                |                |                |         | ✅     |          |
///|                    | `numberOfDays`         |           |           |                |                |                |         | ✅     | ✅       |
///|                    | `totalYears`           |           |           |                |                |                |         | ✅     |          |
///|                    | `totalMonths`          |           |           |                |                |                |         | ✅     |          |
///|                    | `totalWeeks`           |           |           |                |                |                |         | ✅     |          |
///|                    | `totalDays`            |           |           |                |                |                |         | ✅     | ✅       |
///| 🕒 Duration Fields | `numberOfHours`        |           |           |                |                |                |         |        | ✅       |
///|                    | `numberOfMinutes`      |           |           |                |                |                |         |        | ✅       |
///|                    | `numberOfSeconds`      |           |           |                |                |                |         |        | ✅       |
///|                    | `numberOfMilliseconds` |           |           |                |                |                |         |        | ✅       |
///|                    | `numberOfMicroseconds` |           |           |                |                |                |         |        | ✅       |
///|                    | `numberOfNanoseconds`  |           |           |                |                |                |         |        | ✅       |
///|                    | `totalHours`           |           |           |                |                |                |         |        | ✅       |
///|                    | `totalMinutes`         |           |           |                |                |                |         |        | ✅       |
///|                    | `totalSeconds`         |           |           |                |                |                |         |        | ✅       |
///|                    | `totalMilliseconds`    |           |           |                |                |                |         |        | ✅       |
///|                    | `totalMicroseconds`    |           |           |                |                |                |         |        | ✅       |
///|                    | `totalNanoseconds`     |           |           |                |                |                |         |        | ✅       |
///
/// - Note: ``Tempo`` is a namespace for all types and functions related to date and time in this library.
///
public enum Tempo {}
