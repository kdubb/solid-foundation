//
//  LocalVocabularyContainer.swift
//  Codex
//
//  Created by Kevin Wooten on 2/8/25.
//

import Foundation

public class LocalVocabularyContainer: VocabularyLocator, @unchecked Sendable {

  private let vocabularyLocator: VocabularyLocator
  private var vocabularies: [URI: MetaSchema.Vocabulary]
  private let vocabulariesLock: NSLock

  public init(vocabularies: [URI: MetaSchema.Vocabulary] = [:], vocabularyLocator: VocabularyLocator) {
    self.vocabularyLocator = vocabularyLocator
    self.vocabularies = vocabularies
    self.vocabulariesLock = NSLock()
  }

  public func register(_ vocabulary: MetaSchema.Vocabulary) {
    vocabulariesLock.withLock {
      vocabularies[vocabulary.id] = vocabulary
    }
  }

  public func locate(vocabularyId id: URI, options: Schema.Options) throws -> MetaSchema.Vocabulary? {
    if let cached = vocabulariesLock.withLock({ vocabularies[id] }) {
      return cached
    }

    guard let vocabulary = try vocabularyLocator.locate(vocabularyId: id, options: options) else {
      return nil
    }

    vocabulariesLock.withLock {
      vocabularies[id] = vocabulary
      vocabularies[vocabulary.id] = vocabulary
    }

    return vocabulary
  }

}
