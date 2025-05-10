//
//  Zone.swift
//  Codex
//
//  Created by Kevin Wooten on 4/27/25.
//

extension Tempo {

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

    internal init(valid identifier: String) {
      // swift-format-ignore: NeverUseForceTry
      try! self.init(identifier: identifier)
    }

    public init(offset: ZoneOffset) {
      self.identifier = offset.description
      self.rules = FixedOffsetZoneRules(offset: offset)
    }

    public static func fixed(offset: ZoneOffset) -> Self {
      return Self(offset: offset)
    }

    public var isFixed: Bool {
      return rules.isFixed
    }

    public func offset(at instant: Instant) -> ZoneOffset {
      return rules.offset(at: instant)
    }

    public var fixedOffset: ZoneOffset? {
      guard isFixed else {
        return nil
      }
      guard let offset = rules as? FixedOffsetZoneRules else {
        return rules.offset(at: .epoch)
      }
      return offset.offset
    }
  }

}

extension Tempo.Zone: Equatable {

  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.identifier == rhs.identifier
  }

}

extension Tempo.Zone: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }

}

extension Tempo.Zone: Sendable {}


extension Tempo.Zone: CustomStringConvertible {

  public var description: String {
    return identifier
  }

}

extension Tempo.Zone: Tempo.LinkedComponentContainer, Tempo.ComponentBuildable {

  public static let links: [any Tempo.ComponentLink<Self>] = [
    Tempo.ComponentKeyPathLink(.zoneId, to: \.identifier)
  ]

  public init(components: some Tempo.ComponentContainer) {
    do {
      try self.init(identifier: components.value(for: .zoneId))
    } catch {
      fatalError("Invalid zone identifier")
    }
  }

}

extension Tempo.Zone: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    do {
      try self.init(identifier: value)
    } catch {
      fatalError("Invalid zone identifier")
    }
  }
}
