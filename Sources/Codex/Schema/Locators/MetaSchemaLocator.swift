//
//  MetaSchemaLocator.swift
//  Codex
//
//  Created by Kevin Wooten on 2/8/25.
//

public protocol MetaSchemaLocator: Sendable {

  func locate(metaSchemaId: URI, options: Schema.Options) throws -> MetaSchema?

}
