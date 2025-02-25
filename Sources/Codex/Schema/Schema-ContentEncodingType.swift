//
//  Schema-ContentEncodingType.swift
//  Codex
//
//  Created by Kevin Wooten on 2/11/25.
//

import Foundation

extension Schema {

  public protocol ContentEncodingType: Sendable {

    var identifier: String { get }

    func decode(_ data: Data) throws -> Value

    func encode(_ value: Value) throws -> Data

  }

}
