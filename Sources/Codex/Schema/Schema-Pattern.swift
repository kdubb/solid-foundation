//
//  Schema-Pattern.swift
//  Codex
//
//  Created by Kevin Wooten on 2/3/25.
//

extension Schema {

  public struct Pattern {

    public let value: String
    public nonisolated(unsafe) let regex: Regex<AnyRegexOutput>

    public func matches(_ string: String) -> Bool {
      guard (try? regex.firstMatch(in: string)) != nil else {
        return false
      }
      return true
    }
  }

}

extension Schema.Pattern {

  public init(pattern: String) throws {
    self.value = pattern
    self.regex = try Regex(pattern)
  }

  public init(valid: String) {
    do {
      self.value = valid
      self.regex = try Regex(valid)
    } catch {
      fatalError("Invalid regex pattern: \(valid)")
    }
  }

}

extension Schema.Pattern: Sendable {}

extension Schema.Pattern: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }
}

extension Schema.Pattern: Equatable {

  public static func == (lhs: Schema.Pattern, rhs: Schema.Pattern) -> Bool {
    return lhs.value == rhs.value
  }
}

extension Schema.Pattern: CustomStringConvertible {

  public var description: String {
    return "\(value)"
  }
}
