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

  }

}
