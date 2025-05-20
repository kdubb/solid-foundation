//
//  ZoneRulesTests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/14/25.
//

@testable import SolidTempo
import SolidCore
import Testing


@Suite("ZoneRules Tests")
struct ZoneRulesTests {

  @Test("Transition resolution (Provided - Gap)")
  func checkTransitionResolutionProvidedGap() throws {
    let zone = try Zone(identifier: "America/Los_Angeles")
    let dstTransition = try #require(
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2025, month: 3, day: 9, hour: 2, minute: 0, second: 0, nanosecond: 0)
      )
    )
    let dstTransition2 = try #require(
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2025, month: 3, day: 9, hour: 2, minute: 30, second: 0, nanosecond: 0)
      )
    )
    let dstTransition3 = try #require(
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2025, month: 3, day: 9, hour: 2, minute: 59, second: 59, nanosecond: 999_999_999)
      )
    )
    let dstTransition4 = zone.rules.applicableTransition(
      for: try LocalDateTime(year: 2025, month: 3, day: 9, hour: 3, minute: 0, second: 0, nanosecond: 0)
    )
    #expect(dstTransition.before.local == dstTransition2.before.local)
    #expect(dstTransition.before.local == dstTransition3.before.local)
    #expect(dstTransition4 == nil)
  }

  @Test("Transition resolution (Provided - Overlap)")
  func checkTransitionResolutionProvidedOverlap() throws {
    let zone = try Zone(identifier: "America/New_York")
    let stdTransition = try #require(
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2025, month: 11, day: 2, hour: 1, minute: 0, second: 0, nanosecond: 0)
      )
    )
    let stdTransition2 = try #require(
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2025, month: 11, day: 2, hour: 1, minute: 30, second: 0, nanosecond: 0)
      )
    )
    let stdTransition3 = try #require(
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2025, month: 11, day: 2, hour: 1, minute: 59, second: 59, nanosecond: 999_999_999)
      )
    )
    let stdTransition4 =
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2025, month: 11, day: 2, hour: 2, minute: 30, second: 0, nanosecond: 0)
      )
    #expect(stdTransition.before.local == stdTransition2.before.local)
    #expect(stdTransition.before.local == stdTransition3.before.local)
    #expect(stdTransition4 == nil)
  }

  @Test("Transition Resolution (Projected - Gap)")
  func checkTransitionResolutionProjectedGap() throws {
    let zone = try Zone(identifier: "Europe/Oslo")
    let projectedDstTransition = try #require(
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2825, month: 3, day: 30, hour: 2, minute: 0, second: 0, nanosecond: 0),
      )
    )
    let projectedDstTransition2 = try #require(
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2825, month: 3, day: 30, hour: 2, minute: 30, second: 0, nanosecond: 0),
      )
    )
    let projectedDstTransition3 = try #require(
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2825, month: 3, day: 30, hour: 2, minute: 59, second: 59, nanosecond: 999_999_999),
      )
    )
    let projectedDstTransition4 =
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2825, month: 3, day: 30, hour: 3, minute: 0, second: 0, nanosecond: 0),
      )
    #expect(projectedDstTransition.before.local == projectedDstTransition2.before.local)
    #expect(projectedDstTransition.before.local == projectedDstTransition3.before.local)
    #expect(projectedDstTransition4 == nil)
  }

  @Test("Transition Resolution (Projected - Overlap)")
  func checkTransitionResolutionProjectedOverlap() throws {
    let zone = try Zone(identifier: "Europe/Oslo")
    let projectedStdTransition = try #require(
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2825, month: 10, day: 26, hour: 2, minute: 0, second: 0, nanosecond: 0)
      )
    )
    let projectedStdTransition2 = try #require(
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2825, month: 10, day: 26, hour: 2, minute: 30, second: 0, nanosecond: 0)
      )
    )
    let projectedStdTransition3 = try #require(
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2825, month: 10, day: 26, hour: 2, minute: 59, second: 59, nanosecond: 999_999_999)
      )
    )
    let projectedStdTransition4 =
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2825, month: 10, day: 26, hour: 3, minute: 0, second: 0, nanosecond: 0)
      )
    #expect(projectedStdTransition.before.local == projectedStdTransition2.before.local)
    #expect(projectedStdTransition.before.local == projectedStdTransition3.before.local)
    #expect(projectedStdTransition4 == nil)
  }

  @Test("Local start/end times in transitions")
  func checkLocalStartEndTimesInTransitions() throws {
    let zone = try Zone(identifier: "America/New_York")
    let dstTransition = try #require(
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2025, month: 3, day: 9, hour: 2, minute: 0, second: 0, nanosecond: 0)
      )
    )
    #expect(
      try dstTransition.before.local
        == LocalDateTime(year: 2025, month: 3, day: 9, hour: 2, minute: 0, second: 0, nanosecond: 0)
    )
    #expect(
      try dstTransition.after.local
        == LocalDateTime(year: 2025, month: 3, day: 9, hour: 3, minute: 0, second: 0, nanosecond: 0)
    )

    let stdTransition = try #require(
      zone.rules.applicableTransition(
        for: try LocalDateTime(year: 2025, month: 11, day: 2, hour: 1, minute: 0, second: 0, nanosecond: 0)
      )
    )
    #expect(
      try stdTransition.before.local
        == LocalDateTime(year: 2025, month: 11, day: 2, hour: 2, minute: 0, second: 0, nanosecond: 0)
    )
    #expect(
      try stdTransition.after.local
        == LocalDateTime(year: 2025, month: 11, day: 2, hour: 1, minute: 0, second: 0, nanosecond: 0)
    )
  }


}
