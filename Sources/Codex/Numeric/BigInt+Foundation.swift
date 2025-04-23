//
//  BigInt+Foundation.swift
//  Codex
//
//  Created by Kevin Wooten on 4/16/25.
//

import Foundation


extension FormatStyle where Self == IntegerFormatStyle<BigInt> {

  public static var number: Self {
    IntegerFormatStyle<BigInt>()
  }

}
