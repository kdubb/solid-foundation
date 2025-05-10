//
//  BigDecimal+Foundation.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/16/25.
//

import Foundation


extension BigDecimal {

  public func formatted(_ style: DecimalFormatStyle) -> String {
    style.format(self)
  }

  public func formatted() -> String {
    DecimalFormatStyle.default.format(self)
  }

}
