//
//  ValueTextNumberTests.swift
//  Codex
//
//  Created by Kevin Wooten on 2/13/25.
//

import Foundation
import Testing
import BigInt
@testable import Codex

struct ValueTextNumberTests {

  @Test func intFromIntegerZero() throws {

    let number = Value.TextNumber(text: "0")

    #expect(number.asInteger() == BInt.zero)
    #expect(number.asInt() == 0)
    #expect(number.isInteger == true)
  }

  @Test func intFromInteger() throws {

    let number = Value.TextNumber(text: "123")

    #expect(number.asInteger() == BInt(123))
    #expect(number.asInt() == 123)
    #expect(number.isInteger == true)
  }

  @Test func intFromNegativeInteger() throws {

    let number = Value.TextNumber(text: "-123")

    #expect(number.asInteger() == BInt(-123))
    #expect(number.asInt() == -123)
    #expect(number.isInteger == true)
  }

  @Test func intFromDecimalZero() throws {

    let number = Value.TextNumber(text: "0.0")

    #expect(number.asInteger() == BInt.zero)
    #expect(number.asInt() == 0)
    #expect(number.isInteger == true)
  }

  @Test func intFromDecimalZeroExtraPrecision() throws {

    let number = Value.TextNumber(text: "0.000")

    #expect(number.asInteger() == BInt.zero)
    #expect(number.asInt() == 0)
    #expect(number.isInteger == true)
  }

  @Test func intFromDecimalZeroExtraDigits() throws {

    let number = Value.TextNumber(text: "000.000")

    #expect(number.asInteger() == BInt.zero)
    #expect(number.asInt() == 0)
    #expect(number.isInteger == true)
  }

  @Test func intFromDecimalInteger() throws {

    let number = Value.TextNumber(text: "123.0")

    #expect(number.asInteger() == BInt(123))
    #expect(number.asInt() == 123)
    #expect(number.isInteger == true)
  }

  @Test func intFromDecimalIntegerExtraPrecision() throws {

    let number = Value.TextNumber(text: "123.000")

    #expect(number.asInteger() == BInt(123))
    #expect(number.asInt() == 123)
    #expect(number.isInteger == true)
  }

  @Test func intFromDecimalIntegerExtraDigits() throws {

    let number = Value.TextNumber(text: "00123.000")

    #expect(number.asInteger() == BInt(123))
    #expect(number.asInt() == 123)
    #expect(number.isInteger == true)
  }

  @Test func intFromNegativeDecimalInteger() throws {

    let number = Value.TextNumber(text: "-123.0")

    #expect(number.asInteger() == BInt(-123))
    #expect(number.asInt() == -123)
    #expect(number.isInteger == true)
  }

  @Test func intFromNegativeDecimalIntegerExtraPrecision() throws {

    let number = Value.TextNumber(text: "-123.000")

    #expect(number.asInteger() == BInt(-123))
    #expect(number.asInt() == -123)
    #expect(number.isInteger == true)
  }

  @Test func intFromNegativeDecimalIntegerExtraDigits() throws {

    let number = Value.TextNumber(text: "-00123.000")

    #expect(number.asInteger() == BInt(-123))
    #expect(number.asInt() == -123)
    #expect(number.isInteger == true)
  }

}
