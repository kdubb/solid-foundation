//
//  Schema-Objects.swift
//  Codex
//
//  Created by Kevin Wooten on 2/3/25.
//

import BigDecimal
import OrderedCollections

extension Schema {

  public enum Objects {

    public struct Properties: ApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .properties

      public let propertySubSchemas: OrderedDictionary<String, SubSchema>

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard let propertiesInstance = keywordInstance.object else {
          try context.invalidType(requiredType: .object)
        }

        let propertySubSchemas = try context.subSchemas(for: propertiesInstance) { propertyInstance, context in
          guard let propertyKey = propertyInstance.string else {
            try context.invalidType(requiredType: .string)
          }
          return propertyKey
        }

        return Self(propertySubSchemas: propertySubSchemas)
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {

        guard let objectInstance = instance.object else {
          return .valid
        }

        var validations: [String: Validation] = [:]

        for (propertyKey, propertySubSchema) in propertySubSchemas {

          guard let propertyInstance = objectInstance[.string(propertyKey)] else {
            continue
          }

          let validation = context.validate(
            instance: .using(propertyInstance, at: propertyKey),
            using: propertySubSchema
          )
          validations[propertyKey] = validation
        }

        guard validations.allSatisfy(\.value.isValid) else {
          return .invalid
        }
        let validPropertyKeys = validations.filter { $0.value.isValid }.keys
        return .annotation(.array(validPropertyKeys.map { .string($0) }))
      }
    }

    public struct PatternProperties: ApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .patternProperties

      public let patternSubSchemas: OrderedDictionary<Pattern, SubSchema>

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard let patternSchemaInstances = keywordInstance.object else {
          try context.invalidType(requiredType: .object)
        }

        let patternSubSchemas = try context.subSchemas(for: patternSchemaInstances) { patternInstance, context in

          guard case .string(let patternString) = patternInstance else {
            try context.invalidType(requiredType: .string)
          }

          guard let pattern = try? Schema.Pattern(pattern: patternString) else {
            try context.invalidValue("Must be a valid regular expression")
          }

          return pattern
        }

        return Self(patternSubSchemas: patternSubSchemas)
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {

        guard let objectInstance = instance.object else {
          return .valid
        }

        var validations: [Validation] = []
        var validKeys: Set<String> = []
        var invalidKeys: Set<String> = []

        for (pattern, patternSubSchema) in patternSubSchemas {

          for propertyKeyVal in objectInstance.keys {

            guard let propertyKey = propertyKeyVal.string, pattern.matches(propertyKey) else {
              continue
            }

            let propertyInstance = objectInstance[propertyKeyVal].neverNil()

            let validation = context.validate(
              instance: .using(propertyInstance, at: propertyKey),
              using: patternSubSchema,
              at: pattern.value
            )
            validations.append(validation)

            if validation.isValid {
              validKeys.insert(propertyKey)
            } else {
              invalidKeys.insert(propertyKey)
            }
          }
        }

        guard validations.allSatisfy(\.isValid) else {
          return .invalid
        }
        let validPropertyKeys = validKeys.subtracting(invalidKeys)
        return .annotation(.array(validPropertyKeys.map { .string($0) }))
      }
    }

    public struct AdditionalProperties: ApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .additionalProperties

      public let dependencies: Set<Schema.Keyword> = [.properties, .patternProperties]

      public let additionalSubchema: SubSchema

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        let additionalSubchema = try context.subSchema(for: keywordInstance)

        return Self(additionalSubchema: additionalSubchema)
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {

        guard let objectInstance = instance.object else {
          return .valid
        }

        let validPropertiesKeys = context.siblingAnnotation(for: Properties.self).array(of: \.string)
        let validPatternPropertiesKeys = context.siblingAnnotation(for: PatternProperties.self).array(of: \.string)
        let allValidKeys = Set(validPropertiesKeys + validPatternPropertiesKeys)
        let additionalPropertyKeys = Set(objectInstance.keys.compactMap(\.string)).subtracting(allValidKeys)

        var validations: [String: Validation] = [:]

        for propertyKey in additionalPropertyKeys {

          guard let propertyInstance = objectInstance[.string(propertyKey)] else {
            continue
          }

          let validation = context.validate(
            instance: .using(propertyInstance, at: propertyKey),
            using: additionalSubchema
          )
          validations[propertyKey] = validation
        }

        guard validations.allSatisfy(\.value.isValid) else {
          return .invalid(
            validations.count == 1
              ? "Additional property \(validations.keys.map { "'\($0)'" }.joined()) not valid"
              : "Additional properties \(validations.keys.map { "'\($0)'" }.joined(separator: ", ")) not valid"
          )
        }
        let validPropertyKeys = validations.filter { $0.value.isValid }.keys
        return .annotation(.array(validPropertyKeys.map { .string($0) }))
      }
    }

    public struct Required: AssertionBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .required

      public let properties: Set<String>

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard let requiredValues = keywordInstance.array else {
          try context.invalidType(requiredType: .array)
        }

        let required = try requiredValues.map {
          guard case .string(let propertyName) = $0 else {
            try context.invalidValue("Must contain only strings")
          }
          return propertyName
        }

        let uniqueRequired = Set(required)
        if uniqueRequired.count != required.count {
          try context.invalidValue("Must contain unique strings")
        }

        return Self(properties: Set(requiredValues.compactMap(\.string)))
      }

      public func assert(instance: Value, context: inout Validator.Context) -> Assertion {

        guard let objectInstance = instance.object else {
          return .valid
        }

        let missing = properties.subtracting(objectInstance.keys.compactMap(\.string))
        if !missing.isEmpty {

          guard let firstMissing = missing.first, missing.count == 1 else {
            return .invalid("Missing required properties \(missing.map { "'\($0)'" }.joined(separator: ","))")
          }
          return .invalid("Missing required property '\(firstMissing)'")

        }

        return .valid
      }
    }

    public struct DependentRequired: AssertionBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .dependentRequired

      public let dependentRequired: [String: Set<String>]

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case let .object(requiredMap) = keywordInstance else {
          try context.invalidValue("Must be an array")
        }

        var dependentRequired: [String: Set<String>] = [:]

        for (requiredKey, requiredValue) in requiredMap {

          guard case .string(let dependencyKey) = requiredKey else {
            try context.invalidValue("Must contain only string keys")
          }

          guard case .array(let requiredPropertyValues) = requiredValue else {
            try context.invalidValue("Must be an array", at: dependencyKey)
          }

          let requiredProperties = requiredPropertyValues.compactMap(\.string)
          if requiredProperties.count != requiredPropertyValues.count {
            try context.invalidValue("Must contain only strings", at: dependencyKey)
          }

          let uniqueRequired = Set(requiredProperties)

          if requiredProperties.count != uniqueRequired.count {
            try context.invalidValue("Must contain unique strings", at: dependencyKey)
          }

          dependentRequired[dependencyKey] = uniqueRequired
        }

        return Self(dependentRequired: dependentRequired)
      }

      public func assert(instance: Value, context: inout Validator.Context) -> Assertion {

        guard let object = instance.object else {
          return .valid
        }

        let objectKeys = Set(object.keys.compactMap(\.string))

        var invalid = 0

        for (dependencyProperty, requiredProperties) in dependentRequired
        where objectKeys.contains(dependencyProperty) {

          let missing = requiredProperties.subtracting(objectKeys)
          if !missing.isEmpty {
            invalid += 1
            let missingProperties = missing.map { "'\($0)'" }.joined(separator: ",")
            context.invalid(
              "Property '\(dependencyProperty)' requires properties \(missingProperties) to be present",
              at: dependencyProperty
            )
          }
        }

        return invalid == 0 ? .valid : .invalid("Dependent required properties not present")
      }
    }

    public struct PropertyNames: ApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .propertyNames

      public let nameSubchema: SubSchema

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        let nameSubchema = try context.subSchema(for: keywordInstance)

        return Self(nameSubchema: nameSubchema)
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {

        guard let objectInstance = instance.object else {
          return .valid
        }

        var valid = true

        for propertyKey in objectInstance.keys {
          let result = context.validate(
            instance: .using(propertyKey, at: "@"),
            using: nameSubchema,
            at: propertyKey.string
          )
          valid = valid && result.isValid
        }

        guard valid else {
          return .invalid("Properties names must match '\(Keyword.propertyNames)'")
        }
        return .valid
      }
    }

    public struct MinProperties: AssertionBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .minProperties

      public let minProperties: Int

      public func assert(instance: Value, context: inout Validator.Context) -> Assertion {

        guard let object = instance.object else {
          return .valid
        }

        if let maxProperties = context.schema.behavior(MaxProperties.self)?.maxProperties {
          if minProperties > maxProperties {
            return .invalid("Must be less than or equal to '\(Keyword.maxProperties)'")
          }
        }

        if object.keys.count < minProperties {
          return .invalid("Must have at least \(minProperties) properties")
        }

        return .valid
      }

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard let minPropertiesNum = keywordInstance.number else {
          try context.invalidType(requiredType: .number)
        }

        guard let minProperties: Int = minPropertiesNum.asInt() else {
          try context.invalidValue("Must be an integer")
        }

        return Self(minProperties: minProperties)
      }
    }

    public struct MaxProperties: AssertionBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .maxProperties

      public let maxProperties: Int

      public func assert(instance: Value, context: inout Validator.Context) -> Assertion {

        guard let objectInstance = instance.object else {
          return .valid
        }

        if let minProperties = context.schema.behavior(MinProperties.self)?.minProperties {
          if maxProperties < minProperties {
            return .invalid("Must be greater than or equal to '\(Keyword.minProperties)'")
          }
        }

        if objectInstance.keys.count > maxProperties {
          return .invalid("Must have at most \(maxProperties) properties")
        }

        return .valid
      }

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard let maxPropertiesNum = keywordInstance.number else {
          try context.invalidType(requiredType: .number)
        }

        guard let maxProperties: Int = maxPropertiesNum.asInt() else {
          try context.invalidValue("Must be an integer")
        }

        return Self(maxProperties: maxProperties)
      }
    }

    public struct UnevaluatedProperties: UnevaluatedBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .unevaluatedProperties

      public let dependencies: Set<Schema.Keyword> = [.properties, .patternProperties, .additionalProperties]

      public let unevaluatedPropertiesSubSchema: SubSchema

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {

        guard let objectInstance = instance.object else {
          return .valid
        }

        let propertiesAnns = context.adjacentAnnotations(for: .properties)
        let patternPropertiesAnns = context.adjacentAnnotations(for: .patternProperties)
        let additionalPropertiesAnns = context.adjacentAnnotations(for: .additionalProperties)
        let unevaluatedPropertiesAnns = context.adjacentAnnotations(for: .unevaluatedProperties)

        let unevaluatedPropertyKeys: Set<String>

        if propertiesAnns.isEmpty && patternPropertiesAnns.isEmpty
          && additionalPropertiesAnns.isEmpty && unevaluatedPropertiesAnns.isEmpty
        {

          unevaluatedPropertyKeys = Set(objectInstance.keys.compactMap(\.string))

        } else {

          let allPropertyKeys = Set(objectInstance.keys.compactMap(\.string))
          let evaluatedPropertyKeys = propertiesAnns.propertyKeys()
            .union(patternPropertiesAnns.propertyKeys())
            .union(additionalPropertiesAnns.propertyKeys())
            .union(unevaluatedPropertiesAnns.propertyKeys())

          unevaluatedPropertyKeys = allPropertyKeys.subtracting(evaluatedPropertyKeys)
        }

        var validations: [String: Validation] = [:]

        for propertyKey in unevaluatedPropertyKeys {

          let propertyInstance = objectInstance[.string(propertyKey)].neverNil()

          let validation = context.validate(
            instance: .using(propertyInstance, at: propertyKey),
            using: unevaluatedPropertiesSubSchema
          )
          validations[propertyKey] = validation
        }

        guard validations.allSatisfy(\.value.isValid) else {
          return .invalid
        }
        let validPropertyKeys = validations.filter { $0.value.isValid }.keys
        return .annotation(.array(validPropertyKeys.map { .string($0) }))
      }

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        let unevaluatedPropertiesSubSchema = try context.subSchema(for: keywordInstance)

        return Self(unevaluatedPropertiesSubSchema: unevaluatedPropertiesSubSchema)
      }
    }
  }
}
