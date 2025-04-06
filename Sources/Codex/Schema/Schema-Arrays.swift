//
//  Schema-Arrays.swift
//  Codex
//
//  Created by Kevin Wooten on 2/4/25.
//

extension Schema {

  public enum Arrays {

    public struct PrefixItems: ApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .prefixItems

      public let prefixSubSchemas: [SubSchema]

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .array(let prefixSchemaInstances) = keywordInstance else {
          try context.invalidType(requiredType: .array)
        }

        let prefixSubSchemas = try context.subSchemas(for: prefixSchemaInstances)

        return Self(prefixSubSchemas: prefixSubSchemas)
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {

        guard let arrayInstance = instance.array else {
          return .valid
        }

        var validations: [Validation] = []
        var maxIndexApplied: Int = -1

        for (prefixIndex, prefixSubSchema) in prefixSubSchemas.enumerated() {
          guard prefixIndex < arrayInstance.count else {
            break
          }
          let prefixInstance = arrayInstance[prefixIndex]
          let validation = context.validate(instance: .using(prefixInstance, at: prefixIndex), using: prefixSubSchema)
          validations.append(validation)
          if validation.isValid {
            maxIndexApplied = prefixIndex
          }
        }

        let valid = validations.allSatisfy(\.isValid)

        return valid ? .annotation(.number(maxIndexApplied)) : .invalid
      }
    }

    public struct Items: ApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .items

      public let dependencies: Set<Schema.Keyword> = [.prefixItems]

      public let itemSubSchema: SubSchema

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        let itemSubSchema = try context.subSchema(for: keywordInstance)

        return Self(itemSubSchema: itemSubSchema)
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {

        guard let arrayInstance = instance.array else {
          return .valid
        }

        let prefixItemsMaxIndex = context.siblingAnnotation(for: PrefixItems.self).int(default: -1)
        let prefixItemsCount = prefixItemsMaxIndex + 1

        let suffixItems = arrayInstance.dropFirst(prefixItemsCount)

        var valid = true

        for (itemIndex, itemInstance) in suffixItems.enumerated()
        where !context.validate(instance: .using(itemInstance, at: itemIndex), using: itemSubSchema).isValid {
          valid = false
        }

        return valid ? .annotation(.bool(!suffixItems.isEmpty)) : .invalid
      }
    }

    public struct MinItems: AssertionBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .minItems

      public let minItems: Int

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .number(let minItemsInstance) = keywordInstance else {
          try context.invalidType(requiredType: .number)
        }

        guard let minItems: Int = minItemsInstance.asInt() else {
          try context.invalidValue("Must be an integer")
        }

        if minItems < 0 {
          try context.invalidValue("Must be greater than zero")
        }

        return Self(minItems: minItems)
      }

      public func assert(instance: Value, context: inout Validator.Context) -> Assertion {

        if let maxItems = context.schema.behavior(MaxItems.self)?.maxItems {
          if minItems > maxItems {
            return .invalid("Must be less than or equal to '\(Keyword.maxItems)'")
          }
        }

        guard let arrayInstance = instance.array else {
          return .valid
        }

        if arrayInstance.count < minItems {
          return .invalid("Must contain a miniumum of \(minItems) items")
        }

        return .valid
      }
    }

    public struct MaxItems: AssertionBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .maxItems

      public let maxItems: Int

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .number(let maxItemsInstance) = keywordInstance else {
          try context.invalidType(requiredType: .number)
        }

        guard let maxItems: Int = maxItemsInstance.asInt() else {
          try context.invalidValue("Must be an integer")
        }

        if maxItems < 0 {
          try context.invalidValue("Must be greater than zero")
        }

        return Self(maxItems: maxItems)
      }

      public func assert(instance: Value, context: inout Validator.Context) -> Assertion {

        if let minItems = context.schema.behavior(MinItems.self)?.minItems {
          if maxItems < minItems {
            return .invalid("Must be greater than or equal to '\(Keyword.minItems)'")
          }
        }

        guard let arrayInstance = instance.array else {
          return .valid
        }

        if arrayInstance.count > maxItems {
          return .invalid("Must contain a maximum of \(maxItems) items")
        }

        return .valid
      }
    }

    public struct UniqueItems: AssertionBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .uniqueItems

      public let uniqueItems: Bool

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .bool(let uniqueItems) = keywordInstance else {
          try context.invalidType(requiredType: .boolean)
        }

        return Self(uniqueItems: uniqueItems)
      }

      public func assert(instance: Value, context: inout Validator.Context) -> Assertion {

        guard let arrayInstance = instance.array, uniqueItems else {
          return .valid
        }


        if !Self.isUnique(arrayInstance) {
          return .invalid("Must contain unique items")
        }

        return .valid
      }

      public static func isUnique(_ array: [Value]) -> Bool {
        for (idx, item) in array.enumerated() {
          for (otherIdx, otherItem) in array.enumerated() where idx != otherIdx {
            if Value.schemaEqual(item, otherItem) {
              return false
            }
          }
        }
        return true
      }
    }

    public struct Contains: ApplicatorBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .contains

      public let containsSubSchema: SubSchema

      public init(containsSubSchema: SubSchema) {
        self.containsSubSchema = containsSubSchema
      }

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        let containsSubSchema = try context.subSchema(for: keywordInstance)

        return Self(containsSubSchema: containsSubSchema)
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {

        guard let arrayInstance = instance.array else {
          return .valid
        }

        let required: Bool
        if let minContains = context.schema.behavior(MinContains.self)?.minContains {
          required = minContains > 0
        } else {
          required = true
        }

        var validIndices = Set<Int>()

        for (itemIndex, itemInstance) in arrayInstance.enumerated()
        where context.validate(instance: .using(itemInstance, at: itemIndex), using: containsSubSchema).isValid {
          validIndices.insert(itemIndex)
        }

        guard !validIndices.isEmpty || !required else {
          return .invalid("Must contain at least one item matching '\(Keyword.contains)'")
        }
        return .annotation(.array(validIndices.map { .number($0) }))
      }
    }

    public struct MinContains: AssertionBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .minContains

      public let dependencies: Set<Schema.Keyword> = [.contains]

      public let minContains: Int

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .number(let minContainsInstance) = keywordInstance else {
          try context.invalidType(requiredType: .number)
        }

        guard let minContains: Int = minContainsInstance.asInt() else {
          try context.invalidValue("Must be an integer")
        }

        if minContains < 0 {
          try context.invalidValue("Must be greater than zero")
        }

        return Self(minContains: minContains)
      }

      public func assert(instance: Value, context: inout Validator.Context) -> Assertion {

        guard
          instance.type == .array,
          let validContains = context.siblingAnnotation(for: Contains.self)?.array(of: \.int)
        else {
          return .valid
        }

        if let maxContains = context.schema.behavior(MaxContains.self)?.maxContains {
          if minContains > maxContains {
            return .invalid("'\(Keyword.minContains)' must be less than or equal to '\(Keyword.maxContains)'")
          }
        }

        if validContains.count < minContains {
          return .invalid("Must contain a minimum of \(minContains) items matching '\(Keyword.contains)'")
        }

        return .valid
      }
    }

    public struct MaxContains: AssertionBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .maxContains

      public let dependencies: Set<Schema.Keyword> = [.contains]

      public let maxContains: Int

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .number(let maxContainsInstance) = keywordInstance else {
          try context.invalidType(requiredType: .number)
        }

        guard let maxContains: Int = maxContainsInstance.asInt() else {
          try context.invalidValue("Must be an integer")
        }

        if maxContains < 0 {
          try context.invalidValue("Must be greater than zero")
        }

        return Self(maxContains: maxContains)
      }

      public func assert(instance: Value, context: inout Validator.Context) -> Assertion {

        guard
          instance.type == .array,
          let validContains = context.siblingAnnotation(for: Contains.self)?.array(of: \.int)
        else {
          return .valid
        }

        if let minContains = context.schema.behavior(MinContains.self)?.minContains {
          if maxContains < minContains {
            return .invalid("'\(Keyword.maxContains)' must be greater than or equal to '\(Keyword.minContains)'")
          }
        }

        if validContains.count > maxContains {
          return .invalid("Must contain a maximum of \(maxContains) items matching '\(Keyword.contains)'")
        }

        return .valid
      }
    }

    public struct UnevaluatedItems: UnevaluatedBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .unevaluatedItems

      public let dependencies: Set<Schema.Keyword> = [.prefixItems, .items, .contains]

      public let unevaluatedItemsSubSchema: SubSchema

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        let unevaluatedItemsSubSchema = try context.subSchema(for: keywordInstance)

        return Self(unevaluatedItemsSubSchema: unevaluatedItemsSubSchema)
      }

      public func apply(instance: Value, context: inout Validator.Context) -> Validation {

        guard let array = instance.array else {
          return .valid
        }

        let prefixItemsMaxIndexAnns = context.adjacentAnnotations(for: .prefixItems)
        let itemsAnns = context.adjacentAnnotations(for: .items)
        let containsAnns = context.adjacentAnnotations(for: .contains)
        let unevaluatedItemsAnns = context.adjacentAnnotations(for: .unevaluatedItems)

        let unevaluatedIndices: Set<Int>

        if prefixItemsMaxIndexAnns.isEmpty && itemsAnns.isEmpty
          && containsAnns.isEmpty && unevaluatedItemsAnns.isEmpty
        {

          unevaluatedIndices = Set(array.indices)

        } else if itemsAnns.anyTrue() || unevaluatedItemsAnns.anyTrue() {

          unevaluatedIndices = []

        } else {

          var indices = Set(array.indices)

          let prefixItemsMaxIndex = prefixItemsMaxIndexAnns.maxIndex()
          indices = indices.filter { $0 > prefixItemsMaxIndex }

          let validContainsIndices = containsAnns.indices()
          indices.subtract(validContainsIndices)

          unevaluatedIndices = indices
        }

        var validations: [Validation] = []

        for index in unevaluatedIndices {
          let itemInstance = array[index]
          let validation = context.validate(instance: .using(itemInstance, at: index), using: unevaluatedItemsSubSchema)
          validations.append(validation)
        }

        let valid = validations.allSatisfy(\.isValid)
        return valid ? .annotation(.bool(!unevaluatedIndices.isEmpty)) : .invalid
      }
    }

  }
}
