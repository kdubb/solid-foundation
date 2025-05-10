//
//  Data+MimeCoding.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/3/25.
//

import Foundation

extension Data {

  /// Initializes a `Data` object from a MIME quoted-printable encoded string.
  ///
  /// - Parameter string: The MIME quoted-printable encoded string.
  ///
  public init?(mimeQuotedPrintableEncodedString string: String) {
    // Remove soft line breaks ("=\r\n") from the encoded string
    let cleanedString = string.replacingOccurrences(of: "=\r\n", with: "")
    var byteArray: [UInt8] = []
    var index = cleanedString.startIndex

    while index < cleanedString.endIndex {
      let char = cleanedString[index]
      if char == "=" {
        // Expect two hexadecimal digits following '='
        let hexStart = cleanedString.index(after: index)
        let hexEnd =
          cleanedString.index(hexStart, offsetBy: 2, limitedBy: cleanedString.endIndex) ?? cleanedString.endIndex
        if cleanedString.distance(from: hexStart, to: hexEnd) < 2 {
          return nil    // Not enough hex digits
        }
        let hexDigits = cleanedString[hexStart..<hexEnd]
        guard let byte = UInt8(hexDigits, radix: 16) else {
          return nil
        }
        byteArray.append(byte)
        index = hexEnd
      } else {
        guard let ascii = char.asciiValue else {
          return nil
        }
        byteArray.append(ascii)
        index = cleanedString.index(after: index)
      }
    }

    self.init(byteArray)
  }

  /// Encodes the data into a MIME quoted-printable format.
  ///
  /// - Parameter maxLineLength: The maximum line length for the encoded output. Default is 76 characters.
  /// - Returns: A MIME quoted-printable encoded string.
  ///
  public func mimeQuotedPrintableEncoded(maxLineLength: Int = 76) -> String {
    var result = ""
    var currentLine = ""
    let softBreak = "=\r\n"

    for byte in self {
      // If the byte represents a newline (CR or LF), flush the current line and output a CRLF
      if byte == 13 || byte == 10 {
        if let lastChar = currentLine.last, lastChar == " " || lastChar == "\t" {
          // Encode trailing space/tab
          if let ascii = lastChar.asciiValue {
            currentLine.removeLast()
            currentLine += String(format: "=%02X", ascii)
          }
        }
        result += currentLine + "\r\n"
        currentLine = ""
        continue
      }

      // Determine the encoded representation for this byte
      let strByte: String
      // Allowed printable ASCII are 33–60 and 62–126. The equals sign (61) must be encoded.
      if (byte >= 33 && byte <= 60) || (byte >= 62 && byte <= 126) {
        if byte == 61 {    // '=' character
          strByte = String(format: "=%02X", byte)
        } else {
          strByte = String(UnicodeScalar(byte))
        }
      } else if byte == 9 || byte == 32 {
        // Tab or space (will be encoded later if trailing)
        strByte = String(UnicodeScalar(byte))
      } else {
        // All other bytes are encoded
        strByte = String(format: "=%02X", byte)
      }

      // If adding this token would exceed the maximum line length (reserve 1 for soft break), flush the line
      if currentLine.count + strByte.count > maxLineLength - 1 {
        if let lastChar = currentLine.last, lastChar == " " || lastChar == "\t" {
          if let ascii = lastChar.asciiValue {
            currentLine.removeLast()
            currentLine += String(format: "=%02X", ascii)
          }
        }
        result += currentLine + softBreak
        currentLine = ""
      }

      currentLine += strByte
    }

    // Flush any remaining characters in the current line
    if !currentLine.isEmpty {
      if let lastChar = currentLine.last, lastChar == " " || lastChar == "\t" {
        if let ascii = lastChar.asciiValue {
          currentLine.removeLast()
          currentLine += String(format: "=%02X", ascii)
        }
      }
      result += currentLine
    }

    return result
  }
}
