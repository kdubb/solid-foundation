//
//  VocabularyLocator.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/12/25.
//

public protocol VocabularyLocator: Sendable {

  func locate(vocabularyId: URI, options: Schema.Options) throws -> MetaSchema.Vocabulary?

}
