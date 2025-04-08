//
//  Schema-SubSchemaLocator.swift
//  Codex
//
//  Created by Kevin Wooten on 2/23/25.
//

extension Schema {

  /// Locator for ``Schema/SubSchema-swift.protocol`` s by fragment identifier.
  ///
  /// Locates a sub-schema by their fragment identifier. The method allows for determining the
  /// types of fragment identifiers that are considered during location.
  ///
  public protocol SubSchemaLocator: Sendable {

    /// Locate a sub-schema by fragment identifier.
    ///
    /// - Parameters:
    ///  - fragment: The fragment identifier to locate.
    ///  - refTypes: The types of references that are considere during location. See ``Schema/RefType`` for
    ///  the types of references that can be considered.
    func locate(fragment: String, allowing refTypes: RefTypes) -> SubSchema?

  }

}
