//
//  Value-Number.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

import BigInt
import BigDecimal

extension Value {

  public protocol Number : CustomStringConvertible, Sendable {
    var decimal: BigDecimal { get }
    var isInteger: Bool { get }
    var isInfinity: Bool { get }
    var isNaN: Bool { get }
    var isNegative: Bool { get }

    func asDouble() -> Double
    func asInteger() -> BInt
    func asInt() -> Int?
  }

}
