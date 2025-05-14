//
//  ZoneTransitionRuleTests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/13/25.
//

@testable import SolidTempo
import Testing
import Foundation

@Suite("ZoneTransitionRule Tests")
struct ZoneTransitionRuleTests {

  @Test("Check local start/end times in transitions")
  func checkLocalStartEndTimesInTransitions() throws {
    let zone = try Zone(identifier: "America/New_York")
    let rule = zone.rules.applicableTransition(for: try LocalDateTime(year: 2025, month: 3, day: 9, hour: 2, minute: 0, second: 0, nanosecond: 0))
    print(rule)
  }

  @Test("Rule with dayOffset >= 24 hours")
  func testRuleWithOffsetGreaterThan24Hours() throws {
    var cal = Calendar(identifier: .iso8601)
    cal.timeZone = TimeZone(identifier: "Asia/Gaza")!

    let zone = try Zone(identifier: "Asia/Gaza")

    let dateBefore = cal.date(from: DateComponents(year: 2501, month: 3, day: 20, hour: 8, minute: 0, second: 0, nanosecond: 0))!
    let dateAfter = cal.date(from: DateComponents(year: 2501, month: 3, day: 26, hour: 20, minute: 0, second: 0, nanosecond: 0))!
    print(dateBefore.timeIntervalSince1970)
    print(dateAfter.timeIntervalSince1970)

    let before = try Instant(LocalDateTime(year: 2501, month: 3, day: 20, hour: 8, minute: 0, second: 0, nanosecond: 0).at(zone: zone))
    let after = try Instant(LocalDateTime(year: 2501, month: 3, day: 26, hour: 20, minute: 0, second: 0, nanosecond: 0).at(zone: zone))
    print(before.durationSinceEpoch[.totalSeconds])
    print(after.durationSinceEpoch[.totalSeconds])

    let dateOffsetBefore = cal.timeZone.secondsFromGMT(for: dateBefore)
    let dateOffsetAfter = cal.timeZone.secondsFromGMT(for: dateAfter)

    print(dateOffsetBefore)
    print(dateOffsetAfter)

    let offsetBefore = zone.rules.offset(at: before)
    let offsetAfter = zone.rules.offset(at: after)

    print(offsetBefore)
    print(offsetAfter)
  }


}
