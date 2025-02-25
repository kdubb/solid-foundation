//
//  ContentMediaTypeLocator.swift
//  Codex
//
//  Created by Kevin Wooten on 2/9/25.
//

public protocol ContentMediaTypeLocator: Sendable {

  func locate(contentMediaType id: String) throws -> Schema.ContentMediaTypeType

}
