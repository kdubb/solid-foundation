//
//  Strings.swift
//  Codex
//
//  Created by Kevin Wooten on 4/16/25.
//

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
