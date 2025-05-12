//
//  Schema-Numbers.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/3/25.
//

import SolidData
import SolidNumeric


extension Schema {

  public enum Numbers {

    public struct MultipleOf: AssertionBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .multipleOf

      public let multipleOf: BigDecimal

      public static func build(from schemaInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard let numberInstance = schemaInstance.number else {
          try context.invalidType(requiredType: .number)
        }

        let multipleOf = numberInstance.decimal

        return Self(multipleOf: multipleOf)
      }

      public func assert(instance: Value, context: inout Validator.Context) -> Assertion {

        guard let numberInstance = instance.number else {
          return .valid
        }

        if numberInstance.decimal.remainder(dividingBy: multipleOf) != .zero {
          return .invalid("Must be a multiple of \(multipleOf)")
        }

        return .valid
      }
    }

    public struct Minimum: AssertionBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .minimum

      public let minimum: BigDecimal

      public static func build(from schemaInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .number(let numberInstance) = schemaInstance else {
          try context.invalidType(requiredType: .number)
        }

        let minimum = numberInstance.decimal

        return Self(minimum: minimum)
      }

      public func prepare(parent: SubSchema, context: inout Builder.Context) throws {
      }

      public func assert(instance: Value, context: inout Validator.Context) -> Assertion {

        guard let numberInstance = instance.number else {
          return .valid
        }

        if let maximum = context.schema.behavior(Maximum.self)?.maximum {
          if minimum > maximum {
            return .invalid("Must be less than or equal to '\(Keyword.maximum)'")
          }
        }

        if numberInstance.decimal < minimum {
          return .invalid("Must be greater than or equal to \(minimum)")
        }

        return .valid
      }
    }

    public struct Maximum: AssertionBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .maximum

      public let maximum: BigDecimal

      public static func build(from schemaInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .number(let numberInstance) = schemaInstance else {
          try context.invalidType(requiredType: .number)
        }

        let maximum = numberInstance.decimal

        return Self(maximum: maximum)
      }

      public func prepare(parent: SubSchema, context: inout Builder.Context) throws {
      }

      public func assert(instance: Value, context: inout Validator.Context) -> Assertion {

        guard let numberInstance = instance.number else {
          return .valid
        }

        if let minimum = context.schema.behavior(Minimum.self)?.minimum {
          if maximum < minimum {
            return .invalid("Must be greater than or equal to '\(Keyword.minimum)'")
          }
        }

        if numberInstance.decimal > maximum {
          return .invalid("Must be less than or equal to \(maximum)")
        }

        return .valid
      }
    }

    public struct ExclusiveMinimum: AssertionBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .exclusiveMinimum

      public let exclusiveMinimum: BigDecimal

      public static func build(from schemaInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .number(let numberInstance) = schemaInstance else {
          try context.invalidType(requiredType: .number)
        }

        let exclusiveMinimum = numberInstance.decimal

        return Self(exclusiveMinimum: exclusiveMinimum)
      }

      public func assert(instance: Value, context: inout Validator.Context) -> Assertion {

        guard let numberInstance = instance.number else {
          return .valid
        }

        if let exclusiveMaximum = context.schema.behavior(ExclusiveMaximum.self)?.exclusiveMaximum {
          if exclusiveMinimum >= exclusiveMaximum {
            return .invalid("Must be less than '\(Keyword.exclusiveMaximum)'")
          }
        }

        if numberInstance.decimal <= exclusiveMinimum {
          return .invalid("Must be greater than \(exclusiveMinimum)")
        }

        return .valid
      }
    }

    public struct ExclusiveMaximum: AssertionBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .exclusiveMaximum

      public let exclusiveMaximum: BigDecimal

      public static func build(from schemaInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .number(let numberInstance) = schemaInstance else {
          try context.invalidType(requiredType: .number)
        }

        let exclusiveMaximum = numberInstance.decimal

        return Self(exclusiveMaximum: exclusiveMaximum)
      }

      public func prepare(parent: SubSchema, context: inout Builder.Context) throws {
      }

      public func assert(instance: Value, context: inout Validator.Context) -> Assertion {

        guard let numberInstance = instance.number else {
          return .valid
        }

        if let exclusiveMinimum = context.schema.behavior(ExclusiveMinimum.self)?.exclusiveMinimum {
          if exclusiveMaximum <= exclusiveMinimum {
            return .invalid("Must be greater than '\(Keyword.exclusiveMinimum)'")
          }
        }

        if numberInstance.decimal >= exclusiveMaximum {
          return .invalid("Must be less than \(exclusiveMaximum)")
        }

        return .valid
      }
    }

  }
}
