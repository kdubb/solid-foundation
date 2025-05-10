//
//  Schema-ReferenceBehavior.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/20/25.
//

extension Schema {

  public protocol ReferenceBehavior: ApplicatorBehavior {}

}

extension Schema.ReferenceBehavior {

  public var order: Schema.KeywordBehaviorOrder { .references }

}
