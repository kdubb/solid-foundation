//
//  Zone.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

import SolidCore

public struct Zone {

  public static let utc = neverThrow(try Zone(identifier: "UTC"))

  public let identifier: String
  public let rules: any ZoneRules

  public init(identifier: String, rules: any ZoneRules) {
    self.identifier = identifier
    self.rules = rules
  }

  public init(identifier: String) throws {
    let rulesLoader: ZoneRulesLoader = .system
    let rules = try rulesLoader.load(identifier: identifier)
    self.init(identifier: identifier, rules: rules)
  }

  public init(offset: ZoneOffset) {
    self.identifier = offset.description
    self.rules = FixedOffsetZoneRules(offset: offset)
  }

  public static func fixed(offset: ZoneOffset) -> Self {
    return Self(offset: offset)
  }

  public var isFixedOffset: Bool {
    return rules.isFixedOffset
  }

  public func offset(at instant: Instant) -> ZoneOffset {
    return rules.offset(at: instant)
  }

  public func offset(for dateTime: LocalDateTime) -> ZoneOffset {
    return rules.offset(for: dateTime)
  }

  public var fixedOffset: ZoneOffset? {
    guard isFixedOffset else {
      return nil
    }
    return rules.offset(at: .epoch)
  }
}


extension Zone: Equatable {

  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.identifier == rhs.identifier
  }

}

extension Zone: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }

}

extension Zone: Sendable {}


extension Zone: CustomStringConvertible {

  public var description: String {
    return identifier
  }

}

extension Zone {

  public init(availableComponents components: some ComponentContainer) {
    do {
      try self.init(identifier: components.valueIfPresent(for: .zoneId) ?? "UTC")
    } catch {
      fatalError("Invalid zone identifier")
    }
  }

}

extension Zone: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    do {
      try self.init(identifier: value)
    } catch {
      fatalError("Invalid zone identifier")
    }
  }
}
