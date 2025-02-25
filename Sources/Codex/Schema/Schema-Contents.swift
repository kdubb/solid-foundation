//
//  Schema-Contents.swift
//  Codex
//
//  Created by Kevin Wooten on 2/9/25.
//

extension Schema {

  public enum Contents {

    public struct ContentMediaType: AnnotationBehavior, BuildableKeywordBehavior {

      public static let keyword: Schema.Keyword = .contentMediaType

      public let contentMediaType: String

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self? {

        guard case .string(let contentMediaType) = keywordInstance else {
          try context.invalidType(requiredType: .string)
        }

        return Self(contentMediaType: contentMediaType)
      }

      public func annotate(context: inout Validator.Context) -> Value? {
        return .string(contentMediaType)
      }
    }

    public struct ContentMediaEncoding: AnnotationBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .contentMediaEncoding

      public let contentMediaEncoding: String

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws-> Self? {

        guard let stringInstance = keywordInstance.string else {
          try context.invalidType(requiredType: .string)
        }

        return Self(contentMediaEncoding: stringInstance)
      }

      public func annotate(context: inout Validator.Context) -> Value? {
        return .string(contentMediaEncoding)
      }
    }

    public struct ContentSchema: AnnotationBehavior, BuildableKeywordBehavior {

      public static let keyword: Keyword = .contentSchema

      public let subSchema: SubSchema

      public static func build(from keywordInstance: Value, context: inout Builder.Context) throws-> Self? {

        let subschema = try context.subSchema(for: keywordInstance)

        return Self(subSchema: subschema)
      }

      public func annotate(context: inout Validator.Context) -> Value? {
        return .string(subSchema.id.encoded)
      }
    }

  }

}
