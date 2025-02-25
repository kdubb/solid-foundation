//
//  ContentSchemaLocator.swift
//  Codex
//
//  Created by Kevin Wooten on 2/9/25.
//

public protocol ContentSchemaLocator: Sendable {

  func locate(contentSchema id: String) throws -> Schema.ContentSchemaType

}
