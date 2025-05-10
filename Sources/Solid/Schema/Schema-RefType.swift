//
//  Schema-RefType.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/23/25.
//

extension Schema {

  /// Types of reference that can be used to identify a sub-schema.
  public enum RefType {
    /// The canonical reference to the sub-schema.
    ///
    /// This can be either the keyword location or the anchor of the sub-schema.
    case canonical
    /// The keyword location of the sub-schema.
    ///
    /// A sub-schema's keyword location is determined by keyword
    /// path from the resource root schema to the sub-schema.
    case keywordLocation
    /// The anchor of the the sub-schema.
    ///
    /// This is always defined by the schema's `$anchor` keyword.
    case anchor
    /// The dynamic anchor of the the sub-schema.
    ///
    /// This is always defined by the schema's `$dynamicAnchor` keyword
    case dynamicAnchor
  }

  /// The set of allowable reference types that can be used to identify a sub-schema.
  public typealias RefTypes = Set<RefType>

}

extension Schema.RefType: Sendable {}
extension Schema.RefType: Hashable {}
extension Schema.RefType: Equatable {}

extension Schema.RefTypes {

  /// The standard set of reference types to consider when locating a sub-schema.
  ///
  /// This set includes all but the ``Schema/RefType/dynamicAnchor`` reference type.
  public static let standard: Self = [.canonical, .keywordLocation, .anchor]

  /// The standard set of reference types to consider when locating a dynamic sub-schema.
  ///
  /// This set includes all of ``Schema/RefTypes/standard`` plus ``Schema/RefType/dynamicAnchor``.
  public static let standardAndDynamic: Self = standard.union([.dynamicAnchor])

  /// Only considers the ``Schema/RefType/dynamicAnchor`` reference type.
  public static let dynamicOnly: Self = [.dynamicAnchor]

}
