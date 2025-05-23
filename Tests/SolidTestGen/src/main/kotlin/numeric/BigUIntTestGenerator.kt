@file:OptIn(ExperimentalUnsignedTypes::class)

package io.github.solidswift.numeric

import io.github.solidswift.numeric.NumericTestGenerator.Companion.FloatPrecision
import java.math.BigDecimal
import java.math.BigInteger
import java.math.BigInteger.ONE
import java.math.BigInteger.TEN
import java.math.BigInteger.TWO
import java.math.BigInteger.ZERO
import kotlin.math.pow
import kotlin.math.roundToLong
import kotlin.math.truncate


class BigUIntTestGenerator : NumericTestGenerator() {

  override fun generateTests() = buildMap {
    put("stringInitialization", generateStringInitTestCases())
    put("bitWidth", generateBitWidthTestCases())
    put("addition", generateAdditionTestCases())
    put("subtraction", generateSubtractionTestCases())
    put("multiplication", generateMultiplicationTestCases())
    put("divisionModulus", generateDivisionModulusTestCases())
    put("bitwiseShift", generateBitwiseShiftTestCases())
    put("bitwiseOps", generateBitwiseOpsTestCases())
    put("comparison", generateComparisonTestCases())
    put("power", generatePowerTestCases())
    put("gcdLcm", generateGcdLcmTestCases())
    put("floatInitialization", generateFloatInitTestCases())
    put("encoding", generateEncodingTestCases())
    put("integerConversion", generateIntegerConversionTestCases())
  }

  private fun generateStringInitTestCases() = buildList {
    fun case(input: String, expected: BigInteger?) = mapOf(
      "input" to input,
      "expectedWords" to expected?.words
    )

    fun case(valid: BigInteger) = case(valid.toString(), valid)
    fun case(invalid: String) = case(invalid, null)

    // Small numbers
    listOf(
      ZERO,
      ONE,
      bigInt(42),
      bigInt(100),
      bigInt(255),
      bigInt(256),
      bigInt(65535),
      bigInt(65536)
    ).forEach { add(case(it)) }

    // Medium-sized numbers
    listOf(
      TEN.pow(6),
      TEN.pow(9),
      TEN.pow(18),
      BIG_WORD_MAX,
      ONE.shiftLeft(64),
      ONE.shiftLeft(65),
      ONE.shiftLeft(127),
      ONE.shiftLeft(128).subtract(ONE),
      ONE.shiftLeft(128)
    ).forEach { add(case(it)) }

    // Large numbers
    listOf(
      TEN.pow(50),
      TEN.pow(100),
      TEN.pow(300),
      TEN.pow(1000)
    ).forEach { add(case(it)) }

    // Invalid cases
    listOf("", "+", "-", " ", " 123", "123 ").forEach { add(case(it)) }
  }

  private fun generateBitWidthTestCases() = buildList {
    fun case(value: BigInteger) = mapOf(
      "words" to value.words,
      "bitWidth" to value.bitLength(),
      "leadingZeroBitCount" to 0,
      "trailingZeroBitCount" to (value.lowestSetBit.takeIf { it != -1 } ?: 0)
    )

    add(case(ZERO))

    listOf(1, 2, 3, 7, 8, 16, 32, 63, 64, 65, 127, 128, 129, 255, 256, 512)
      .map { ONE.shiftLeft(it).minus(ONE) }
      .forEach { add(case(it)) }

    listOf(
      bigInt(42),
      bigInt(0xFF),
      bigInt(0xFFFF),
      bigInt(0xFFFFFFFFL),
      bigInt(-1L).and(
        bigInt(Long.MAX_VALUE)
          .multiply(TWO)
          .add(ONE)
      )
    ).forEach { add(case(it)) }
  }

  private fun generateAdditionTestCases() = buildList {
    fun case(left: BigInteger, right: BigInteger) = mapOf(
      "lWords" to left.words,
      "rWords" to right.words,
      "expectedWords" to left.add(right).words
    )

    // Small additions
    listOf(
      ZERO to ZERO,
      ONE to ZERO,
      ZERO to ONE,
      ONE to ONE,
      bigInt(42) to bigInt(58),
      bigInt(0xFF) to ONE,
      bigInt(0xFFFF) to ONE,
      bigInt(0xFFFFFFFFL) to ONE,
      bigInt(-1L).and(
        bigInt(Long.MAX_VALUE)
          .multiply(TWO)
          .add(ONE)
      ) to ONE
    ).forEach { (left, right) -> add(case(left, right)) }

    // Word boundary tests
    listOf(
      bigInt(-1L).and(
        bigInt(Long.MAX_VALUE)
          .multiply(TWO)
          .add(ONE)
      ) to bigInt(-1L).and(
        bigInt(Long.MAX_VALUE)
          .multiply(TWO)
          .add(ONE)
      ),
      ONE.shiftLeft(64) to ONE.shiftLeft(64),
      ONE.shiftLeft(128).subtract(ONE) to ONE,
      ONE.shiftLeft(128).subtract(ONE) to
        ONE.shiftLeft(128).subtract(ONE)
    ).forEach { (left, right) -> add(case(left, right)) }

    // Large additions
    listOf(
      TEN.pow(50) to TEN.pow(50),
      TEN.pow(100) to TEN.pow(100),
      TEN.pow(300) to TEN.pow(300)
    ).forEach { (left, right) -> add(case(left, right)) }
  }

  private fun generateSubtractionTestCases() = buildList {
    fun case(left: BigInteger, right: BigInteger) = mapOf(
      "lWords" to left.words,
      "rWords" to right.words,
      "expectedWords" to left.subtract(right).words
    )

    // Basic cases (a >= b to avoid negative results)
    listOf(
      ONE to ZERO,
      ONE to ONE,
      bigInt(100) to bigInt(42),
      bigInt(0xFF) to bigInt(0x0F),
      bigInt(0x10000) to ONE,
      bigInt(0xFFFFFFFFL) to bigInt(0xF),
      bigInt(-1L).and(
        bigInt(Long.MAX_VALUE)
          .multiply(TWO)
          .add(ONE)
      ) to bigInt(0xFFFF)
    ).forEach { (left, right) -> add(case(left, right)) }

    // Word boundary tests
    listOf(
      ONE.shiftLeft(64) to ONE,
      ONE.shiftLeft(64) to ONE.shiftLeft(32),
      ONE.shiftLeft(128) to ONE.shiftLeft(64),
      ONE.shiftLeft(128) to ONE
    ).forEach { (left, right) -> add(case(left, right)) }

    // Large number of tests
    listOf(
      TEN.pow(50) to TEN.pow(40),
      TEN.pow(100) to TEN.pow(90),
      TEN.pow(300) to TEN.pow(290)
    ).forEach { (left, right) -> add(case(left, right)) }
  }

  private fun generateMultiplicationTestCases() = buildList {
    fun case(left: BigInteger, right: BigInteger) = mapOf(
      "lWords" to left.words,
      "rWords" to right.words,
      "expectedWords" to left.multiply(right).words
    )

    // Small multiplications
    listOf(
      ZERO to ZERO,
      ONE to ZERO,
      ZERO to ONE,
      ONE to ONE,
      TWO to bigInt(3),
      bigInt(42) to bigInt(58),
      bigInt(0xFF) to bigInt(0xFF),
      bigInt(0xFFFF) to bigInt(0xFFFF)
    ).forEach { (left, right) -> add(case(left, right)) }

    // Word boundary tests
    listOf(
      bigInt(0xFFFFFFFFL) to bigInt(0xFFFFFFFFL),
      bigInt(-1L).and(bigInt(Long.MAX_VALUE).multiply(TWO).add(ONE)) to TWO,
      ONE.shiftLeft(64) to TWO,
      ONE.shiftLeft(64) to ONE.shiftLeft(64)
    ).forEach { (left, right) -> add(case(left, right)) }

    // Algorithm coverage tests
    listOf(
      ONE.shiftLeft(64).subtract(TWO) to ONE.shiftLeft(64).subtract(TWO),
      ONE.shiftLeft(64).subtract(ONE) to ONE.shiftLeft(96).subtract(ONE),
      ONE.shiftLeft(80) to ONE.shiftLeft(80),
      bigInt(0x123456789ABCDEF0L) to bigInt(0xFEDCBA9876543210UL),
      ONE.shiftLeft(61).subtract(ONE) to ONE.shiftLeft(61).subtract(ONE),
      ONE.shiftLeft(128).subtract(ONE) to TWO,
      bigInt(1UL, 2UL, 3UL, 4UL) to bigInt(2UL),
      bigInt(1UL, 2UL, 3UL, 4UL) to bigInt(0UL, 1UL),
      bigInt(4UL, 3UL, 2UL, 1UL) to bigInt(1UL, 2UL, 3UL, 4UL),
      bigInt(ULong.MAX_VALUE, ULong.MAX_VALUE, ULong.MAX_VALUE) to bigInt(ULong.MAX_VALUE, ULong.MAX_VALUE),
      bigInt(1UL, 2UL) to bigInt(2UL, 1UL),
      bigInt(0x2637AB28) to bigInt(0x164B),
      bigInt(0x16B60) to bigInt(0x33E28),
    ).forEach { (left, right) -> add(case(left, right)) }

    // Large multiplications
    listOf(
      TEN.pow(20) to TEN.pow(20),
      TEN.pow(50) to TEN.pow(50),
      TEN.pow(100) to TEN.pow(10)
    ).forEach { (left, right) -> add(case(left, right)) }
  }

  private fun generateDivisionModulusTestCases() = buildList {
    fun case(dividend: BigInteger, divisor: BigInteger) {
      val (quotient, remainder) = dividend.divideAndRemainder(divisor)
      add(
        mapOf(
          "dividendWords" to dividend.words,
          "divisorWords" to divisor.words,
          "quotientWords" to quotient.words,
          "remainderWords" to remainder.words
        )
      )
    }

    // Small divisions
    listOf(
      ZERO to ONE,
      ONE to ONE,
      TWO to ONE,
      bigInt(4) to TWO,
      bigInt(100) to bigInt(3),
      bigInt(0x100) to bigInt(0x10),
      bigInt(0x10000) to bigInt(0x100),
      bigInt(0x1000000) to bigInt(0x10000)
    ).forEach { (dividend, divisor) -> case(dividend, divisor) }

    // Word boundary tests
    listOf(
      ONE.shiftLeft(64).add(ONE) to ONE.shiftLeft(32),
      bigInt(ULong.MAX_VALUE) to ONE.shiftLeft(32),
      ONE.shiftLeft(64) to ONE.shiftLeft(32),
      ONE.shiftLeft(128) to ONE.shiftLeft(64)
    ).forEach { (dividend, divisor) -> case(dividend, divisor) }

    // Algorithm coverage tests
    listOf(
      bigInt("1234") to bigInt("10000"),
      bigInt("100000000") to bigInt("10000"),
      bigInt("100000001") to bigInt("100000000"),
      bigInt("1FFFFFFFFFFFFFFFFFFFFFFFFFFF") to bigInt("100000000000000"),
      bigInt("100000000000000001") to bigInt("100000000000000000"),
      bigInt("00ABCDEF") to bigInt("00ABCDEF"),
      bigInt("100000000000000000000000000") to bigInt("FFFFFFFFFFFFFFFF"),
      bigInt("2FFFFFFFFFFFFFFC") to bigInt("FFFFFFFFFFFFFFFF"),
      bigInt("91a2b3c4d5e6f780000000000000000123456789abcdef") to bigInt("80000000000000000000000000000001"),
      bigInt("7dac3c24a5671d2f8255a4502032e391f3266bc0c6acdc3fe6ee40000000000000000000000") to bigInt("1e3e37763abc82400"),
      bigInt(1) to bigInt(1),
      bigInt(1) to bigInt(2),
      bigInt(2) to bigInt(1),
      bigInt() to bigInt(0, 1),
      bigInt(1) to bigInt(0, 1),
      bigInt(0, 1) to bigInt(0, 1),
      bigInt(0, 0, 1) to bigInt(0, 1),
      bigInt(0, 0, 1) to bigInt(1, 1),
      bigInt(0, 0, 1) to bigInt(3, 1),
      bigInt(0, 0, 1) to bigInt(75, 1),
      bigInt(0, 0, 0, 1) to bigInt(0, 1),
      bigInt(2, 4, 6, 8) to bigInt(1, 2),
      bigInt(2, 3, 4, 5) to bigInt(4, 5),
      bigInt(ULong.MAX_VALUE, ULong.MAX_VALUE - 1UL, ULong.MAX_VALUE) to bigInt(ULong.MAX_VALUE, ULong.MAX_VALUE),
      bigInt(0UL, ULong.MAX_VALUE, ULong.MAX_VALUE - 1UL) to bigInt(ULong.MAX_VALUE, ULong.MAX_VALUE),
      bigInt(0UL, 0UL, 0UL, 0UL, 0UL, ULong.MAX_VALUE / 2UL + 1UL, ULong.MAX_VALUE / 2UL) to
        bigInt(1UL, 0UL, 0UL, ULong.MAX_VALUE / 2UL + 1UL),
      bigInt(0UL, ULong.MAX_VALUE - 1UL, ULong.MAX_VALUE / 2UL + 1UL) to
        bigInt(ULong.MAX_VALUE, ULong.MAX_VALUE / 2UL + 1UL),
      bigInt(0UL, 0UL, 0x41UL.shl(WORD_BIT_WIDTH - 8)) to
        bigInt(ULong.MAX_VALUE, 1UL.shl(WORD_BIT_WIDTH - 1))
    ).forEach { (dividend, divisor) -> case(dividend, divisor) }

    // Large divisions
    listOf(
      TEN.pow(50) to TEN.pow(25),
      TEN.pow(100) to TEN.pow(50),
      TEN.pow(200) to TEN.pow(100)
    ).forEach { (dividend, divisor) -> case(dividend, divisor) }
  }

  private fun generateNegationTestCases() = buildList {
    fun case(value: BigInteger) = mapOf(
      "valueWords" to value.words,
      "expectedWords" to value.negate().words
    )

    // Test various values
    listOf(
      ZERO,
      ONE,
      bigInt(42),
      bigInt(-1L).and(
        bigInt(Long.MAX_VALUE)
          .multiply(TWO)
          .add(ONE)
      ),
      ONE.shiftLeft(64),
      TEN.pow(20),
      TEN.pow(50)
    ).forEach { add(case(it)) }
  }

  private fun generateAbsTestCases() = buildList {
    fun case(value: BigInteger) = mapOf(
      "valueWords" to value.words,
      "expectedWords" to value.abs().words
    )

    // Test various values
    listOf(
      ZERO,
      ONE,
      bigInt(42),
      bigInt(-1L).and(
        bigInt(Long.MAX_VALUE)
          .multiply(TWO)
          .add(ONE)
      ),
      ONE.shiftLeft(64),
      TEN.pow(20),
      TEN.pow(50)
    ).forEach { add(case(it)) }
  }

  private fun generateBitwiseShiftTestCases() = buildList {

    fun case(value: BigInteger, shift: Int): Map<String, Any> {
      val leftShifted = value.shl(shift)
      val rightShifted = value.shr(shift)
      return mapOf(
        "words" to value.words,
        "shift" to shift,
        "expectedLeftWords" to leftShifted.words,
        "expectedRightWords" to rightShifted.words
      )
    }

    val singleWord = bigInt("5555") to listOf(
      1, 4, 16, 32, 48, 49, 50, 64, 96, 97, 98, 112, 128, 129, 130, 176, 177, 178,
      192, 193, 194, 240, 241, 242, 256, 257, 258, 304, 305, 306, 320, 321, 322,
      368, 369, 370, 384, 385, 386, 496, 497, 498, 512, 513, 514
    )

    val doubleWord = bigInt("5555555555555555") to listOf(
      1, 2, 64, 65, 66, 128, 130, 192, 193, 194, 256, 257, 258
    )

    val quadWord = bigInt("5555555555555555555555555555555555") to listOf(
      1, 2, 64, 66, 128, 129, 130, 192, 193, 194, 256, 257, 258, 512, 513, 514
    )

    listOf(singleWord, doubleWord, quadWord).forEach { (value, shifts) ->
      shifts.forEach { shift ->
        add(case(value, shift))
      }
    }

    listOf(singleWord.first, doubleWord.first, quadWord.first).forEach { value ->
      listOf(1, 4, 16, 32, 48, 64, 96, 128, 192, 256).forEach { shift ->
        add(case(value, shift))
      }
    }
  }

  private fun generateBitwiseOpsTestCases() = buildList {
    fun case(a: BigInteger, b: BigInteger) {
      add(
        mapOf(
          "lWords" to a.words,
          "rWords" to b.words,
          "expectedAndWords" to a.and(b).words,
          "expectedOrWords" to a.or(b).words,
          "expectedXorWords" to a.xor(b).words,
          "expectedNotLWords" to a.not().and(ONE.shiftLeft(a.bitLength()).minus(ONE)).words,
          "expectedNotRWords" to b.not().and(ONE.shiftLeft(b.bitLength()).minus(ONE)).words
        )
      )
    }

    // Test cases
    listOf(
      bigInt("1010", 2) to bigInt("1100", 2),
      bigInt("FFFFFFFFFFFFFFFF") to bigInt("FFFFFFFF"),
      bigInt("FFFFFFFF") to bigInt("100000000"),
      bigInt("1010", 2) to ZERO,
      bigInt("FFFFFFFFFFFFFFFF") to ZERO
    ).forEach { (a, b) -> case(a, b) }
  }

  private fun generateComparisonTestCases() = buildList {
    fun case(a: BigInteger, b: BigInteger) =
      mapOf(
        "lWords" to a.words,
        "rWords" to b.words,
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
      bigInt(-1L).and(
        bigInt(Long.MAX_VALUE)
          .multiply(TWO)
          .add(ONE)
      ) to bigInt(-1L).and(
        bigInt(Long.MAX_VALUE)
          .multiply(TWO)
          .add(ONE)
      )
    ).forEach { (a, b) -> add(case(a, b)) }

    // Less than
    listOf(
      ZERO to ONE,
      ONE to TWO,
      bigInt(-1L).and(
        bigInt(Long.MAX_VALUE)
          .multiply(TWO)
          .add(ONE)
      ) to ONE.shiftLeft(64)
    ).forEach { (a, b) -> add(case(a, b)) }

    // Greater than
    listOf(
      ONE to ZERO,
      TWO to ONE,
      ONE.shiftLeft(64) to bigInt(-1L).and(
        bigInt(Long.MAX_VALUE)
          .multiply(TWO)
          .add(ONE)
      )
    ).forEach { (a, b) -> add(case(a, b)) }

    // Multi-word comparisons
    listOf(
      ONE.shiftLeft(64) to ONE.shiftLeft(65),
      ONE.shiftLeft(65) to ONE.shiftLeft(64)
    ).forEach { (a, b) -> add(case(a, b)) }
  }

  private fun generatePowerTestCases(): List<Map<String, Any>> = buildList {
    fun case(base: BigInteger, exponent: Int) = mapOf(
      "baseWords" to base.words,
      "exponent" to exponent,
      "expectedWords" to base.pow(exponent).words
    )

    // Simple cases
    listOf(
      ZERO to 0,  // 0^0 = 1 (mathematical convention)
      ZERO to 1,   // 0^1 = 0
      ONE to 0,   // 1^0 = 1
      ONE to 1,    // 1^1 = 1
      TWO to 0,  // 2^0 = 1
      TWO to 1,   // 2^1 = 2
      TWO to 2,  // 2^2 = 4
      TWO to 3,  // 2^3 = 8
      bigInt(3) to 2,  // 3^2 = 9
      bigInt(5) to 3,  // 5^3 = 125
      TEN to 2    // 10^2 = 100
    ).forEach { (base, exp) -> add(case(base, exp)) }

    // Powers of 2 & 10
    ((1..<100) + (100..<200 step 10) + (300..<500 step 100)).forEach { exp ->
      add(case(TWO, exp))
      add(case(TEN, exp))
    }

    // Other interesting bases
    listOf(
      3 to 27,
      5 to 20,
      7 to 15,
      11 to 10,
      16 to 16,
      17 to 15,
      42 to 8,
      99 to 7,
      0xFF to 4
    ).forEach { (base, exp) ->
      add(case(bigInt(base.toLong()), exp))
    }

    // Large bases with small exponents
    listOf(
      ONE.shiftLeft(64).subtract(ONE),
      ONE.shiftLeft(64),
      ONE.shiftLeft(128).subtract(ONE),
      TEN.pow(30),
      TEN.pow(50)
    ).forEach { base ->
      add(case(base, 2))
    }

    listOf(
      123456789 to 5,
      0xABCDEF to 6,
      0x123456789 to 4
    ).forEach { (base, exp) ->
      add(case(bigInt(base.toLong()), exp))
    }
  }

  private fun generateGcdLcmTestCases() = buildList {
    fun case(a: BigInteger, b: BigInteger) {
      val (gcd, lcm) = gcdLcm(a, b)
      add(
        mapOf(
          "lWords" to a.words,
          "rWords" to b.words,
          "expectedGcdWords" to gcd.words,
          "expectedLcmWords" to lcm.words
        )
      )
    }

    // Simple cases
    listOf(
      ZERO to ZERO,
      ONE to ZERO,
      ZERO to ONE,
      ONE to ONE,
      TWO to ONE,
      bigInt(4) to TWO,
      bigInt(6) to bigInt(8),
      bigInt(17) to bigInt(13),
      bigInt(12) to bigInt(18),
      bigInt(35) to bigInt(49),
      bigInt(101) to bigInt(103)
    ).forEach { (a, b) -> case(a, b) }

    // Large common factors
    listOf(
      TWO.pow(10) to TWO.pow(15),
      TWO.pow(63) to TWO.pow(64),
      TWO.pow(100) to TWO.pow(90),
      bigInt(3).pow(20) to bigInt(3).pow(25),
      TWO.pow(30).times(bigInt(3).pow(20)) to
        TWO.pow(25).times(bigInt(3).pow(15)),
      bigInt(7).pow(20).times(bigInt(11).pow(15)) to
        bigInt(7).pow(15).times(bigInt(11).pow(10)),
    ).forEach { (a, b) -> case(a, b) }

    // Coprime pairs
    listOf(
      TWO.pow(64).minus(ONE) to TWO.pow(64),
      TEN.pow(20).add(ONE) to TEN.pow(20).minus(ONE),
      TWO.pow(100).add(ONE) to bigInt(3).pow(80),
      bigInt(7919) to bigInt(7907),
      TEN.pow(30).minus(ONE) to TEN.pow(30).add(ONE),
    ).forEach { (a, b) -> case(a, b) }

    // Edge pairs
    listOf(
      TWO.pow(256).minus(ONE) to TWO.pow(128).minus(ONE),
      TEN.pow(100) to TEN.pow(50),
      TEN.pow(100).minus(ONE) to TEN.pow(100).plus(ONE)
    ).forEach { (a, b) -> case(a, b) }
  }

  private fun generateIntegerConversionTestCases() = buildList {
    fun case(value: BigInteger) = mapOf(
      "sourceWords" to value.words,
      "expectedInt8" to value.takeIf { it <= MAX_INT8 },
      "expectedUInt8" to value.takeIf { it <= MAX_UINT8 },
      "expectedInt16" to value.takeIf { it <= MAX_INT16 },
      "expectedUInt16" to value.takeIf { it <= MAX_UINT16 },
      "expectedInt32" to value.takeIf { it <= MAX_INT32 },
      "expectedUInt32" to value.takeIf { it <= MAX_UINT32 },
      "expectedInt64" to value.takeIf { it <= MAX_INT64 },
      "expectedUInt64" to value.takeIf { it <= MAX_UINT64 },
      "expectedInt128" to value.takeIf { it <= MAX_INT128 },
      "expectedUInt128" to value.takeIf { it <= MAX_UINT128 },
      "expectedInt" to value.takeIf { it <= MAX_INT64 },
      "expectedUInt" to value.takeIf { it <= MAX_UINT64 }
    )

    // Test cases
    listOf(
      ZERO,
      ONE,
      MAX_INT8,
      MAX_UINT8,
      MAX_INT16,
      MAX_UINT16,
      MAX_INT32,
      MAX_UINT32,
      MAX_INT64,
      MAX_UINT64,
      MAX_INT128,
      MAX_UINT128,
      ONE.shiftLeft(128)
    ).forEach { add(case(it)) }
  }

  private fun generateTwosComplementInitTestCases() = buildList {
    fun case(value: BigInteger) {
      // For two's complement representation
      val tcWords = if (value >= ZERO) {
        // For positive numbers, use unsigned intToWords and ensure MSB is 0
        val words = value.words
        if (words.isNotEmpty() && words.last().shr(63) == 1UL) {
          words + ZERO  // Add an extra word with MSB=0
        } else {
          words
        }
      } else {
        // For negative numbers, compute two's complement
        val absVal = value.abs()
        val absWords = absVal.words

        // Apply two's complement: invert all bits and add 1
        var carry = 1UL
        val tcWords = absWords.map { word ->
          val inverted = word.inv().and(ULong.MAX_VALUE)
          val sum = inverted + carry
          carry = if (sum > ULong.MAX_VALUE) 1UL else 0UL
          sum.and(ULong.MAX_VALUE)
        }.toMutableList()

        // If the highest bit is set, add another word with all-bits set
        if (absWords.isEmpty() || absWords.last().shr(63) == 1UL) {
          tcWords.add(ULong.MAX_VALUE)
        }

        tcWords
      }

      // Expected results in sign-flag representation
      val expectedWords = value.words

      add(
        mapOf(
          "twosComplementWords" to tcWords,
          "expectedWords" to expectedWords
        )
      )
    }

    // Test values
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
      ONE.shiftLeft(64),
      bigInt(0x123456789ABCDEF0L),
      ONE.shiftLeft(128).subtract(ONE),
      bigInt(0x123456789ABCDEF0L)
        .shiftLeft(64)
        .add(bigInt(0x123456789ABCDEF0L)),
      ONE.negate(),
      bigInt(42).negate(),
      bigInt(0xFF).negate(),
      bigInt(0xFFFF).negate(),
      bigInt(0xFFFFFFFFL).negate(),
      bigInt(Long.MAX_VALUE).negate(),
      bigInt(Long.MIN_VALUE),
      bigInt(0x123456789ABCDEF0L).negate(),
      ONE.shiftLeft(128).subtract(ONE).negate(),
      bigInt(0x123456789ABCDEF0L)
        .shiftLeft(64)
        .add(bigInt(0x123456789ABCDEF0L))
        .negate()
    ).forEach { case(it) }
  }

  private fun generateFloatInitTestCases() = buildList {

    fun case(value: Number, precision: FloatPrecision, expected: List<ULong>) =
      mapOf(
        "floatValue" to value,
        "precision" to precision.bits,
        "expectedWords" to expected
      )
    fun case(value: Double, precision: FloatPrecision) =
      case(value, precision, value.words(precision))

    val smallExact = listOf(0.0, 1.0, 2.0, 10.0, 100.0, 1000.0)
    val float16Vals = listOf(
      1.0, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0,  // Powers of 2 (exact)
      10.0, 100.0, 1000.0, 10000.0,          // Powers of 10
      FLOAT16_INT_MAX.toDouble() - 1,        // Max exact integer - 1
      FLOAT16_INT_MAX.toDouble(),
      2049.0,                                // Max exact integer + 1 (will lose precision)
      32768.0, 65504.0                       // Exact float16 values
    )
    val float32Vals = listOf(
      1.0e5, 1.0e6, 1.0e7,                   // Powers of 10
      2.0.pow(20), 2.0.pow(24),              // Powers of 2 around exact boundary
      2.0.pow(25),
      FLOAT32_INT_MAX.toDouble() - 1,        // Max exact integer - 1
      FLOAT32_INT_MAX.toDouble(),            // Max exact integer
      16777217.0,                            // Max exact integer + 1 (will lose precision)
      1.0e30                                 // Large values within the float32 range
    )
    val float64Vals = listOf(
      1.0e38, 1.0e40, 1.0e50, 1.0e100,       // Large powers of 10
      2.0.pow(40), 2.0.pow(50),              // Powers of 2 around exact boundary
      2.0.pow(53), 2.0.pow(54),
      FLOAT64_INT_MAX.toDouble() - 1,        // Max exact integer - 1
      FLOAT64_INT_MAX.toDouble(),            // Max exact integer
      BigDecimal("9007199254740993.0"),      // Max exact integer + 1 (will lose precision)
      1.0e200, 1.0e300                       // Very large values
    )
    val rounding = listOf(
      1.99, 2.01, 2.49, 2.5, 2.51, 2.99,    // Test different rounding patterns
      10.1, 10.5, 10.9,                     // Around 10
      100.1, 100.5, 100.9                   // Around 100
    )

    for (value in smallExact + float16Vals) {
      if (value > FLOAT16_MAX) continue
      add(case(value, FloatPrecision.Half, value.toHalfRange().words(FloatPrecision.Half)))
    }
    for (value in smallExact + float16Vals + float32Vals) {
      if (value > FLOAT32_MAX) continue
      add(case(value, FloatPrecision.Single, value.toFloatRange().words(FloatPrecision.Single)))
    }
    for (value in smallExact + float16Vals + float32Vals + float64Vals) {
      if (BigDecimal(value.toString()) > FLOAT64_MAX.toBigDecimal()) continue
      add(case(value, FloatPrecision.Double, value.toDouble().words(FloatPrecision.Double)))
    }

    add(case(FLOAT16_MAX, FloatPrecision.Half))
    add(case(FLOAT32_INT_MAX.toDouble(), FloatPrecision.Single))

    for (value in rounding) {
      for (precision in FloatPrecision.entries) {
        add(case(value, precision, truncate(value).roundToLong().toBigInteger().words))
      }
    }
  }

  private fun generateEncodingTestCases() = buildList {
    fun case(value: BigInteger) {
      add(
        mapOf(
          "words" to value.words,
          "encodedBytes" to value.unsignedBytes,
        )
      )
    }

    // Test values covering various cases
    listOf(
      ZERO,
      ONE,
      bigInt(255),
      bigInt(256),
      bigInt(0xFFFF),
      bigInt(0xFFFFFF),
      bigInt(0xFFFFFFFF),
      bigInt("FFFFFFFFFFFFFFFF"),
      bigInt("10000000000000000"),
      bigInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"),
      TEN.pow(20),
      TEN.pow(50),
      TEN.pow(100)
    ).forEach { case(it) }

    // Single byte values
    (0 ..< 256 step 32).forEach { case(bigInt(it)) }

    // Leading zero bytes should be removed
    listOf(1, 2, 4, 8).forEach { padding ->
      // Positive values with leading zeros
      listOf(1, 0xFF, 0xFFFF).forEach { value ->
        val bytes = bigInt(value.toLong()).unsignedBytes
        val paddedBytes = UByteArray(padding) { 0.toUByte() } + bytes

        add(
          mapOf(
            "words" to bigInt(value.toLong()).words,
            "encodedBytes" to bytes.toList(),
            "inputBytes" to paddedBytes.toList()
          )
        )
      }
    }

    // Word boundaries
    case((ONE shl WORD_BIT_WIDTH).minus(ONE)) // 1 word
    case((ONE shl WORD_BIT_WIDTH)) // just over 1 word
    listOf(2, 3, 4).forEach { words ->
      case((ONE shl (WORD_BIT_WIDTH * words)).minus(ONE))
    }

    // Odd number of bytes not aligned to word boundaries
    listOf(3, 5, 7, 9, 11).forEach { bytes ->
      case((ONE shl (8 * bytes)) - ONE)
    }
  }

}
