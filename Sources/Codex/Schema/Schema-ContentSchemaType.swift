//
//  Schema-ContentSchemaType.swift
//  Codex
//
//  Created by Kevin Wooten on 2/11/25.
//

import Foundation

extension Schema {

  public protocol ContentSchemaType: Sendable {

    var identifier: String { get }

    func validate(_ value: Value) throws -> Bool

  }

}
