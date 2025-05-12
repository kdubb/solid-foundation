//
//  CompositeMetaSchemaLocator.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/9/25.
//

import SolidURI


public struct CompositeMetaSchemaLocator: MetaSchemaLocator {

  public var locators: [MetaSchemaLocator]

  public init(locators: [MetaSchemaLocator]) {
    self.locators = locators
  }

  public func locate(metaSchemaId id: URI, options: Schema.Options) throws -> MetaSchema? {
    for locator in locators {
      do {
        if let schema = try locator.locate(metaSchemaId: id, options: options) {
          return schema
        }
      } catch {
        continue
      }
    }
    return nil
  }

}
