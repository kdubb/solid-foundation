//
//  Datas.swift
//  Codex
//
//  Created by Kevin Wooten on 4/3/25.
//

import Foundation

extension Data {

  public init?(baseEncodedString string: String, encoding: BaseEncoding) {
    guard let data = encoding.decode(string: string) else {
      return nil
    }
    self = data
  }

  public func baseEncoded(using encoding: BaseEncoding) -> String {
    return encoding.encode(data: self)
  }

  public struct BaseEncoding: Sendable {

    public static let base64 = Self(
      alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",
      padding: "=",
      strictPadding: true,
      caseInsensitive: false
    )
    public static let base64Url = Self(
      alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_",
      padding: "=",
      strictPadding: false,
      caseInsensitive: false
    )
    public static let base62 = Self(
      alphabet: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz",
      padding: nil,
      strictPadding: false,
      caseInsensitive: false
    )
    public static let base32 = Self(
      alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567",
      padding: "=",
      strictPadding: true,
      caseInsensitive: true
    )
    public static let base32Hex = Self(
      alphabet: "0123456789ABCDEFGHIJKLMNOPQRSTUV",
      padding: "=",
      strictPadding: true,
      caseInsensitive: true
    )
    public static let base16 = Self(
      alphabet: "0123456789ABCDEF",
      padding: nil,
      strictPadding: false,
      caseInsensitive: true
    )

    public let alphabet: [Character]
    public let bitsPerChar: Int
    public let paddingCharacter: Character?
    public let strictPadding: Bool
    public let caseInsensitive: Bool
    fileprivate let lookup: [UInt8: Character]
    fileprivate let reverseLookup: [Character: UInt8]

    public init(
      alphabet: String,
      padding: Character?,
      strictPadding: Bool,
      caseInsensitive: Bool
    ) {
      self.init(
        alphabet: Array(alphabet),
        padding: padding,
        strictPadding: strictPadding,
        caseInsensitive: caseInsensitive
      )
    }

    public init(
      alphabet: [Character],
      padding: Character?,
      strictPadding: Bool,
      caseInsensitive: Bool
    ) {
      let bitsPerChar = Int(log2(Double(alphabet.count)))
      precondition(1 << bitsPerChar == alphabet.count, "Alphabet length must be a power of 2")
      self.alphabet = alphabet
      self.bitsPerChar = bitsPerChar
      self.paddingCharacter = padding
      self.strictPadding = strictPadding
      self.caseInsensitive = caseInsensitive
      self.lookup = Self.buildLookup(for: alphabet)
      self.reverseLookup = Self.buildReverseLookup(for: alphabet, caseInsensitive: caseInsensitive)
    }

    public func unpadded(strict: Bool = false) -> Self {
      return Self(alphabet: alphabet, padding: nil, strictPadding: strict, caseInsensitive: caseInsensitive)
    }

    public func padded(character: Character = "=", strict: Bool? = nil) -> Self {
      return Self(
        alphabet: alphabet,
        padding: character,
        strictPadding: strict ?? strictPadding,
        caseInsensitive: caseInsensitive
      )
    }

    public func strictPadding(_ enabled: Bool = true) -> Self {
      return Self(
        alphabet: alphabet,
        padding: paddingCharacter,
        strictPadding: enabled,
        caseInsensitive: caseInsensitive
      )
    }

    public func lenientPadding(_ enabled: Bool = true) -> Self {
      return Self(
        alphabet: alphabet,
        padding: paddingCharacter,
        strictPadding: !enabled,
        caseInsensitive: caseInsensitive
      )
    }

    public func caseInsensitive(_ enabled: Bool = true) -> Self {
      return Self(alphabet: alphabet, padding: paddingCharacter, strictPadding: strictPadding, caseInsensitive: enabled)
    }

    public func caseSensitive(_ enabled: Bool = true) -> Self {
      return Self(
        alphabet: alphabet,
        padding: paddingCharacter,
        strictPadding: strictPadding,
        caseInsensitive: !enabled
      )
    }

    public func encode(data: Data) -> String {
      let mask = UInt32((1 << bitsPerChar) - 1)

      var output = ""
      var buffer: UInt32 = 0
      var bufferBits = 0

      for byte in data {
        buffer = (buffer << 8) | UInt32(byte)
        bufferBits += 8

        while bufferBits >= bitsPerChar {
          bufferBits -= bitsPerChar
          let index = UInt8((buffer >> bufferBits) & mask)
          if let char = lookup[index] {
            output.append(char)
          }
        }
      }

      if bufferBits > 0 {
        buffer <<= UInt32(bitsPerChar - bufferBits)
        let index = UInt8(buffer & mask)
        if let char = lookup[index] {
          output.append(char)
        }
      }

      if let paddingChar = paddingCharacter {
        let totalChars = ((data.count * 8) + bitsPerChar - 1) / bitsPerChar
        let paddedLength = ((totalChars + (8 / bitsPerChar) - 1) / (8 / bitsPerChar)) * (8 / bitsPerChar)
        output.append(String(repeating: paddingChar, count: paddedLength - output.count))
      }

      return output
    }

    public func decode(string: String) -> Data? {
      let unpaddedInput = string.filter { $0 != paddingCharacter }

      // Padding check
      if strictPadding, let padChar = paddingCharacter {
        let paddingCount = string.reversed().prefix { $0 == padChar }.count
        let totalChars = string.count
        let expectedPaddedLength = ((totalChars + (8 / bitsPerChar) - 1) / (8 / bitsPerChar)) * (8 / bitsPerChar)

        if totalChars != expectedPaddedLength {
          return nil    // Padding doesn't match expected length
        }
        if (unpaddedInput.count * bitsPerChar) % 8 != 0 {
          return nil    // Not a full byte
        }
        if paddingCount > (8 / bitsPerChar) {
          return nil    // Too much padding
        }
      }

      var buffer: UInt32 = 0
      var bufferBits = 0
      var output: [UInt8] = []

      for char in unpaddedInput {
        guard let value = reverseLookup[char] else {
          return nil    // Invalid character
        }

        buffer = (buffer << bitsPerChar) | UInt32(value)
        bufferBits += bitsPerChar

        while bufferBits >= 8 {
          bufferBits -= 8
          let byte = UInt8((buffer >> bufferBits) & 0xFF)
          output.append(byte)
        }
      }

      if bufferBits > 0 {
        let leftover = buffer & ((1 << bufferBits) - 1)
        if leftover != 0 {
          return nil    // Invalid trailing bits
        }
      }

      return Data(output)
    }

    private static func buildLookup(for chars: [Character]) -> [UInt8: Character] {
      Dictionary(uniqueKeysWithValues: chars.enumerated().map { (UInt8($0.offset), $0.element) })
    }

    private static func buildReverseLookup(for chars: [Character], caseInsensitive: Bool) -> [Character: UInt8] {
      var reverseLookup: [Character: UInt8] = [:]
      for (i, char) in chars.enumerated() {
        reverseLookup[char] = UInt8(i)
        if caseInsensitive {
          reverseLookup[Character(char.lowercased())] = UInt8(i)
          reverseLookup[Character(char.uppercased())] = UInt8(i)
        }
      }
      return reverseLookup
    }
  }
}
