//
//  MetaSchemaLocator.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/8/25.
//

import SolidURI


public protocol MetaSchemaLocator: Sendable {

  func locate(metaSchemaId: URI, options: Schema.Options) throws -> MetaSchema?

}
