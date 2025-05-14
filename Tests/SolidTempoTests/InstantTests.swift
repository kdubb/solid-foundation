//
//  InstantTests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/12/25.
//

@testable import SolidTempo
import Testing


@Suite("Instant Tests")
struct InstantTests {

  @Test("Instant initialization with duration")
  func testInitialization() {
    let duration = Duration.seconds(100)
    let instant = Instant(durationSinceEpoch: duration)
    #expect(instant.durationSinceEpoch == duration)
  }

  @Test("Instant static properties")
  func testStaticProperties() {
    #expect(Instant.epoch.durationSinceEpoch == .zero)
    #expect(Instant.min.durationSinceEpoch == .min)
    #expect(Instant.max.durationSinceEpoch == .max)
  }

  @Test("Instant arithmetic operations")
  func testArithmeticOperations() {
    let instant1 = Instant(durationSinceEpoch: .seconds(100))
    let instant2 = Instant(durationSinceEpoch: .seconds(50))
    let duration = Duration.seconds(25)

    // Subtraction between instants
    #expect(instant1 - instant2 == .seconds(50))

    // Addition with duration
    #expect(instant1 + duration == Instant(durationSinceEpoch: .seconds(125)))

    // Subtraction with duration
    #expect(instant1 - duration == Instant(durationSinceEpoch: .seconds(75)))

    // Compound assignment
    var instant = instant1
    instant += duration
    #expect(instant == Instant(durationSinceEpoch: .seconds(125)))

    instant -= duration
    #expect(instant == instant1)
  }

  @Test("Instant comparison")
  func testComparison() {
    let instant1 = Instant(durationSinceEpoch: .seconds(100))
    let instant2 = Instant(durationSinceEpoch: .seconds(50))

    #expect(instant1 > instant2)
    #expect(instant2 < instant1)
    #expect(instant1 != instant2)
    #expect(instant1 == Instant(durationSinceEpoch: .seconds(100)))
  }

  @Test("Instant description")
  func testDescription() {
    let instant = Instant(durationSinceEpoch: .seconds(100))
    #expect(instant.description == "1 minute, 40 seconds")
  }

  @Test("Instant now")
  func testNow() {
    let now = Instant.now()
    #expect(now.durationSinceEpoch > .zero)
  }

  @Test("Instant component container")
  func testComponentContainer() {
    let instant = Instant(durationSinceEpoch: .seconds(100))

    #expect(instant.value(for: .totalNanoseconds) == 100_000_000_000)    // 100 seconds in nanoseconds
  }

  @Test("Instant component arithmetic")
  func testComponentArithmetic() throws {
    let instant = Instant(durationSinceEpoch: .seconds(100))
    let time = try LocalTime(hour: 1, minute: 1, second: 1, nanosecond: 1)
    let result = try instant.adding(time)
    let expected = Instant(durationSinceEpoch: .seconds(100) + .hours(1) + .minutes(1) + .seconds(1) + .nanoseconds(1))

    #expect(result == expected)
  }
}
