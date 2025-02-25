//
//  Schema-UnevaluatedBehavior.swift
//  Codex
//
//  Created by Kevin Wooten on 2/24/25.
//

extension Schema {

  public protocol UnevaluatedBehavior: ApplicatorBehavior {}

}

extension Schema.UnevaluatedBehavior {

  public var order: Schema.KeywordBehaviorOrder { .unevaluated }

}
