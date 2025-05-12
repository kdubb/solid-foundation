//
//  Schema-KeywordBehavior.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/18/25.
//

import SolidData


extension Schema {

  public protocol KeywordBehavior: Sendable {

    var dependencies: Set<Keyword> { get }
    var order: KeywordBehaviorOrder { get }

    var keyword: Keyword { get }

    func apply(instance: Value, context: inout Validator.Context) -> Validation
  }

}

extension Schema.KeywordBehavior {

  public var dependencies: Set<Schema.Keyword> { [] }
  public var order: Schema.KeywordBehaviorOrder { .default }

}

extension Schema.KeywordBehavior where Self: Schema.KeywordBehaviorBuilder {

  public var keyword: Schema.Keyword { Self.keyword }

}
