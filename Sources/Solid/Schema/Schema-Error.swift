//
//  Schema-Error.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/3/25.
//

import SolidData
import SolidURI
import Foundation


extension Schema {

  public indirect enum Error: Swift.Error {
    case unknownSchema(String)
    case unknownType(location: Pointer)
    case unknownKeyword(String, location: Pointer)
    case invalidSchemaId(String, location: Pointer)
    case invalidType(String, location: Pointer)
    case invalidValue(String, location: Pointer)
    case unresolvedReference(URI)
    case failedToResolveReference(URI, Error?)
    case keywordUsageError(String, location: Pointer)
  }

}
