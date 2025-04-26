//
//  BigUIntTests.swift
//  Codex
//
//  Created by Kevin Wooten on 4/16/25.
//

@testable import Codex
import Foundation
import Testing


@Suite("BigUInt Tests")
struct BigUIntTests {

  static let testData = BigUIntTestData.loadFromBundle()

  @Test("Default initialization")
  func defaultInitialization() {
    let zero = BigUInt()
    #expect(zero.isZero)
    #expect(zero.words == [0])
  }

  @Test(
    "Integer literal initialization",
    arguments: [
      (0, [0]),
      (1, [1]),
      (42, [42]),
      (0xFF, [0xFF]),
      (0xFFFF, [0xFFFF]),
      (0xFFFFFFFF, [0xFFFFFFFF]),
      (0xFFFFFFFFFFFFFFFF, [0xFFFFFFFFFFFFFFFF]),
      (0x123456789ABCDEF0, [0x123456789ABCDEF0]),
      (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, [0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF]),
      (0x123456789ABCDEF0123456789ABCDEF0, [0x123456789ABCDEF0, 0x123456789ABCDEF0]),
      (
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
        [0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF]
      ),
      (
        0x123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0,
        [0x123456789ABCDEF0, 0x123456789ABCDEF0, 0x123456789ABCDEF0, 0x123456789ABCDEF0]
      ),
    ] as [(StaticBigInt, [UInt])]
  )
  func integerLiteralInitialization(_ value: StaticBigInt, _ expectedWords: [UInt]) throws {
    let num: BigUInt = BigUInt(integerLiteral: value)
    #expect(num.words == BigUInt.Words(expectedWords))
  }

  @Test(
    "Binary integer initialization",
    arguments: [
      // UInt8 tests
      (UInt8.max, [UInt(UInt8.max)]),
      (UInt8.max - 1, [UInt(UInt8.max - 1)]),
      (UInt8.min, [UInt(UInt8.min)]),

      // UInt16 tests
      (UInt16.max, [UInt(UInt16.max)]),
      (UInt16.max - 1, [UInt(UInt16.max - 1)]),
      (UInt16.min, [UInt(UInt16.min)]),

      // UInt32 tests
      (UInt32.max, [UInt(UInt32.max)]),
      (UInt32.max - 1, [UInt(UInt32.max - 1)]),
      (UInt32.min, [UInt(UInt32.min)]),

      // UInt64 tests
      (UInt64.max, [UInt(UInt64.max)]),
      (UInt64.max - 1, [UInt(UInt64.max - 1)]),
      (UInt64.min, [UInt(UInt64.min)]),

      // UInt tests
      (UInt.max, [UInt(UInt.max)]),
      (UInt.max - 1, [UInt(UInt.max - 1)]),
      (UInt.min, [UInt(UInt.min)]),

      // UInt128 tests
      (UInt128.max, [UInt.max, UInt.max]),
      (UInt128.max - 1, [UInt.max - 1, UInt.max]),
      (UInt128.min, [UInt(UInt128.min)]),
    ] as [(any BinaryInteger & Sendable, [UInt])]
  )
  func binaryIntegerInitialization(_ value: any BinaryInteger & Sendable, _ expectedWords: [UInt]) {
    let num = BigUInt(value)
    #expect(num.words == BigUInt.Words(expectedWords))
    #expect(num.magnitude == num)
  }

  @Test(
    "Exact binary integer initialization",
    arguments: [
      // UInt8 tests
      (UInt8.max, [UInt(UInt8.max)]),
      (UInt8.max - 1, [UInt(UInt8.max - 1)]),
      (UInt8.min, [UInt(UInt8.min)]),

      // UInt16 tests
      (UInt16.max, [UInt(UInt16.max)]),
      (UInt16.max - 1, [UInt(UInt16.max - 1)]),
      (UInt16.min, [UInt(UInt16.min)]),

      // UInt32 tests
      (UInt32.max, [UInt(UInt32.max)]),
      (UInt32.max - 1, [UInt(UInt32.max - 1)]),
      (UInt32.min, [UInt(UInt32.min)]),

      // UInt64 tests
      (UInt64.max, [UInt(UInt64.max)]),
      (UInt64.max - 1, [UInt(UInt64.max - 1)]),
      (UInt64.min, [UInt(UInt64.min)]),

      // UInt tests
      (UInt.max, [UInt(UInt.max)]),
      (UInt.max - 1, [UInt(UInt.max - 1)]),
      (UInt.min, [UInt(UInt.min)]),

      // UInt128 tests
      (UInt128.max, [UInt.max, UInt.max]),
      (UInt128.max - 1, [UInt.max - 1, UInt.max]),
      (UInt128.min, [UInt(UInt128.min)]),

      // Int8 tests
      (Int8.max, [UInt(Int8.max)]),
      (Int8.max - 1, [UInt(Int8.max - 1)]),
      (Int8.min, nil),

      // Int16 tests
      (Int16.max, [UInt(Int16.max)]),
      (Int16.max - 1, [UInt(Int16.max - 1)]),
      (Int16.min, nil),

      // Int32 tests
      (Int32.max, [UInt(Int32.max)]),
      (Int32.max - 1, [UInt(Int32.max - 1)]),
      (Int32.min, nil),

      // Int64 tests
      (Int64.max, [UInt(Int64.max)]),
      (Int64.max - 1, [UInt(Int64.max - 1)]),
      (Int64.min, nil),

      // Int tests
      (Int.max, [UInt(Int.max)]),
      (Int.max - 1, [UInt(Int.max - 1)]),
      (Int.min, nil),

      // Int128 tests
      (Int128.max, [UInt.max, UInt(Int.max)]),
      (Int128.max - 1, [UInt.max - 1, UInt(Int.max)]),
      (Int128.min, nil),
    ] as [(any BinaryInteger & Sendable, [UInt]?)]
  )
  func exactBinaryIntegerInitialization(_ value: any BinaryInteger & Sendable, _ expectedWords: [UInt]?) throws {
    switch value {
    case let uint as UInt:
      let expectedWords = try #require(expectedWords)
      let num = try #require(BigUInt(exactly: uint))
      #expect(num.words == BigUInt.Words(expectedWords))
    case let uint8 as UInt8:
      let expectedWords = try #require(expectedWords)
      let num = try #require(BigUInt(exactly: uint8))
      #expect(num.words == BigUInt.Words(expectedWords))
    case let uint16 as UInt16:
      let expectedWords = try #require(expectedWords)
      let num = try #require(BigUInt(exactly: uint16))
      #expect(num.words == BigUInt.Words(expectedWords))
    case let uint32 as UInt32:
      let expectedWords = try #require(expectedWords)
      let num = try #require(BigUInt(exactly: uint32))
      #expect(num.words == BigUInt.Words(expectedWords))
    case let uint64 as UInt64:
      let expectedWords = try #require(expectedWords)
      let num = try #require(BigUInt(exactly: uint64))
      #expect(num.words == BigUInt.Words(expectedWords))
    case let uint128 as UInt128:
      let expectedWords = try #require(expectedWords)
      let num = try #require(BigUInt(exactly: uint128))
      #expect(num.words == BigUInt.Words(expectedWords))
    case let int8 as Int8:
      guard let expectedWords else {
        #expect(BigUInt(exactly: int8) == nil)
        return
      }
      let num = try #require(BigUInt(exactly: int8))
      #expect(num.words == BigUInt.Words(expectedWords))
    case let int16 as Int16:
      guard let expectedWords else {
        #expect(BigUInt(exactly: int16) == nil)
        return
      }
      let num = try #require(BigUInt(exactly: int16))
      #expect(num.words == BigUInt.Words(expectedWords))
    case let int32 as Int32:
      guard let expectedWords else {
        #expect(BigUInt(exactly: int32) == nil)
        return
      }
      let num = try #require(BigUInt(exactly: int32))
      #expect(num.words == BigUInt.Words(expectedWords))
    case let int64 as Int64:
      guard let expectedWords else {
        #expect(BigUInt(exactly: int64) == nil)
        return
      }
      let num = try #require(BigUInt(exactly: int64))
      #expect(num.words == BigUInt.Words(expectedWords))
    case let int as Int:
      guard let expectedWords else {
        #expect(BigUInt(exactly: int) == nil)
        return
      }
      let num = try #require(BigUInt(exactly: int))
      #expect(num.words == BigUInt.Words(expectedWords))
    case let int128 as Int128:
      guard let expectedWords else {
        #expect(BigUInt(exactly: int128) == nil)
        return
      }
      let num = try #require(BigUInt(exactly: int128))
      #expect(num.words == BigUInt.Words(expectedWords))
    default:
      fatalError("Unexpected type: \(type(of: value))")
    }
  }

  @Test(
    "Binary integer initialization with truncation",
    arguments: [
      (0, [0]),
      (1, [1]),
      (42, [42]),

      // UInt8/Int8 tests
      (UInt8.max, [UInt(UInt8.max)]),
      (UInt8.min, [UInt(UInt8.min)]),
      (Int8.min, [UInt(Int8.max) + 1]),
      (Int8.max, [UInt(Int8.max)]),

      // UInt16/Int16 tests
      (UInt16.max, [UInt(UInt16.max)]),
      (UInt16.min, [UInt(UInt16.min)]),
      (Int16.min, [UInt(Int16.max) + 1]),
      (Int16.max, [UInt(Int16.max)]),

      // UInt32/Int32 tests
      (UInt32.max, [UInt(UInt32.max)]),
      (UInt32.min, [UInt(UInt32.min)]),
      (Int32.min, [UInt(Int32.max) + 1]),
      (Int32.max, [UInt(Int32.max)]),

      // UInt64/Int64 tests
      (UInt64.max, [UInt(UInt64.max)]),
      (UInt64.min, [UInt(UInt64.min)]),
      (Int64.min, [UInt(Int64.max) + 1]),
      (Int64.max, [UInt(Int64.max)]),

      // UInt/Int tests
      (UInt.max, [UInt.max]),
      (UInt.min, [UInt.min]),
      (Int.min, [UInt.max / 2 + 1]),
      (Int.max, [UInt(Int.max)]),

      // UInt128/Int128 tests
      (UInt128.max, [UInt.max, UInt.max]),
      (UInt128.min, [UInt(UInt128.min)]),
      (Int128.min, [0, UInt.max / 2 + 1]),
      (Int128.max, [UInt.max, UInt.max / 2]),
    ] as [(any BinaryInteger & Sendable, [UInt])]
  )
  func binaryIntegerInitializationWithTruncation(_ value: any BinaryInteger & Sendable, _ expectedWords: [UInt]) {
    let num = BigUInt(truncatingIfNeeded: value)
    #expect(num.words == BigUInt.Words(expectedWords))
  }

  @Test(
    "Binary integer initialization with clamping",
    arguments: [
      // UInt8/Int8 tests
      (UInt8.max, [UInt(UInt8.max)]),
      (UInt8.min, [UInt(UInt8.min)]),
      (Int8.min, [0]),
      (Int8.max, [UInt(Int8.max)]),

      // UInt16/Int16 tests
      (UInt16.max, [UInt(UInt16.max)]),
      (UInt16.min, [UInt(UInt16.min)]),
      (Int16.min, [0]),
      (Int16.max, [UInt(Int16.max)]),

      // UInt32/Int32 tests
      (UInt32.max, [UInt(UInt32.max)]),
      (UInt32.min, [UInt(UInt32.min)]),
      (Int32.min, [0]),
      (Int32.max, [UInt(Int32.max)]),

      // UInt64/Int64 tests
      (UInt64.max, [UInt(UInt64.max)]),
      (UInt64.min, [UInt(UInt64.min)]),
      (Int64.min, [0]),
      (Int64.max, [UInt(Int64.max)]),

      // UInt/Int tests
      (UInt.max, [UInt.max]),
      (UInt.min, [UInt.min]),
      (Int.min, [0]),
      (Int.max, [UInt(Int.max)]),

      // UInt128/Int128 tests
      (UInt128.max, [UInt.max, UInt.max]),
      (UInt128.min, [UInt(UInt128.min)]),
      (Int128.min, [0]),
      (Int128.max, [UInt.max, UInt.max / 2]),
    ] as [(any BinaryInteger & Sendable, [UInt])]
  )
  func binaryIntegerInitializationWithClamping(_ value: any BinaryInteger & Sendable, _ expectedWords: [UInt]) {
    let num = BigUInt(clamping: value)
    #expect(num.words == BigUInt.Words(expectedWords))
  }

  @Test(
    "String initialization",
    arguments: testData.stringInitialization.map { ($0.input, $0.expectedWords) }
  )
  func stringInitializationData(_ input: String, _ expectedWords: [UInt]?) throws {
    let num = BigUInt(input)
    #expect(num?.words == expectedWords.map { BigUInt.Words($0) })
  }

  @Test(
    "String conversion",
    arguments: testData.stringInitialization.compactMap { test in test.expectedWords.map { ($0, test.input) } }
  )
  func stringConversion(_ words: [UInt], _ expectedString: String) {
    let number = BigUInt(words: words)
    let stringFromNumber = String(number)
    let stringFromDescription = number.description
    let stringFromDebugDescription = number.debugDescription
    #expect(stringFromNumber == expectedString)
    #expect(stringFromDescription == expectedString)
    #expect(stringFromDebugDescription == "BigUInt(\(expectedString))")
  }

  @Test(
    "Formatted strings",
    arguments: [
      (
        1234567890, "1234567890",
        IntegerFormatStyle<BigUInt>.number.locale(Locale(identifier: "C")).grouping(.never)
      ),
      (
        1000000000000000000, "1,000,000,000,000,000,000",
        IntegerFormatStyle<BigUInt>.number.locale(Locale(identifier: "en_US"))
      ),
      (
        0xFFFFFFFFFFFFFFFF, "+18,446,744,073,709,551,615",
        IntegerFormatStyle<BigUInt>.number.grouping(.automatic).sign(strategy: .always(includingZero: true))
      ),
    ] as [(StaticBigInt, String, IntegerFormatStyle<BigUInt>)]
  )
  func formattedStrings(_ value: StaticBigInt, _ expected: String, _ style: IntegerFormatStyle<BigUInt>) {
    let num = BigUInt(integerLiteral: value)
    let formatted = num.formatted(style)
    #expect(formatted == expected)
  }

  @Test(
    "Addition",
    arguments: testData.addition.map { ($0.lWords, $0.rWords, $0.expectedWords) }
  )
  func addition(_ lWords: [UInt], _ rWords: [UInt], _ expectedWords: [UInt]) {
    let numA = BigUInt(words: lWords)
    let numB = BigUInt(words: rWords)
    let sum = numA + numB
    let sumReversed = numB + numA
    var sumAssign = numA
    sumAssign += numB
    #expect(sum.words == BigUInt.Words(expectedWords))
    #expect(sumReversed.words == BigUInt.Words(expectedWords))
    #expect(sum == sumReversed)
    #expect(sumAssign.words == BigUInt.Words(expectedWords))
  }

  @Test(
    "Subtraction",
    arguments: testData.subtraction.map { ($0.lWords, $0.rWords, $0.expectedWords) }
  )
  func subtraction(_ lWords: [UInt], _ rWords: [UInt], _ expectedWords: [UInt]) {
    let numA = BigUInt(words: lWords)
    let numB = BigUInt(words: rWords)
    let diff = numA - numB
    var diffAssign = numA
    diffAssign -= numB
    #expect(diff.words == BigUInt.Words(expectedWords))
    #expect(diffAssign.words == BigUInt.Words(expectedWords))
  }

  @Test(
    "Multiplication",
    arguments: testData.multiplication.map { ($0.lWords, $0.rWords, $0.expectedWords) }
  )
  func multiplication(_ lWords: [UInt], _ rWords: [UInt], _ expectedWords: [UInt]) {
    let numA = BigUInt(words: lWords)
    let numB = BigUInt(words: rWords)
    let product = numA * numB
    let productReversed = numB * numA
    var productAssign = numA
    productAssign *= numB
    #expect(product.words == BigUInt.Words(expectedWords))
    #expect(productReversed.words == BigUInt.Words(expectedWords))
    #expect(product == productReversed)
    #expect(productAssign.words == BigUInt.Words(expectedWords))
  }

  @Test(
    "Division/Modulus",
    arguments: testData.divisionModulus.map { ($0.dividendWords, $0.divisorWords, $0.quotientWords, $0.remainderWords) }
  )
  func division(_ dividendWords: [UInt], _ divisorWords: [UInt], _ quotientWords: [UInt], _ remainderWords: [UInt]) {
    let numA = BigUInt(words: dividendWords)
    let numB = BigUInt(words: divisorWords)
    let (quotient, remainder) = numA.quotientAndRemainder(dividingBy: numB)
    let quotient2 = numA / numB
    var quotient3 = numA
    quotient3 /= numB
    let remainder2 = numA % numB
    var remainder3 = numA
    remainder3 %= numB
    #expect(quotient.words == BigUInt.Words(quotientWords))
    #expect(remainder.words == BigUInt.Words(remainderWords))
    #expect(quotient2.words == BigUInt.Words(quotientWords))
    #expect(remainder2.words == BigUInt.Words(remainderWords))
    #expect(quotient3.words == BigUInt.Words(quotientWords))
    #expect(remainder3.words == BigUInt.Words(remainderWords))
  }

  @Test(
    "Raise to power",
    arguments: testData.power.map { ($0.baseWords, $0.exponent, $0.expectedWords) }
  )
  func raiseToPower(_ baseWords: [UInt], _ exponent: Int, _ expectedWords: [UInt]) {
    let base = BigUInt(words: baseWords)
    let result = base.raised(to: exponent)
    #expect(result.words == BigUInt.Words(expectedWords))
  }

  @Test(
    "Greatest common divisor",
    arguments: testData.gcdLcm.map { ($0.lWords, $0.rWords, $0.expectedGcdWords) }
  )
  func greatestCommonDivisor(_ lWords: [UInt], _ rWords: [UInt], _ expectedWords: [UInt]) {
    let numA = BigUInt(words: lWords)
    let numB = BigUInt(words: rWords)
    let result = numA.greatestCommonDivisor(numB)
    #expect(result.words == BigUInt.Words(expectedWords))
  }

  @Test(
    "Lowest common multiple",
    arguments: testData.gcdLcm.map { ($0.lWords, $0.rWords, $0.expectedLcmWords) }
  )
  func lowestCommonMultiple(_ lWords: [UInt], _ rWords: [UInt], _ expectedWords: [UInt]) {
    let numA = BigUInt(words: lWords)
    let numB = BigUInt(words: rWords)
    let result = numA.lowestCommonMultiple(numB)
    #expect(result.words == BigUInt.Words(expectedWords))
  }

  @Test(
    "Bit width",
    arguments: testData.bitWidth.map { ($0.words, $0.bitWidth, $0.leadingZeroBitCount, $0.trailingZeroBitCount) }
  )
  func bitWidth(
    _ words: [UInt],
    _ expectedBitWidth: Int,
    _ expectedLeadingZeroBitCount: Int,
    _ expectedTrailingZeroBitCount: Int
  ) {
    let num = BigUInt(words: words)
    #expect(num.bitWidth == expectedBitWidth)
    #expect(num.leadingZeroBitCount == expectedLeadingZeroBitCount)
    #expect(num.trailingZeroBitCount == expectedTrailingZeroBitCount)
  }

  @Test(
    "Bitwise operations",
    arguments: testData.bitwiseOps.map {
      (
        $0.lWords, $0.rWords,
        $0.expectedAndWords, $0.expectedOrWords, $0.expectedXorWords,
        $0.expectedNotLWords, $0.expectedNotRWords
      )
    }
  )
  func bitwiseOperations(
    _ lWords: [UInt],
    _ rWords: [UInt],
    _ expectedAndWords: [UInt],
    _ expectedOrWords: [UInt],
    _ expectedXorWords: [UInt],
    _ expectedNotLWords: [UInt],
    _ expectedNotRWords: [UInt]
  ) {
    let numL = BigUInt(words: lWords)
    let numR = BigUInt(words: rWords)
    let resultAnd = numL & numR
    var resultAndAssign = numL
    resultAndAssign &= numR
    let resultOr = numL | numR
    var resultOrAssign = numL
    resultOrAssign |= numR
    let resultXor = numL ^ numR
    var resultXorAssign = numL
    resultXorAssign ^= numR
    let resultNotL = ~numL
    let resultNotR = ~numR
    #expect(resultAnd.words == BigUInt.Words(expectedAndWords))
    #expect(resultAndAssign.words == BigUInt.Words(expectedAndWords))
    #expect(resultOr.words == BigUInt.Words(expectedOrWords))
    #expect(resultOrAssign.words == BigUInt.Words(expectedOrWords))
    #expect(resultXor.words == BigUInt.Words(expectedXorWords))
    #expect(resultXorAssign.words == BigUInt.Words(expectedXorWords))
    #expect(resultNotL.words == BigUInt.Words(expectedNotLWords))
    #expect(resultNotR.words == BigUInt.Words(expectedNotRWords))
  }

  @Test(
    "Bit shifts",
    arguments: testData.bitwiseShift.map { ($0.words, $0.shift, $0.expectedLeftWords, $0.expectedRightWords) }
  )
  func bitShifts(_ words: [UInt], _ shift: Int, _ expectedLeftWords: [UInt], _ expectedRightWords: [UInt]) {
    let numA = BigUInt(words: words)
    let leftShift = numA << shift
    var leftShiftAssign = numA
    leftShiftAssign <<= shift
    let rightShift = numA >> shift
    var rightShiftAssign = numA
    rightShiftAssign >>= shift
    #expect(leftShift.words == BigUInt.Words(expectedLeftWords))
    #expect(rightShift.words == BigUInt.Words(expectedRightWords))
    #expect(leftShiftAssign.words == BigUInt.Words(expectedLeftWords))
    #expect(rightShiftAssign.words == BigUInt.Words(expectedRightWords))
  }

  @Test(
    "Comparison operations",
    arguments: testData.comparison.map {
      ($0.lWords, $0.rWords, $0.expectedEq, $0.expectedLt, $0.expectedLtEq, $0.expectedGt, $0.expectedGtEq)
    }
  )
  func comparisonOperations(
    _ lWords: [UInt],
    _ rWords: [UInt],
    _ expectedEq: Bool,
    _ expectedLt: Bool,
    _ expectedLtEq: Bool,
    _ expectedGt: Bool,
    _ expectedGtEq: Bool
  ) {
    let numL = BigUInt(words: lWords)
    let numR = BigUInt(words: rWords)
    #expect((numL < numR) == expectedLt)
    #expect((numL <= numR) == expectedLtEq)
    #expect((numL > numR) == expectedGt)
    #expect((numL >= numR) == expectedGtEq)
    #expect((numL == numR) == expectedEq)
  }

  @Test(
    "Hashing",
    arguments: [
      (42, 42, 100),
      (0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0x10000000000000000),
      (0x10000000000000000, 0x10000000000000000, 0x20000000000000000),
      (0x1234567890ABCDEF1234567890ABCDEF, 0x1234567890ABCDEF1234567890ABCDEF, 0x1234567890ABCDEF1234567890ABCDE0),
    ] as [(StaticBigInt, StaticBigInt, StaticBigInt)]
  )
  func hashing(_ a: StaticBigInt, _ b: StaticBigInt, _ c: StaticBigInt) {
    let numA = BigUInt(integerLiteral: a)
    let numB = BigUInt(integerLiteral: b)
    let numC = BigUInt(integerLiteral: c)

    #expect(numA.hashValue == numB.hashValue)
    #expect(numA.hashValue != numC.hashValue)
  }

  @Test("Zero handling")
  func zeroHandling() {
    let zero = BigUInt()
    let one: BigUInt = 1

    #expect(zero + zero == zero)
    #expect(zero * one == zero)
    #expect(zero / one == zero)
    #expect(zero % one == zero)
    #expect(zero << 1 == zero)
    #expect(zero >> 1 == zero)
  }

  @Test(
    "Integer conversion from BigUInt",
    arguments: testData.integerConversion.map {
      (
        $0.sourceWords,
        $0.expectedInt8, $0.expectedUInt8,
        $0.expectedInt16, $0.expectedUInt16,
        $0.expectedInt32, $0.expectedUInt32,
        $0.expectedInt64, $0.expectedUInt64,
        $0.expectedInt128, $0.expectedUInt128,
        $0.expectedInt, $0.expectedUInt
      )
    }
  )
  func integerConversionFromBigUInt(
    _ sourceWords: [UInt],
    _ expectedInt8: Int8?,
    _ expectedUInt8: UInt8?,
    _ expectedInt16: Int16?,
    _ expectedUInt16: UInt16?,
    _ expectedInt32: Int32?,
    _ expectedUInt32: UInt32?,
    _ expectedInt64: Int64?,
    _ expectedUInt64: UInt64?,
    _ expectedInt128: Int128?,
    _ expectedUInt128: UInt128?,
    _ expectedInt: Int?,
    _ expectedUInt: UInt?
  ) {
    let num = BigUInt(words: sourceWords)
    let int8 = Int8(exactly: num)
    let uint8 = UInt8(exactly: num)
    let int16 = Int16(exactly: num)
    let uint16 = UInt16(exactly: num)
    let int32 = Int32(exactly: num)
    let uint32 = UInt32(exactly: num)
    let int64 = Int64(exactly: num)
    let uint64 = UInt64(exactly: num)
    let int128 = Int128(exactly: num)
    let uint128 = UInt128(exactly: num)
    let int = Int(exactly: num)
    let uint = UInt(exactly: num)

    // Int8/UInt8
    #expect(int8 == expectedInt8)
    #expect(uint8 == expectedUInt8)

    // Int16/UInt16
    #expect(int16 == expectedInt16)
    #expect(uint16 == expectedUInt16)

    // Int32/UInt32
    #expect(int32 == expectedInt32)
    #expect(uint32 == expectedUInt32)

    // Int64/UInt64
    #expect(int64 == expectedInt64)
    #expect(uint64 == expectedUInt64)

    // Int/UInt
    #expect(int == expectedInt)
    #expect(uint == expectedUInt)

    // Int128/UInt128
    #expect(int128 == expectedInt128)
    #expect(uint128 == expectedUInt128)
  }

  @Test(
    "Floating point initialization",
    arguments: testData.floatInitialization.map { ($0.floatValue, $0.precision, $0.expectedWords) }
  )
  func floatingPointInitialization(
    _ floatValue: Double,
    _ precision: Int,
    _ expectedWords: [UInt]
  ) throws {
    // Define maximum exactly representable integers for each precision
    let float16ExactMax: Double = 2048.0    // 2^11
    let float32ExactMax: Double = 16777216.0    // 2^24
    let float64ExactMax: Double = 9007199254740992.0    // 2^53

    switch precision {
    case 16:
      let num = BigUInt(Float16(floatValue))
      #expect(num.words == BigUInt.Words(expectedWords))
      // Only test UInt128 equality for values within exact precision range
      if floatValue <= float16ExactMax {
        let int = UInt128(floatValue)
        #expect(num == BigUInt(int))
        if UInt128(exactly: floatValue) != nil {
          let exact = try #require(BigUInt(exactly: floatValue))
          #expect(exact.words == BigUInt.Words(expectedWords))
        }
      }
    case 32:
      let num = BigUInt(Float32(floatValue))
      #expect(num.words == BigUInt.Words(expectedWords))
      // Only test UInt128 equality for values within exact precision range
      if floatValue <= float32ExactMax {
        let int = UInt128(floatValue)
        #expect(num == BigUInt(int))
        if UInt128(exactly: floatValue) != nil {
          let exact = try #require(BigUInt(exactly: floatValue))
          #expect(exact.words == BigUInt.Words(expectedWords))
        }
      }
    case 64:
      let num = BigUInt(floatValue)
      #expect(num.words == BigUInt.Words(expectedWords))
      // Only test UInt128 equality for values within exact precision range
      if floatValue <= float64ExactMax {
        let int = UInt128(floatValue)
        #expect(num == BigUInt(int))
        if UInt128(exactly: floatValue) != nil {
          let exact = try #require(BigUInt(exactly: floatValue))
          #expect(exact.words == BigUInt.Words(expectedWords))
        }
      }
    default:
      fatalError("Unexpected precision: \(precision)")
    }
  }

  @Test("Floating point initialization special cases")
  func floatingPointInitializationSpecialCases() {
    #expect(BigUInt(exactly: Double.nan) == nil)
    #expect(BigUInt(exactly: +Double.infinity) == nil)
    #expect(BigUInt(exactly: -Double.infinity) == nil)
  }

  @Test(
    "Encode/decode bytes",
    arguments: testData.encoding.map { ($0.words, $0.encodedBytes, $0.inputBytes) }
  )
  func encodeDecodeBytes(_ words: [UInt], _ expectedBytes: [UInt8], _ inputBytes: [UInt8]?) {
    let number = BigUInt(words: words)

    // Test encoding
    let encoded = number.encode()
    #expect(encoded == expectedBytes)

    // Test decoding
    let decoded = BigUInt(encoded: encoded)
    #expect(decoded == number)

    if let inputBytes = inputBytes {
      let decoded2 = BigUInt(encoded: inputBytes)
      #expect(decoded2 == number)
    }
  }

  @Test("isMultiple implementation")
  func isMultipleImplementation() {
    // Setup test values
    let zero = BigUInt.zero
    let one = BigUInt.one
    let two = BigUInt.two
    let ten = BigUInt.ten
    let hundred = BigUInt(100)
    let largeNumber = BigUInt("123456789123456789123456789")!
    let divisibleLargeNumber = largeNumber * BigUInt(42)

    // Zero is multiple of everything except zero
    #expect(zero.isMultiple(of: one))
    #expect(zero.isMultiple(of: two))
    #expect(zero.isMultiple(of: ten))
    #expect(zero.isMultiple(of: hundred))
    #expect(zero.isMultiple(of: largeNumber))

    // One is multiple of only one
    #expect(one.isMultiple(of: one))
    #expect(!one.isMultiple(of: two))
    #expect(!one.isMultiple(of: ten))
    #expect(!one.isMultiple(of: hundred))
    #expect(!one.isMultiple(of: largeNumber))

    // Basic multiples
    #expect(ten.isMultiple(of: one))
    #expect(ten.isMultiple(of: two))
    #expect(ten.isMultiple(of: BigUInt(5)))
    #expect(!ten.isMultiple(of: BigUInt(3)))
    #expect(!ten.isMultiple(of: hundred))

    // Self is always multiple of self
    #expect(hundred.isMultiple(of: hundred))
    #expect(largeNumber.isMultiple(of: largeNumber))

    // Large numbers
    #expect(divisibleLargeNumber.isMultiple(of: largeNumber))
    #expect(divisibleLargeNumber.isMultiple(of: BigUInt(42)))
    #expect(divisibleLargeNumber.isMultiple(of: BigUInt(6)))
    #expect(divisibleLargeNumber.isMultiple(of: BigUInt(7)))
    #expect(!divisibleLargeNumber.isMultiple(of: BigUInt(11)))

    // Powers of 2 - testing trailing zeros optimization
    let powerOf2 = BigUInt(1) << 64
    let multiplePowerOf2 = powerOf2 * BigUInt(42)
    #expect(powerOf2.isMultiple(of: BigUInt(1) << 32))
    #expect(powerOf2.isMultiple(of: BigUInt(1) << 16))
    #expect(powerOf2.isMultiple(of: BigUInt(1) << 8))
    #expect(powerOf2.isMultiple(of: BigUInt(1) << 4))
    #expect(powerOf2.isMultiple(of: BigUInt(1) << 2))
    #expect(powerOf2.isMultiple(of: BigUInt(1) << 1))
    #expect(!powerOf2.isMultiple(of: BigUInt(1) << 128))

    #expect(multiplePowerOf2.isMultiple(of: BigUInt(1) << 32))
    #expect(multiplePowerOf2.isMultiple(of: BigUInt(1) << 16))
    #expect(multiplePowerOf2.isMultiple(of: BigUInt(1) << 8))
    #expect(multiplePowerOf2.isMultiple(of: BigUInt(1) << 4))
    #expect(multiplePowerOf2.isMultiple(of: BigUInt(1) << 2))
    #expect(multiplePowerOf2.isMultiple(of: BigUInt(1) << 1))
    #expect(!multiplePowerOf2.isMultiple(of: BigUInt(1) << 128))

    // Test two-word divisors (GCD method)
    let twoWordDivisor = BigUInt(UInt.max) + BigUInt(1)
    let multipleTwoWordDivisor = twoWordDivisor * BigUInt(123)
    #expect(multipleTwoWordDivisor.isMultiple(of: twoWordDivisor))
    #expect(!multipleTwoWordDivisor.isMultiple(of: twoWordDivisor + BigUInt(1)))

    // Test large divisors (fallback method)
    let largeWordDivisor = BigUInt(UInt.max) + BigUInt(1)
    let veryLargeDivisor = largeWordDivisor * largeWordDivisor * largeWordDivisor
    let multipleVeryLargeDivisor = veryLargeDivisor * BigUInt(456)
    #expect(multipleVeryLargeDivisor.isMultiple(of: veryLargeDivisor))
    #expect(!multipleVeryLargeDivisor.isMultiple(of: veryLargeDivisor + BigUInt(1)))
  }
}
