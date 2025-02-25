//
//  JSONStructure.swift
//  Codex
//
//  Created by Kevin Wooten on 2/26/24.
//

import Foundation

enum JSONStructure {
  static let beginArray: UInt8 = 0x5B // [
  static let endArray: UInt8 = 0x5D // ]
  static let beginObject: UInt8 = 0x7B // {
  static let endObject: UInt8 = 0x7D // }
  static let pairSeparator: UInt8 = 0x3A // :
  static let elementSeparator: UInt8 = 0x2C // ,
  static let quotationMark: UInt8 = 0x22 // "
  static let escape: UInt8 = 0x5C // \
  static let nullStart: UInt8 = 0x6E // n
  static let trueStart: UInt8 = 0x74 // t
  static let falseStart: UInt8 = 0x66 // f
}
