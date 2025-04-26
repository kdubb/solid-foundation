//
// BigDecimalTestData.swift
// Codex
//
// Created by Kevin Wooten on 4/22/25.
//

import Foundation
import Testing
@testable import Codex

/// Test data for BigDecimal.
struct BigDecimalTestData: TestData, Codable, Sendable {

  /// Represents a BigInt component (value, sign) and scale for BigDecimal.
  struct BigDecimalComponents: Codable, Sendable, CustomTestStringConvertible {
    let mantissaWords: [UInt]    // BigInt mantissa value
    let scale: Int

    var testDescription: String {
      return "\(BigDecimal(components: self))"
    }
  }

  /// String initialization test cases.
  struct StringInitializationTest: Codable, Sendable {
    let input: String
    let expected: BigDecimalComponents?
  }

  /// Addition test cases.
  struct AdditionTest: Codable, Sendable {
    let lhs: String
    let rhs: String
    let expected: BigDecimalComponents
  }

  /// Subtraction test cases.
  struct SubtractionTest: Codable, Sendable {
    let lhs: String
    let rhs: String
    let expected: BigDecimalComponents
  }

  /// Multiplication test cases.
  struct MultiplicationTest: Codable, Sendable {
    let lhs: String
    let rhs: String
    let expected: BigDecimalComponents
  }

  /// Division test cases.
  struct DivisionTest: Codable, Sendable {
    let lhs: String
    let rhs: String
    let expected: BigDecimalComponents
  }

  /// Remainder test cases.
  struct RemainderTest: Codable, Sendable {
    let lhs: String
    let rhs: String
    let expected: BigDecimalComponents
    let expectedTruncating: BigDecimalComponents
  }

  /// Power operation test cases.
  struct IntegerPowerTest: Codable, Sendable {
    let base: String
    let exponent: Int
    let expected: BigDecimalComponents
  }

  /// Power operation test cases.
  struct FloatingPointPowerTest: Codable, Sendable {
    let base: String
    let exponent: String
    let expected: BigDecimalComponents
  }

  /// Comparison test cases.
  struct ComparisonTest: Codable, Sendable {
    let lhs: String
    let rhs: String
    let expectedEq: Bool
    let expectedLt: Bool
    let expectedLtEq: Bool
    let expectedGt: Bool
    let expectedGtEq: Bool
  }

  /// Rounding test cases.
  struct RoundingTest: Codable, Sendable {
    let value: String
    let scale: Int
    let mode: String
    let expected: BigDecimalComponents
  }

  /// String formatting test cases.
  struct StringFormattingTest: Codable, Sendable {
    let value: String
    let expectedString: String
    let expectedNormalizedString: String
    let expectedScientificString: String
  }

  // Top-level test data properties
  let stringInitialization: [StringInitializationTest]
  let addition: [AdditionTest]
  let subtraction: [SubtractionTest]
  let multiplication: [MultiplicationTest]
  let division: [DivisionTest]
  let remainder: [RemainderTest]
  let integerPower: [IntegerPowerTest]
  let floatingPointPower: [FloatingPointPowerTest]
  let comparison: [ComparisonTest]
  let rounding: [RoundingTest]
  let stringFormatting: [StringFormattingTest]
}

extension BigDecimal {

  /// Initialize a BigDecimal from test data components.
  init(components: BigDecimalTestData.BigDecimalComponents) {
    let mantissa = BigInt(wordsWithSignFlag: components.mantissaWords)
    self.init(mantissa: mantissa, scale: components.scale)
  }
}
