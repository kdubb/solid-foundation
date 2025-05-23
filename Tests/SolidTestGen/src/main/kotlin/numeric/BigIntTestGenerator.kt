@file:OptIn(ExperimentalUnsignedTypes::class)

package io.github.solidswift.numeric

import io.github.solidswift.numeric.NumericTestGenerator.Companion.FloatPrecision
import java.math.BigInteger
import java.math.BigInteger.ONE
import java.math.BigInteger.TEN
import java.math.BigInteger.TWO
import java.math.BigInteger.ZERO
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.pow
import kotlin.math.sign


class BigIntTestGenerator : NumericTestGenerator() {

  companion object {

    val BigInteger.signedWords: List<ULong>
      get() = listOf((signum() + 1).toULong()) + this.abs().words

    val BigInteger.signedBytes: Collection<UByte>
      get() {
        val byteLength = max(1, (abs().bitLength() + 8) / 8)
        val bytes = unsignedBytes
        return if (bytes.size < byteLength) {
          listOf(if (signum() < 0) UByte.MAX_VALUE else 0.toUByte()) + bytes
        } else {
          bytes
        }
      }

    fun Double.signedWords(precision: FloatPrecision): List<ULong> =
      listOf((sign + 1).toULong()) + abs(this).words(precision)
  }

  override fun generateTests() = buildMap {
    put("stringInitialization", generateStringInitTestCases())
    put("floatInitialization", generateFloatInitTestCases())
    put("bitWidth", generateBitWidthTestCases())
    put("addition", generateAdditionTestCases())
    put("subtraction", generateSubtractionTestCases())
    put("multiplication", generateMultiplicationTestCases())
    put("divisionModulus", generateDivisionModulusTestCases())
    put("negation", generateNegationTestCases())
    put("abs", generateAbsTestCases())
    put("bitwiseOps", generateBitwiseOpsTestCases())
    put("bitwiseShift", generateBitwiseShiftTestCases())
    put("comparison", generateComparisonTestCases())
    put("power", generatePowerTestCases())
    put("gcdLcm", generateGcdLcmTestCases())
    put("integerConversion", generateIntegerConversionTestCases())
    put("twosComplementInit", generateTwosComplementInitTestCases())
    put("encoding", generateEncodingTestCases())
  }

  private fun generateStringInitTestCases() = buildList {
    fun case(input: String, expected: BigInteger?) = mapOf(
      "input" to input,
      "expectedWords" to expected?.signedWords
    )

    fun case(valid: BigInteger) = case(valid.toString(), valid)
    fun case(invalid: String) = case(invalid, null)

    // Small numbers
    listOf(
      bigInt(-100),
      bigInt(-1),
      ZERO,
      ONE,
      bigInt(42),
      // TODO: bigInt(-42),
      bigInt(100),
      bigInt(255),
      // TODO: bigInt(-255),
      bigInt(256),
      // TODO: bigInt(-256),
      bigInt(65535),
      // TODO: bigInt(-65535),
      bigInt(65536),
      // TODO: bigInt(-65536)
    ).forEach { add(case(it)) }

    // Medium numbers
    listOf(
      TEN.pow(6).negate(),
      TEN.pow(9).negate(),
      TEN.pow(18).negate(),
      TWO.pow(63).negate(),
      TEN.pow(6),
      TEN.pow(9),
      TEN.pow(18),
      TWO.pow(63).minus(ONE),
    ).forEach { add(case(it)) }

    // Large numbers
    listOf(
      TEN.pow(50).negate(),
      TEN.pow(100).negate(),
      TEN.pow(50),
      TEN.pow(100),
    ).forEach { add(case(it)) }

    // Invalid cases
    listOf("", " ", " 123", "123 ").forEach { add(case(it)) }
  }

  private fun generateFloatInitTestCases() = buildList {

    fun case(value: Double, precision: FloatPrecision, expected: List<ULong>) =
      mapOf(
        "floatValue" to value,
        "precision" to precision.bits,
        "expectedWords" to expected
      )

    fun case(value: Double, precision: FloatPrecision) =
      case(value, precision, value.signedWords(precision))

    // Basic values
    val values = listOf(
      0.0, 1.0, -1.0, 2.0, -2.0, 10.0, -10.0,
      100.0, -100.0, 1000.0, -1000.0,
      1.5, -1.5, 2.5, -2.5, 3.14, -3.14
    )

    // Power of 2 values
    val pow2Values = (1..9)
      .let { range ->
        range.map { (2.0).pow(it) } + range.map { -(2.0.pow(it)) }
      }

    // Larger values
    val largerValues = (2..9)
      .let { range ->
        range.map { 10.0.pow(it) } + range.map { -(10.0.pow(it)) }
      }

    // Edge cases for each precision
    val edgeValues = listOf(
      FLOAT16_INT_MAX, -FLOAT16_INT_MAX,
      FLOAT32_INT_MAX, -FLOAT32_INT_MAX,
      FLOAT64_INT_MAX, -FLOAT64_INT_MAX
    ).map { it.toDouble() }

    // Special values
    val specialValues = listOf(
      Double.POSITIVE_INFINITY,
      Double.NEGATIVE_INFINITY,
      Double.NaN
    )

    val allTestValues = values + pow2Values + largerValues + edgeValues + specialValues

    for (value in allTestValues) {
      if (value.isFinite()) {
        if (abs(value) <= FLOAT16_MAX) {
          add(case(value, FloatPrecision.Half))
        }
        if (abs(value) <= FLOAT32_MAX) {
          add(case(value, FloatPrecision.Single))
        }
        add(case(value, FloatPrecision.Double))
      } else {
        // TODO: Add tests for NaN and Infinity
      }
    }
  }

  private fun generateBitWidthTestCases() = buildList {
    fun case(value: BigInteger) = mapOf(
      "words" to value.signedWords,
      "bitWidth" to value.abs().bitLength() + 1,
      "leadingZeroBitCount" to 0,
      "trailingZeroBitCount" to (value.lowestSetBit.takeIf { it != -1 } ?: 0)
    )

    // Test various bit widths for positive numbers
    listOf(0, 1, 2, 3, 7, 8, 16, 32, 63, 64, 65, 127, 128).forEach { i ->
      val n = if (i == 0) ZERO else ONE.shiftLeft(i).minus(ONE)
      add(case(n))
    }

    // Test various bit widths for negative numbers
    listOf(1, 2, 3, 7, 8, 16, 32, 63, 64, 65, 127, 128).forEach { i ->
      val n = ONE.shiftLeft(i).minus(ONE).negate()
      add(case(n))
    }

    // Test specific values
    listOf(
      bigInt(42),
      bigInt(-42),
      bigInt(0xFF),
      bigInt(-0xFF),
      bigInt(0xFFFF),
      bigInt(-0xFFFF),
      bigInt(0xFFFFFFFFL),
      bigInt(-0xFFFFFFFFL)
    ).forEach { add(case(it)) }
  }

  private fun generateAdditionTestCases() = buildList {
    fun case(left: BigInteger, right: BigInteger) = mapOf(
      "lWords" to left.signedWords,
      "rWords" to right.signedWords,
      "expectedWords" to left.add(right).signedWords
    )

    // Small additions with mixed signs
    listOf(
      ZERO to ZERO,
      ONE to ZERO,
      ZERO to ONE,
      ONE to ONE,
      bigInt(42) to bigInt(58),
      bigInt(-1) to ZERO,
      ZERO to bigInt(-1),
      bigInt(-1) to bigInt(-1),
      bigInt(-42) to bigInt(-58),
      ONE to bigInt(-1),
      bigInt(-1) to ONE,
      bigInt(100) to bigInt(-100),
      bigInt(-100) to bigInt(100)
    ).forEach { (left, right) -> add(case(left, right)) }

    // Word boundary tests
    listOf(
      bigInt(Long.MAX_VALUE) to ONE,
      bigInt(Long.MIN_VALUE) to bigInt(-1),
      bigInt(Long.MAX_VALUE) to bigInt(-1),
      bigInt(Long.MIN_VALUE) to ONE
    ).forEach { (left, right) -> add(case(left, right)) }

    // Large additions
    listOf(
      TEN.pow(50) to TEN.pow(50),
      TEN.pow(50).negate() to TEN.pow(50).negate(),
      TEN.pow(50) to TEN.pow(50).negate(),
      TEN.pow(50).negate() to TEN.pow(50),
      TEN.pow(100) to TEN.pow(100),
      TEN.pow(100).negate() to TEN.pow(100).negate()
    ).forEach { (left, right) -> add(case(left, right)) }
  }

  private fun generateSubtractionTestCases() = buildList {
    fun case(left: BigInteger, right: BigInteger) = mapOf(
      "lWords" to left.signedWords,
      "rWords" to right.signedWords,
      "expectedWords" to left.minus(right).signedWords
    )

    // Small subtractions with mixed signs
    listOf(
      ZERO to ZERO,
      ONE to ZERO,
      ONE to ONE,
      bigInt(100) to bigInt(42),
      ZERO to ONE,
      bigInt(42) to bigInt(100),
      bigInt(-1) to ZERO,
      ZERO to bigInt(-1),
      bigInt(-1) to bigInt(-1),
      bigInt(-100) to bigInt(-42),
      bigInt(-42) to bigInt(-100),
      bigInt(-1) to ONE,
      ONE to bigInt(-1)
    ).forEach { (left, right) -> add(case(left, right)) }

    // Word boundary tests
    listOf(
      bigInt(Long.MAX_VALUE) to bigInt(Long.MAX_VALUE),
      bigInt(Long.MIN_VALUE) to bigInt(Long.MIN_VALUE),
      bigInt(Long.MAX_VALUE) to bigInt(Long.MIN_VALUE),
      bigInt(Long.MIN_VALUE) to bigInt(Long.MAX_VALUE)
    ).forEach { (left, right) -> add(case(left, right)) }

    // Large subtractions
    listOf(
      TEN.pow(50) to TEN.pow(40),
      TEN.pow(50).negate() to TEN.pow(40).negate(),
      TEN.pow(50) to TEN.pow(40).negate(),
      TEN.pow(50).negate() to TEN.pow(40),
      TEN.pow(100) to TEN.pow(90),
      TEN.pow(100).negate() to TEN.pow(90).negate()
    ).forEach { (left, right) -> add(case(left, right)) }
  }

  private fun generateMultiplicationTestCases() = buildList {
    fun case(left: BigInteger, right: BigInteger) = mapOf(
      "lWords" to left.signedWords,
      "rWords" to right.signedWords,
      "expectedWords" to left.multiply(right).signedWords
    )

    // Small multiplications with mixed signs
    listOf(
      ZERO to ZERO,
      ONE to ZERO,
      ZERO to ONE,
      ONE to ONE,
      TWO to bigInt(3),
      bigInt(42) to bigInt(58),
      bigInt(-1) to ZERO,
      ZERO to bigInt(-1),
      bigInt(-1) to bigInt(-1),
      TWO.negate() to bigInt(3),
      TWO to bigInt(-3),
      TWO.negate() to bigInt(-3),
      bigInt(-42) to bigInt(58),
      bigInt(42) to bigInt(-58),
      bigInt(-42) to bigInt(-58)
    ).forEach { (left, right) -> add(case(left, right)) }

    // Word boundary tests
    listOf(
      bigInt(Long.MAX_VALUE) to bigInt(2),
      bigInt(Long.MIN_VALUE) to bigInt(2),
      bigInt(Long.MAX_VALUE) to bigInt(-1),
      bigInt(Long.MIN_VALUE) to bigInt(-1),
      bigInt(Long.MAX_VALUE) to bigInt(Long.MAX_VALUE),
      bigInt(Long.MIN_VALUE) to bigInt(Long.MIN_VALUE)
    ).forEach { (left, right) -> add(case(left, right)) }

    // Algorithm coverage tests
    listOf(
      bigInt("1234567890ABCDEF") to bigInt("FEDCBA0987654321"),
      bigInt("-1234567890ABCDEF") to bigInt("FEDCBA0987654321"),
      bigInt("1234567890ABCDEF") to bigInt("-FEDCBA0987654321"),
      bigInt("-1234567890ABCDEF") to bigInt("-FEDCBA0987654321"),
      bigInt(Long.MAX_VALUE) to bigInt(Long.MAX_VALUE),
      bigInt(Long.MIN_VALUE) to bigInt(Long.MAX_VALUE),
      bigInt(1, 2, 3, 4) to bigInt(5, 6, 7, 8),
      bigInt(-1, 2, 3, 4) to bigInt(5, 6, 7, 8),
      bigInt(1, 2, 3, 4) to bigInt(-5, 6, 7, 8),
      bigInt(-1, 2, 3, 4) to bigInt(-5, 6, 7, 8)
    ).forEach { (left, right) -> add(case(left, right)) }

    // Large multiplications
    listOf(
      TEN.pow(20) to TEN.pow(20),
      TEN.pow(20).negate() to TEN.pow(20),
      TEN.pow(20) to TEN.pow(20).negate(),
      TEN.pow(20).negate() to TEN.pow(20).negate(),
      TEN.pow(50) to TEN.pow(50),
      TEN.pow(50).negate() to TEN.pow(50).negate()
    ).forEach { (left, right) -> add(case(left, right)) }
  }

  private fun generateDivisionModulusTestCases() = buildList {
    fun case(dividend: BigInteger, divisor: BigInteger) {
      if (divisor == ZERO) return
      val (quotient, remainder) = dividend.divideAndRemainder(divisor)
      add(
        mapOf(
          "dividendWords" to dividend.signedWords,
          "divisorWords" to divisor.signedWords,
          "quotientWords" to quotient.signedWords,
          "remainderWords" to remainder.signedWords
        )
      )
    }

    // Small divisions with mixed signs
    listOf(
      ZERO to ONE,
      ONE to ONE,
      TWO to ONE,
      bigInt(4) to TWO,
      bigInt(100) to bigInt(3),
      ZERO to bigInt(-1),
      ONE to bigInt(-1),
      TWO to bigInt(-1),
      bigInt(4) to TWO.negate(),
      bigInt(100) to bigInt(-3),
      bigInt(-1) to ONE,
      TWO.negate() to ONE,
      bigInt(-4) to TWO,
      bigInt(-100) to bigInt(3),
      bigInt(-1) to bigInt(-1),
      TWO.negate() to bigInt(-1),
      bigInt(-4) to TWO.negate(),
      bigInt(-100) to bigInt(-3)
    ).forEach { (dividend, divisor) -> case(dividend, divisor) }

    // Word boundary tests
    listOf(
      bigInt(Long.MAX_VALUE) to ONE,
      bigInt(Long.MIN_VALUE) to ONE,
      bigInt(Long.MAX_VALUE) to bigInt(-1),
      bigInt(Long.MIN_VALUE) to bigInt(-1),
      bigInt(Long.MAX_VALUE) to bigInt(Long.MAX_VALUE),
      bigInt(Long.MIN_VALUE) to bigInt(Long.MIN_VALUE)
    ).forEach { (dividend, divisor) -> case(dividend, divisor) }

    // Algorithm coverage tests
    listOf(
      bigInt(0x1234567890ABCDEFL) to bigInt(0x123456),
      bigInt(-0x1234567890ABCDEFL) to bigInt(0x123456),
      bigInt(0x1234567890ABCDEFL) to bigInt(-0x123456),
      bigInt(-0x1234567890ABCDEFL) to bigInt(-0x123456),
      bigInt(1, 2, 3, 4) to bigInt(5, 0, 0, 0),
      bigInt(-1, 2, 3, 4) to bigInt(5, 0, 0, 0),
      bigInt(1, 2, 3, 4) to bigInt(-5, 0, 0, 0),
      bigInt(-1, 2, 3, 4) to bigInt(-5, 0, 0, 0)
    ).forEach { (dividend, divisor) -> case(dividend, divisor) }

    // Large divisions
    listOf(
      TEN.pow(50) to TEN.pow(25),
      TEN.pow(50).negate() to TEN.pow(25),
      TEN.pow(50) to TEN.pow(25).negate(),
      TEN.pow(50).negate() to TEN.pow(25).negate(),
      TEN.pow(100) to TEN.pow(50),
      TEN.pow(100).negate() to TEN.pow(50)
    ).forEach { (dividend, divisor) -> case(dividend, divisor) }
  }

  private fun generateNegationTestCases() = buildList {
    fun case(value: BigInteger) = mapOf(
      "valueWords" to value.signedWords,
      "expectedWords" to value.negate().signedWords
    )

    listOf(
      ZERO,
      ONE,
      bigInt(-1),
      bigInt(42),
      bigInt(-42),
      bigInt(Long.MAX_VALUE),
      bigInt(Long.MIN_VALUE),
      TEN.pow(20),
      TEN.pow(20).negate(),
      TEN.pow(50),
      TEN.pow(50).negate()
    ).forEach { add(case(it)) }
  }

  private fun generateAbsTestCases() = buildList {
    fun case(value: BigInteger) = mapOf(
      "valueWords" to value.signedWords,
      "expectedWords" to value.abs().signedWords
    )

    listOf(
      ZERO,
      ONE,
      bigInt(-1),
      bigInt(42),
      bigInt(-42),
      bigInt(Long.MAX_VALUE),
      bigInt(Long.MIN_VALUE),
      TEN.pow(20),
      TEN.pow(20).negate(),
      TEN.pow(50),
      TEN.pow(50).negate()
    ).forEach { add(case(it)) }
  }

  private fun generateBitwiseOpsTestCases() = buildList {
    fun case(a: BigInteger, b: BigInteger) {
      add(
        mapOf(
          "lWords" to a.signedWords,
          "rWords" to b.signedWords,
          "expectedAndWords" to a.and(b).signedWords,
          "expectedOrWords" to a.or(b).signedWords,
          "expectedXorWords" to a.xor(b).signedWords,
          "expectedNotLWords" to a.not().signedWords,
          "expectedNotRWords" to b.not().signedWords
        )
      )
    }

    listOf(
      bigInt(0b1010) to bigInt(0b1100),
      bigInt(-0b1010) to bigInt(0b1100),
      bigInt(0b1010) to bigInt(-0b1100),
      bigInt(-0b1010) to bigInt(-0b1100),
      bigInt(Long.MAX_VALUE) to bigInt(0xFFFFFFFFL),
      bigInt(Long.MIN_VALUE) to bigInt(0xFFFFFFFFL)
    ).forEach { (a, b) -> case(a, b) }
  }

  private fun generateBitwiseShiftTestCases() = buildList {
    val values = listOf(
      bigInt(0b1010),
      bigInt(-0b1010),
      bigInt(0x5555),
      bigInt(-0x5555),
      bigInt(Long.MAX_VALUE),
      bigInt(Long.MIN_VALUE)
    )

    val shifts = listOf(1, 4, 8, 16, 32, 63, 64, 65, 127, 128)

    for (value in values) {
      for (shift in shifts) {
        add(
          mapOf(
            "words" to value.signedWords,
            "shift" to shift,
            "expectedLeftWords" to value.shiftLeft(shift).signedWords,
            "expectedRightWords" to value.shiftRight(shift).signedWords
          )
        )
      }
    }
  }

  private fun generateComparisonTestCases() = buildList {
    fun case(a: BigInteger, b: BigInteger) =
      mapOf(
        "lWords" to a.signedWords,
        "rWords" to b.signedWords,
        "expectedEq" to (a == b),
        "expectedLt" to (a < b),
        "expectedLtEq" to (a <= b),
        "expectedGt" to (a > b),
        "expectedGtEq" to (a >= b)
      )

    // Equal numbers
    listOf(
      ZERO to ZERO,
      ONE to ONE,
      bigInt(-1) to bigInt(-1),
      bigInt(Long.MAX_VALUE) to bigInt(Long.MAX_VALUE),
      bigInt(Long.MIN_VALUE) to bigInt(Long.MIN_VALUE)
    ).forEach { (a, b) -> add(case(a, b)) }

    // Less than
    listOf(
      ZERO to ONE,
      ONE to TWO,
      bigInt(-2) to bigInt(-1),
      bigInt(-1) to ZERO,
    ).forEach { (a, b) -> add(case(a, b)) }

    // Greater than
    listOf(
      ONE to ZERO,
      TWO to ONE,
      bigInt(-1) to bigInt(-2),
      ZERO to bigInt(-1),
    ).forEach { (a, b) -> add(case(a, b)) }

    add(case(bigInt(Long.MIN_VALUE), bigInt(Long.MAX_VALUE)))
    add(case(bigInt(Long.MAX_VALUE), bigInt(Long.MIN_VALUE)))

    // Multi-word comparisons
    listOf(
      bigInt(1, 2, 3, 4) to bigInt(1, 2, 3, 4),
      bigInt(1, 2, 3, 4) to bigInt(5, 6, 7, 8),
      bigInt(5, 6, 7, 8) to bigInt(1, 2, 3, 4),

      bigInt(-1, 2, 3, 4) to bigInt(-1, 2, 3, 4),
      bigInt(-5, 6, 7, 8) to bigInt(-1, 2, 3, 4),
      bigInt(-1, 2, 3, 4) to bigInt(-5, 6, 7, 8),
    ).forEach { (a, b) -> add(case(a, b)) }
  }

  private fun generatePowerTestCases() = buildList {
    fun case(base: BigInteger, exponent: Int) = mapOf(
      "baseWords" to base.signedWords,
      "exponent" to exponent,
      "expectedWords" to base.pow(exponent).signedWords
    )

    // Simple cases
    listOf(
      ZERO to 0,  // 0^0 = 1 (mathematical convention)
      ZERO to 1,  // 0^1 = 0
      ONE to 0,   // 1^0 = 1
      ONE to 1,   // 1^1 = 1
      bigInt(-1) to 0,  // (-1)^0 = 1
      bigInt(-1) to 1,  // (-1)^1 = -1
      bigInt(-1) to 2,  // (-1)^2 = 1
      TWO to 0,   // 2^0 = 1
      TWO to 1,   // 2^1 = 2
      TWO to 2,   // 2^2 = 4
      TWO.negate() to 2,  // (-2)^2 = 4
      TWO.negate() to 3,  // (-2)^3 = -8
      bigInt(3) to 2,  // 3^2 = 9
      bigInt(-3) to 2  // (-3)^2 = 9
    ).forEach { (base, exp) -> add(case(base, exp)) }

    // Powers of 2, -2, 10, and -10
    listOf(1, 2, 3, 10, 20, 50).forEach { exp ->
      add(case(TWO, exp))
      add(case(TWO.negate(), exp))
      add(case(TEN, exp))
      add(case(TEN.negate(), exp))
    }

    // Other interesting bases
    listOf(
      bigInt(3) to 10,
      bigInt(-3) to 10,
      bigInt(-3) to 11,
      bigInt(5) to 7,
      bigInt(-5) to 7
    ).forEach { (base, exp) -> add(case(base, exp)) }
  }

  private fun generateGcdLcmTestCases() = buildList {
    fun case(a: BigInteger, b: BigInteger) {
      val (gcd, lcm) = gcdLcm(a, b)
      add(
        mapOf(
          "lWords" to a.signedWords,
          "rWords" to b.signedWords,
          "expectedGcdWords" to gcd.signedWords,
          "expectedLcmWords" to lcm.signedWords
        )
      )
    }

    // Simple cases
    listOf(
      ZERO to ZERO,
      ONE to ZERO,
      ZERO to ONE,
      ONE to ONE,
      TWO to bigInt(3),
      bigInt(6) to bigInt(8),
      bigInt(12) to bigInt(18),
      bigInt(35) to bigInt(49),
      bigInt(48) to bigInt(180),
      bigInt(-12) to bigInt(18),
      bigInt(12) to bigInt(-18),
      bigInt(-12) to bigInt(-18),
      bigInt(-35) to bigInt(49),
      bigInt(35) to bigInt(-49),
      bigInt(-35) to bigInt(-49)
    ).forEach { (a, b) -> case(a, b) }

    // Edge cases and larger numbers
    listOf(
      bigInt(Long.MAX_VALUE) to bigInt(Long.MAX_VALUE - 1),
      bigInt(Long.MAX_VALUE) to bigInt(Long.MAX_VALUE).plus(ONE),
      bigInt(Long.MIN_VALUE) to bigInt(Long.MIN_VALUE).abs(),
      TEN.pow(20) to TEN.pow(21),
      TEN.pow(20).negate() to TEN.pow(21),
      TEN.pow(50) to TEN.pow(49)
    ).forEach { (a, b) -> case(a, b) }
  }

  private fun generateIntegerConversionTestCases() = buildList {
    fun case(value: BigInteger) = mapOf(
      "sourceWords" to value.signedWords,
      "expectedInt8" to value.takeIf { it in MIN_INT8..MAX_INT8 },
      "expectedUInt8" to value.takeIf { it in ZERO..MAX_UINT8 },
      "expectedInt16" to value.takeIf { it in MIN_INT16..MAX_INT16 },
      "expectedUInt16" to value.takeIf { it in ZERO..MAX_UINT16 },
      "expectedInt32" to value.takeIf { it in MIN_INT32..MAX_INT32 },
      "expectedUInt32" to value.takeIf { it in ZERO..MAX_UINT32 },
      "expectedInt64" to value.takeIf { it in MIN_INT64..MAX_INT64 },
      "expectedUInt64" to value.takeIf { it in ZERO..MAX_UINT64 },
      "expectedInt128" to value.takeIf { it in MIN_INT128..MAX_INT128 },
      "expectedUInt128" to value.takeIf { it in ZERO..MAX_UINT128 },
      "expectedInt" to value.takeIf { it in MIN_INT64..MAX_INT64 },
      "expectedUInt" to value.takeIf { it in ZERO..MAX_UINT64 }
    )

    listOf(
      ZERO,
      ONE,
      bigInt(-1),
      MAX_INT8,
      MIN_INT8,
      MAX_INT8.negate(),
      MAX_UINT8,
      MAX_INT16,
      MIN_INT16,
      MAX_INT16.negate(),
      MAX_UINT16,
      MAX_INT32,
      MIN_INT32,
      MAX_INT32.negate(),
      MAX_UINT32,
      MAX_INT64,
      MIN_INT64,
      MAX_INT64.negate(),
      MAX_UINT64,
      MAX_INT128,
      MIN_INT128,
      MAX_INT128.negate(),
      MAX_UINT128,
      TEN.pow(20),
      TEN.pow(20).negate(),
      TEN.pow(50),
      TEN.pow(50).negate()
    ).forEach { add(case(it)) }
  }

  private fun generateTwosComplementInitTestCases() = buildList {
    fun case(value: BigInteger) {
      val tcWords = if (value >= ZERO) {
        val words = value.words
        if (words.isNotEmpty() && words.last().shr(63) == 1UL) {
          words + ZERO
        } else {
          words
        }
      } else {
        val absVal = value.abs()
        val absWords = absVal.words
        val tcWords = mutableListOf<ULong>()
        var carry = 1UL

        for (word in absWords) {
          val inverted = word.inv() and ULong.MAX_VALUE
          val sum = inverted + carry
          carry = if (sum > ULong.MAX_VALUE) 1UL else 0UL
          tcWords.add(sum and ULong.MAX_VALUE)
        }

        if (absWords.isNotEmpty() && absWords.last().shr(63) == 1UL) {
          tcWords.add(ULong.MAX_VALUE)
        }

        tcWords
      }

      add(
        mapOf(
          "twosComplementWords" to tcWords,
          "expectedWords" to value.signedWords
        )
      )
    }

    listOf(
      ZERO,
      ONE,
      bigInt(42),
      bigInt(0xFF),
      bigInt(0xFFFF),
      bigInt(0xFFFFFFFFL),
      bigInt(Long.MAX_VALUE),
      bigInt(-1L).and(
        bigInt(Long.MAX_VALUE)
          .multiply(TWO)
          .add(ONE)
      ),
      ONE.shiftLeft(60),
      bigInt(0x123456789ABCDEF0L),
      ONE.shiftLeft(128).minus(ONE),
      bigInt(0x123456789ABCDEF0L)
        .shiftLeft(64)
        .add(bigInt(0x123456789ABCDEF0L)),
      bigInt(-1),
      bigInt(-42),
      bigInt(-0xFF),
      bigInt(-0xFFFF),
      bigInt(-0xFFFFFFFFL),
      bigInt(Long.MAX_VALUE).negate(),
      bigInt(Long.MIN_VALUE),
      bigInt(-1L).and(
        bigInt(Long.MAX_VALUE)
          .multiply(TWO)
          .add(ONE)
      ).negate(),
      bigInt(-0x123456789ABCDEF0L),
      ONE.shiftLeft(128).minus(ONE).negate(),
      bigInt(0x123456789ABCDEF0L)
        .shiftLeft(64)
        .add(bigInt(0x123456789ABCDEF0L))
        .negate()
    ).forEach { case(it) }
  }

  private fun generateEncodingTestCases() = buildList {
    fun case(value: BigInteger) {
      add(
        mapOf(
          "value" to value.toString(),
          "encodedBytes" to value.signedBytes,
          "words" to value.signedWords,
        )
      )
    }

    // Test values covering various cases
    listOf(
      ZERO,
      ONE,
      bigInt(-1),
      bigInt(127),
      bigInt(-128),
      bigInt(128),
      bigInt(-129),
      bigInt(255),
      bigInt(-256),
      bigInt(256),
      bigInt(-257),
      bigInt(0x7FFF),
      bigInt(-0x8000),
      bigInt(0x8000),
      bigInt(-0x8001),
      bigInt(0xFFFF),
      bigInt(-0x10000),
      bigInt(0x7FFFFFFF),
      bigInt(-0x80000000),
      bigInt(0xFFFFFFFFL),
      bigInt(-0x100000000L),
      bigInt(Long.MAX_VALUE),
      bigInt(Long.MIN_VALUE),
      bigInt(-1L).and(
        bigInt(Long.MAX_VALUE)
          .multiply(TWO)
          .add(ONE)
      ),
      bigInt("-10000000000000000"),
      bigInt("10000000000000000"),
      bigInt("-10000000000000001"),
      TEN.pow(20),
      TEN.pow(20).negate(),
      TEN.pow(50),
      TEN.pow(50).negate()
    ).forEach { case(it) }

    // Powers of 2 boundary cases
    (3..11).forEach { i ->
      val posPower = ONE.shiftLeft(i)
      val negPower = posPower.negate()
      case(posPower)
      case(negPower)
    }

    // Test values around Int64.min and Int64.max
    val int64Max = bigInt(Long.MAX_VALUE)
    val int64Min = bigInt(Long.MIN_VALUE)

    listOf(-10, -2, -1, 0, 1, 2, 10).forEach { offset ->
      if (offset == 0) {
        case(int64Max)
        case(int64Min)
      } else {
        case(int64Max.add(bigInt(offset)))
        case(int64Min.add(bigInt(offset)))
      }
    }

    // Leading zero bytes and 0xFF bytes
    listOf(1, 2, 4).forEach { padding ->
      // Positive values with leading zeros
      listOf(1, 0x7F, 0x80, 0xFF).forEach { value ->
        val bytes = bigInt(value).signedBytes
        val paddedBytes = UByteArray(padding) { 0.toUByte() } + bytes

        add(
          mapOf(
            "value" to value.toString(),
            "encodedBytes" to bytes.toList(),
            "words" to bigInt(value).signedWords,
            "inputBytes" to paddedBytes.toList()
          )
        )
      }

      // Negative values with leading 0xFF bytes
      listOf(-1, -0x80, -0x81, -0x100).forEach { value ->
        val bytes = bigInt(value).signedBytes
        val paddedBytes = UByteArray(padding) { 0xFF.toUByte() } + bytes

        add(
          mapOf(
            "value" to value.toString(),
            "encodedBytes" to bytes.toList(),
            "words" to bigInt(value).signedWords,
            "inputBytes" to paddedBytes.toList()
          )
        )
      }
    }
  }
}
