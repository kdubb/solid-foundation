//
//  BigUIntTestData.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/17/25.
//

import Foundation
@testable import Solid

/// Test data for BigUInt.
struct BigUIntTestData: TestData, Codable, Sendable {

  /// String initialization test cases.
  struct StringInitializationTest: Codable, Sendable {
    let input: String
    let expectedWords: [UInt]?
  }

  /// Floating-point initialization test cases.
  struct FloatInitializationTest: Codable, Sendable {
    let floatValue: Double
    let precision: Int    // 16, 32, or 64 bits
    let expectedWords: [UInt]
  }

  /// Bit width test cases.
  struct BitWidthTest: Codable, Sendable {
    let words: [UInt]
    let bitWidth: Int
    let leadingZeroBitCount: Int
    let trailingZeroBitCount: Int
  }

  /// Addition test cases.
  struct AdditionTest: Codable, Sendable {
    let lWords: [UInt]
    let rWords: [UInt]
    let expectedWords: [UInt]
  }

  /// Subtraction test cases.
  struct SubtractionTest: Codable, Sendable {
    let lWords: [UInt]
    let rWords: [UInt]
    let expectedWords: [UInt]
  }

  /// Multiplication test cases.
  struct MultiplicationTest: Codable, Sendable {
    let lWords: [UInt]
    let rWords: [UInt]
    let expectedWords: [UInt]
  }

  /// Division and modulus test cases.
  struct DivisionModulusTest: Codable, Sendable {
    let dividendWords: [UInt]
    let divisorWords: [UInt]
    let quotientWords: [UInt]
    let remainderWords: [UInt]
  }

  /// Bitwise shift test cases.
  struct BitwiseShiftTest: Codable, Sendable {
    let words: [UInt]
    let shift: Int
    let expectedLeftWords: [UInt]
    let expectedRightWords: [UInt]
  }

  /// Bitwise operations test cases.
  struct BitwiseOpsTest: Codable, Sendable {
    let lWords: [UInt]
    let rWords: [UInt]
    let expectedAndWords: [UInt]
    let expectedOrWords: [UInt]
    let expectedXorWords: [UInt]
    let expectedNotLWords: [UInt]
    let expectedNotRWords: [UInt]
  }

  /// Comparison test cases.
  struct ComparisonTest: Codable, Sendable {
    let lWords: [UInt]
    let rWords: [UInt]
    let expectedEq: Bool
    let expectedLt: Bool
    let expectedLtEq: Bool
    let expectedGt: Bool
    let expectedGtEq: Bool
  }

  /// Power operation test cases.
  struct PowerTest: Codable, Sendable {
    let baseWords: [UInt]
    let exponent: Int
    let expectedWords: [UInt]
  }

  /// GCD and LCM test cases.
  struct GcdLcmTest: Codable, Sendable {
    let lWords: [UInt]
    let rWords: [UInt]
    let expectedGcdWords: [UInt]
    let expectedLcmWords: [UInt]
  }

  /// Encoding and decoding test cases.
  struct EncodingTest: Codable, Sendable {
    let words: [UInt]
    let encodedBytes: [UInt8]
    let inputBytes: [UInt8]?
  }

  /// Integer conversion test cases.
  struct IntegerConversionTest: Codable, Sendable {
    let sourceWords: [UInt]
    let expectedInt8: Int8?
    let expectedUInt8: UInt8?
    let expectedInt16: Int16?
    let expectedUInt16: UInt16?
    let expectedInt32: Int32?
    let expectedUInt32: UInt32?
    let expectedInt64: Int64?
    let expectedUInt64: UInt64?
    let expectedInt128: Int128?
    let expectedUInt128: UInt128?
    let expectedInt: Int?
    let expectedUInt: UInt?
  }

  // Top-level test data properties
  let stringInitialization: [StringInitializationTest]
  let floatInitialization: [FloatInitializationTest]
  let bitWidth: [BitWidthTest]
  let addition: [AdditionTest]
  let subtraction: [SubtractionTest]
  let multiplication: [MultiplicationTest]
  let divisionModulus: [DivisionModulusTest]
  let bitwiseShift: [BitwiseShiftTest]
  let bitwiseOps: [BitwiseOpsTest]
  let comparison: [ComparisonTest]
  let power: [PowerTest]
  let gcdLcm: [GcdLcmTest]
  let encoding: [EncodingTest]
  let integerConversion: [IntegerConversionTest]

}
