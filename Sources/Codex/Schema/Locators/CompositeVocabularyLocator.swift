//
//  CompositeVocabularyLocator.swift
//  Codex
//
//  Created by Kevin Wooten on 2/9/25.
//

public struct CompositeVocabularyLocator: VocabularyLocator {

  public var locators: [VocabularyLocator]

  public init(locators: [VocabularyLocator]) {
    self.locators = locators
  }

  public func locate(vocabularyId id: URI, options: Schema.Options) throws -> MetaSchema.Vocabulary? {
    for locator in locators {
      do {
        if let vocabulary = try locator.locate(vocabularyId: id, options: options) {
          return vocabulary
        }
      } catch {
        continue
      }
    }
    return nil
  }

}
