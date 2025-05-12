//
//  SchemaContainer.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/6/25.
//

import SolidURI
import Foundation


/// Locates a schema resource by URI.
///
/// A schema resoure is any  JSON Schema object that specifies an `$id` or
/// is a root schema resource that inherits a default `$id` from the resource
/// locator used to fetch it.
public protocol SchemaLocator: Sendable {

  /// Locates a schema resource by URI.
  ///
  /// - Note: `schemaId` must be a normalized, absolute URI with no sub-resource fragment.
  ///
  /// - Parameters:
  ///  - schemaId: The URI of the schema resource to locate.
  ///  - options: The options to use when locating the schema.
  func locate(schemaId: URI, options: Schema.Options) throws -> Schema?

}
