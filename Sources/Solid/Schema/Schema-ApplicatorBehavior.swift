//
//  Schema-ApplicatorBehavior.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/20/25.
//

import SolidData


extension Schema {

  public protocol ApplicatorBehavior: KeywordBehavior {
    func apply(instance: Value, context: inout Validator.Context) -> Validation
  }

}

extension Schema.ApplicatorBehavior {

  public var order: Schema.KeywordBehaviorOrder { .applicators }

}
