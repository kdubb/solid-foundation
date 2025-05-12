//
//  ZoneOffsetTests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

@testable import SolidTempo
import Testing


@Suite("ZoneOffset Tests")
struct ZoneOffsetTests {

  @Test(
    "Hours/Minutes/Seconds Validation",
    .serialized,
    arguments: [
      // Valid cases
      (0, 0, 0, nil, nil),
      (1, 30, 45, nil, nil),
      (-1, -30, -45, nil, nil),
      (18, 0, 0, nil, nil),
      (-18, 0, 0, nil, nil),

      // Invalid hours
      (19, 0, 0, "Invalid hours value", "Value 19 is outside valid range -18...18"),
      (-19, 0, 0, "Invalid hours value", "Value -19 is outside valid range -18...18"),

      // Invalid minutes
      (1, 60, 0, "Invalid minutes value", "Value 60 is outside valid range -59...59"),
      (1, -60, 0, "Invalid minutes value", "Value -60 is outside valid range -59...59"),

      // Invalid seconds
      (1, 0, 60, "Invalid seconds value", "Value 60 is outside valid range -59...59"),
      (1, 0, -60, "Invalid seconds value", "Value -60 is outside valid range -59...59"),

      // Mismatching signs
      (-1, 1, 0, "Invalid minutes value", "Minutes must be negative when the hour is negative"),
      (1, -1, 0, "Invalid minutes value", "Minutes must be positive when the hour is positive"),
      (-1, 0, 1, "Invalid seconds value", "Seconds must be negative when the hour is negative"),
      (1, 0, -1, "Invalid seconds value", "Seconds must be positive when the hour is positive"),

      // Invalid total seconds
      (18, 0, 1, "Invalid total seconds value", "Total offset must be less than 18 hours"),
      (-18, 0, -1, "Invalid total seconds value", "Total offset must be less than 18 hours"),
    ]
  )
  func testHoursMinutesSecondsValidation(
    hours: Int,
    minutes: Int,
    seconds: Int,
    expectedErrorDescription: String?,
    expectedFailureReason: String?
  ) throws {
    if let expectedErrorDescription {
      let error = try #require(throws: Error.self) {
        try ZoneOffset(hours: hours, minutes: minutes, seconds: seconds)
      }
      #expect(error.errorDescription == expectedErrorDescription)
      #expect(error.failureReason == expectedFailureReason)
      let error2 = try #require(throws: Error.self) {
        try ZoneOffset(totalSeconds: 0).with(hours: hours, minutes: minutes, seconds: seconds)
      }
      #expect(error2.errorDescription == expectedErrorDescription)
      #expect(error2.failureReason == expectedFailureReason)
    } else {
      let offset = try ZoneOffset(hours: hours, minutes: minutes, seconds: seconds)
      #expect(offset.hours == hours)
      #expect(offset.minutes == minutes)
      #expect(offset.seconds == seconds)
      let offset2 = try ZoneOffset(totalSeconds: 0).with(hours: hours, minutes: minutes, seconds: seconds)
      #expect(offset2.hours == hours)
      #expect(offset2.minutes == minutes)
      #expect(offset2.seconds == seconds)
    }
  }

  @Test(
    "Accessors",
    arguments: [
      (3660, 1, 1, 0),
      (-3660, -1, -1, 0),
      (0, 0, 0, 0),
      (60, 0, 1, 0),
      (-60, 0, -1, 0),
      (3600, 1, 0, 0),
      (-3600, -1, 0, 0),
    ]
  )
  func testAccessors(totalSeconds: Int, hours: Int, minutes: Int, seconds: Int) throws {
    let offset = try ZoneOffset(totalSeconds: totalSeconds)
    #expect(offset.totalSeconds == totalSeconds)
    #expect(offset.hours == hours)
    #expect(offset.minutes == minutes)
    #expect(offset.seconds == seconds)
  }

  @Test("Description")
  func testDescription() throws {
    let offset = try ZoneOffset(totalSeconds: -3660)
    #expect(offset.description == "-01:01")

    let offset2 = try ZoneOffset(totalSeconds: 3660)
    #expect(offset2.description == "+01:01")

    let offset3 = try ZoneOffset(totalSeconds: 0)
    #expect(offset3.description == "+00:00")

    let offset4 = try ZoneOffset(totalSeconds: 60)
    #expect(offset4.description == "+00:01")

    let offset5 = try ZoneOffset(totalSeconds: -60)
    #expect(offset5.description == "-00:01")

    let offset6 = try ZoneOffset(hours: 12, minutes: 34, seconds: 56)
    #expect(offset6.description == "+12:34:56")

    let offset7 = try ZoneOffset(hours: -12, minutes: -34, seconds: -56)
    #expect(offset7.description == "-12:34:56")
  }
}
