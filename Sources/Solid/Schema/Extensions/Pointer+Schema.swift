//
//  Pointer+Schema.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/20/25.
//

import SolidData


internal extension Pointer {

  static func / (pointer: Pointer, relativeTokens: [KeywordLocationToken]) -> Pointer {
    return pointer.appending(tokens: relativeTokens.map { $0.pointerToken })
  }

  static func / (pointer: Pointer, relativeToken: KeywordLocationToken) -> Pointer {
    return pointer / relativeToken.pointerToken
  }

  static func /= (pointer: inout Pointer, relativeTokens: [KeywordLocationToken]) {
    pointer = pointer / relativeTokens
  }

  static func /= (pointer: inout Pointer, relativeToken: KeywordLocationToken) {
    pointer = pointer / relativeToken.pointerToken
  }

  var hasRefKeyword: Bool {
    return tokens.contains {
      $0.encoded == Schema.Keyword.ref$.rawValue || $0.encoded == Schema.Keyword.dynamicRef$.rawValue
    }
  }

}
