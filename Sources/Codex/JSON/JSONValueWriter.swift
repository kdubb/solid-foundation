//
//  JSONValueWriter.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

public struct JSONValueWriter {

  let tokenWriter: JSONTokenWriter

  public init() {
    self.tokenWriter = JSONTokenWriter()
  }

  func writeValue(_ value: Value) {
    switch value {

    case .null:
      tokenWriter.writeToken(.scalar(.null))

    case .bool(let bool):
      tokenWriter.writeToken(.scalar(.bool(bool)))

    case .number(let number):
      tokenWriter.writeToken(.scalar(.number(.init(number))))

    case .string(let string):
      tokenWriter.writeToken(.scalar(.string(string)))

    case .bytes(let data):
      tokenWriter.writeToken(.scalar(.string(data.base64EncodedString())))

    case .array(let array):

      tokenWriter.writeToken(.beginArray)

      for (idx, element) in array.enumerated() {

        writeValue(element)

        if idx < array.count - 1 {
          tokenWriter.writeToken(.elementSeparator)
        }
      }

      tokenWriter.writeToken(.endArray)

    case .object(let object):

      tokenWriter.writeToken(.beginObject)

      for (idx, entry) in object.enumerated() {

        writeValue(entry.key)
        tokenWriter.writeToken(.pairSeparator)
        writeValue(entry.value)

        if idx < object.values.count - 1 {
          tokenWriter.writeToken(.elementSeparator)
        }
      }

      tokenWriter.writeToken(.endObject)
    }
  }
}
