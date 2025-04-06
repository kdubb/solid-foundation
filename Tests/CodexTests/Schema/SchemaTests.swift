//
//  SchemaTests.swift
//  Codex
//
//  Created by Kevin Wooten on 2/5/25.
//

import Testing
@testable import Codex

@Suite("Schema Tests")
public struct SchemaTests {

  @Test func detailedType() throws {
    let schemaInstance: Value = [
      "$id": "https://example.com/polygon",
      "$schema": "https://json-schema.org/draft/2020-12/schema",
      "$defs": [
        "point": [
          "type": "object",
          "properties": [
            "x": ["type": "number"],
            "y": ["type": "number"],
          ],
          "additionalProperties": false,
          "required": ["x", "y"],
        ]
      ],
      "title": "Polygon",
      "type": "array",
      "items": ["$ref": "#/$defs/point"],
      "minItems": 3,
    ]
    let instance: Value = [
      [
        "x": 2.5,
        "y": 1.3,
      ],
      [
        "x": 1,
        "z": 6.7,
      ],
    ]

    let schema = try Schema.Builder.build(from: schemaInstance)

    let validatorResult = try schema.validate(instance: instance, outputFormat: .detailed, options: .default.trace())
    print(validatorResult)
    #expect(validatorResult.isValid == false)
  }

  @Test func basicTest() throws {

    let value: Value = ["a": "Testing 1..2..3..", "b": "yo!", "c": 1]
    let schemaInstance: Value = [
      "title": "Test Schema",
      "anyOf": [
        [
          "title": "Any 1",
          "type": "object",
          "properties": [
            "a": [
              "type": "string",
              "maxLength": 20,
            ]
          ],
          "minProperties": 1,
          "if": [
            "properties": [
              "a": ["const": "Testing 1..2..3.."]
            ]
          ],
          "then": [
            "required": ["b"],
            "properties": [
              "b": ["$ref": "#/$defs/Test"]
            ],
          ],
          "else": [
            "required": ["c"]
          ],
        ]
      ],
      "$defs": [
        "Test": [
          "const": "yo1"
        ]
      ],
    ]

    let schema = try Schema.Builder.build(from: schemaInstance)

    let validatorResult = try schema.validate(instance: value)
    print(validatorResult)
    #expect(validatorResult.isValid == false)
  }

}
