//
//  JSONTokenWriter.swift
//  Codex
//
//  Created by Kevin Wooten on 2/26/24.
//

import Foundation

public struct JSONTokenWriter {

  class Output: TextOutputStream {
    var value = ""

    func write(_ value: String) {
      self.value += value
    }
  }

  let output = Output()
  let escapeSlashes = false

  func writeToken(_ token: JSONToken) {

    switch token {

    case .scalar(.string(let value)): writeString(value)
    case .scalar(.number(let value)): writeNumber(value)
    case .scalar(.bool(let value)): writeBool(value)
    case .scalar(.null): writeNull()

    case .beginArray: writeASCII(JSONStructure.beginArray)
    case .endArray: writeASCII(JSONStructure.endArray)

    case .beginObject: writeASCII(JSONStructure.beginObject)
    case .endObject: writeASCII(JSONStructure.endObject)

    case .elementSeparator: writeASCII(JSONStructure.elementSeparator)
    case .pairSeparator: writeASCII(JSONStructure.pairSeparator)
    }
  }

  func writeASCII(_ value: UInt8) {
    output.write(String(UnicodeScalar(value)))
  }

  func writeString(_ value: String) {
    output.write("\"")
    for scalar in value.unicodeScalars {
      switch scalar {
      case "\"":
        output.write("\\\"")    // U+0022 quotation mark
      case "\\" where escapeSlashes:
        output.write("\\\\")    // U+005C reverse solidus
      case "/" where escapeSlashes:
        output.write("\\/")    // U+002F solidus
      case "\u{8}":
        output.write("\\b")    // U+0008 backspace
      case "\u{c}":
        output.write("\\f")    // U+000C form feed
      case "\n":
        output.write("\\n")    // U+000A line feed
      case "\r":
        output.write("\\r")    // U+000D carriage return
      case "\t":
        output.write("\\t")    // U+0009 tab
      case "\u{0}"..."\u{f}":
        output.write("\\u000\(String(scalar.value, radix: 16))")    // U+0000 to U+000F
      case "\u{10}"..."\u{1f}":
        output.write("\\u00\(String(scalar.value, radix: 16))")    // U+0010 to U+001F
      default:
        output.write(String(scalar))
      }
    }
    output.write("\"")
  }

  func writeNumber(_ value: JSONToken.Scalar.Number) {
    output.write(value.value)
  }

  func writeBool(_ value: Bool) {
    output.write(value ? "true" : "false")
  }

  func writeNull() {
    output.write("null")
  }

}
