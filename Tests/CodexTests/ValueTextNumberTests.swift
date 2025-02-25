//
//  ValueTextNumberTests.swift
//  Codex
//
//  Created by Kevin Wooten on 2/13/25.
//

import Foundation
import Testing
@testable import Codex

struct ValueTextNumberTests {

  @Test func intFromIntegerZero() throws {

    let zero = Value.TextNumber(text: "0")

    #expect(zero.asInteger() == .zero)
    #expect(zero.asInteger() == 0)
    #expect(zero.asInt() == 0)
    #expect(zero.isInteger == true)
  }

  @Test func intFromInteger() throws {

    let zero = Value.TextNumber(text: "123")

    #expect(zero.asInteger() == 123)
    #expect(zero.asInteger() == 123)
    #expect(zero.asInt() == 123)
    #expect(zero.isInteger == true)
  }

  @Test func intFromNegativeInteger() throws {

    let zero = Value.TextNumber(text: "-123")

    #expect(zero.asInteger() == -123)
    #expect(zero.asInteger() == -123)
    #expect(zero.asInt() == -123)
    #expect(zero.isInteger == true)
  }

  @Test func intFromDecimalZero() throws {

    let zero = Value.TextNumber(text: "0.0")

    #expect(zero.asInteger() == .zero)
    #expect(zero.asInteger() == 0)
    #expect(zero.asInt() == 0)
    #expect(zero.isInteger == true)
  }

  @Test func intFromDecimalZeroExtraPrecision() throws {

    let zero = Value.TextNumber(text: "0.000")

    #expect(zero.asInteger() == .zero)
    #expect(zero.asInteger() == 0)
    #expect(zero.asInt() == 0)
    #expect(zero.isInteger == true)
  }

  @Test func intFromDecimalZeroExtraDigits() throws {

    let zero = Value.TextNumber(text: "000.000")

    #expect(zero.asInteger() == .zero)
    #expect(zero.asInteger() == 0)
    #expect(zero.asInt() == 0)
    #expect(zero.isInteger == true)
  }

  @Test func intFromDecimalInteger() throws {

    let zero = Value.TextNumber(text: "123.0")

    #expect(zero.asInteger() == 123)
    #expect(zero.asInteger() == 123)
    #expect(zero.asInt() == 123)
    #expect(zero.isInteger == true)
  }

  @Test func intFromDecimalIntegerExtraPrecision() throws {

    let zero = Value.TextNumber(text: "123.000")

    #expect(zero.asInteger() == 123)
    #expect(zero.asInteger() == 123)
    #expect(zero.asInt() == 123)
    #expect(zero.isInteger == true)
  }

  @Test func intFromDecimalIntegerExtraDigits() throws {

    let zero = Value.TextNumber(text: "00123.000")

    #expect(zero.asInteger() == 123)
    #expect(zero.asInteger() == 123)
    #expect(zero.asInt() == 123)
    #expect(zero.isInteger == true)
  }

  @Test func intFromNegativeDecimalInteger() throws {

    let zero = Value.TextNumber(text: "-123.0")

    #expect(zero.asInteger() == -123)
    #expect(zero.asInteger() == -123)
    #expect(zero.asInt() == -123)
    #expect(zero.isInteger == true)
  }

  @Test func intFromNegativeDecimalIntegerExtraPrecision() throws {

    let zero = Value.TextNumber(text: "-123.000")

    #expect(zero.asInteger() == -123)
    #expect(zero.asInteger() == -123)
    #expect(zero.asInt() == -123)
    #expect(zero.isInteger == true)
  }

  @Test func intFromNegativeDecimalIntegerExtraDigits() throws {

    let zero = Value.TextNumber(text: "-00123.000")

    #expect(zero.asInteger() == -123)
    #expect(zero.asInteger() == -123)
    #expect(zero.asInt() == -123)
    #expect(zero.isInteger == true)
  }

}
