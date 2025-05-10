//
//  Strings.swift
//  Codex
//
//  Created by Kevin Wooten on 4/16/25.
//

import Foundation

extension StringProtocol {

  internal func leftPad(to length: Int, with char: Character) -> String {
    if count >= length { return String(self) }
    return String(repeating: char, count: length - count) + self
  }

  internal func rightPad(to length: Int, with char: Character) -> String {
    if count >= length { return String(self) }
    return self + String(repeating: String(char), count: length - count)
  }

}

public enum StringError: Swift.Error {
  case invalidUTF8String
}

extension String {

  package static func from(data: Data, encoding: String.Encoding) throws -> String {
    guard let string = String(data: data, encoding: encoding) else {
      throw StringError.invalidUTF8String
    }
    return string
  }

}
