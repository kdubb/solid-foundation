//
//  Schema-FormatType.swift
//  Codex
//
//  Created by Kevin Wooten on 2/9/25.
//

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
