//
//  Schema-Annotations.swift
//  Codex
//
//  Created by Kevin Wooten on 2/5/25.
//

extension Schema {

  public enum Annotations {

    public struct Unknown: AnnotationBehavior {

      public let keyword: Keyword
      public let annotation: Value

      public init(keyword: Keyword, annotation: Value) {
        self.keyword = keyword
        self.annotation = annotation
      }

      public func annotate(context: inout Validator.Context) -> Value? {
        return annotation
      }
    }

    public struct Title: AnnotationBehavior, BuildableKeywordBehavior {

      public static let keyword: Schema.Keyword = .title

      public let title: String

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .string(let title) = keywordInstance else {
          try context.invalidType(requiredType: .string)
        }

        return Self(title: title)
      }

      public func annotate(context: inout Validator.Context) -> Value? {
        return .string(title)
      }
    }

    public struct Description: AnnotationBehavior, BuildableKeywordBehavior {

      public static let keyword: Schema.Keyword = .description

      public let description: String

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .string(let description) = keywordInstance else {
          try context.invalidType(requiredType: .string)
        }

        return Self(description: description)
      }

      public func annotate(context: inout Validator.Context) -> Value? {
        return .string(description)
      }
    }

    public struct Default: AnnotationBehavior, BuildableKeywordBehavior {

      public static let keyword: Schema.Keyword = .default

      public let `default`: Value

      public static func build(from keywordInstance: Value, context: inout Builder.Context) -> Self? {
        return Self(default: keywordInstance)
      }

      public func annotate(context: inout Validator.Context) -> Value? {
        return self.default
      }
    }

    public struct Deprecated: AnnotationBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .deprecated

      public let deprecated: Bool

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .bool(let deprecated) = keywordInstance else {
          try context.invalidType(requiredType: .boolean)
        }

        return Self(deprecated: deprecated)
      }

      public func annotate(context: inout Validator.Context) -> Value? {
        return .bool(deprecated)
      }
    }

    public struct Examples: AnnotationBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .examples

      public let examples: [Value]

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .array(let examples) = keywordInstance else {
          try context.invalidType(requiredType: .boolean)
        }

        return Self(examples: examples)
      }

      public func annotate(context: inout Validator.Context) -> Value? {
        return .array(examples)
      }
    }

    public struct ReadOnly: AnnotationBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .readOnly

      public let readOnly: Bool

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .bool(let readOnly) = keywordInstance else {
          try context.invalidType(requiredType: .boolean)
        }

        return Self(readOnly: readOnly)
      }

      public func annotate(context: inout Validator.Context) -> Value? {
        return .bool(readOnly)
      }
    }

    public struct WriteOnly: AnnotationBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .writeOnly

      public let writeOnly: Bool

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .bool(let writeOnly) = keywordInstance else {
          try context.invalidType(requiredType: .boolean)
        }

        return Self(writeOnly: writeOnly)
      }

      public func annotate(context: inout Validator.Context) -> Value? {
        return .bool(writeOnly)
      }
    }

    public struct Format: AnnotationBehavior, BuildableKeywordBehavior {

      public static let keyword: Schema.Keyword = .format

      public let format: String

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .string(let format) = keywordInstance else {
          try context.invalidType(requiredType: .string)
        }

        return Self(format: format)
      }

      public func annotate(context: inout Validator.Context) -> Value? {
        return .string(format)
      }
    }

  }
}
