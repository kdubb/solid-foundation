//
//  Schema-FormatType.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/9/25.
//

import SolidData


extension Schema {

  public protocol FormatType: Sendable {

    var identifier: String { get }

    func validate(_ value: Value) -> Bool

    func convert(_ value: Value) -> Value?
  }

}

extension Schema.FormatType {

  public func convert(_ value: Value) -> Value? {
    return nil
  }

}
