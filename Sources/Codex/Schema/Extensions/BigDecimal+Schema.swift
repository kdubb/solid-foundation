//
//  BigDecimal+Schema.swift
//  Codex
//
//  Created by Kevin Wooten on 2/13/25.
//

import BigDecimal

extension BigDecimal {

  var isSchemaInteger: Bool {
    !isNaN && !isInfinite && rounded() == self
  }

  func asSchemaInt() -> Int? {
    guard let int: Int = asInt() else {
      return self == .zero ? 0 : nil
    }
    return int
  }

}
