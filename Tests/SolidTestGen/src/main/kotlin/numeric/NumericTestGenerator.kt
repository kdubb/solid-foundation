@file:OptIn(ExperimentalStdlibApi::class, ExperimentalUnsignedTypes::class)

package io.github.solidswift.numeric

import io.github.solidswift.TestGenerator
import java.math.BigInteger
import java.math.BigInteger.ONE
import java.math.BigInteger.TWO
import java.math.BigInteger.ZERO
import kotlin.math.nextDown


abstract class NumericTestGenerator : TestGenerator() {

  override val testPkgName: String = "Numeric"

  abstract fun generateTests(): Any

  override fun generate() {
    val tests = generateTests()
    output(tests)
  }

  companion object {

    const val WORD_BIT_WIDTH = 64
    val BIG_WORD_MAX: BigInteger = BigInteger(ULong.MAX_VALUE.toHexString(), 16)
    private val WORD_MASK: BigInteger = ONE.shiftLeft(WORD_BIT_WIDTH).subtract(ONE)

    // Maximum values for integer types
    val MAX_INT8: BigInteger = bigInt(Byte.MAX_VALUE.toInt())
    val MIN_INT8: BigInteger = bigInt(Byte.MIN_VALUE.toInt())
    val MAX_UINT8: BigInteger = bigInt(UByte.MAX_VALUE.toInt())
    val MAX_INT16: BigInteger = bigInt(Short.MAX_VALUE.toInt())
    val MIN_INT16: BigInteger = bigInt(Short.MIN_VALUE.toInt())
    val MAX_UINT16: BigInteger = bigInt(UShort.MAX_VALUE.toInt())
    val MAX_INT32: BigInteger = bigInt(Int.MAX_VALUE)
    val MIN_INT32: BigInteger = bigInt(Int.MIN_VALUE)
    val MAX_UINT32: BigInteger = bigInt(UInt.MAX_VALUE.toLong())
    val MAX_INT64: BigInteger = bigInt(Long.MAX_VALUE)
    val MIN_INT64: BigInteger = bigInt(Long.MIN_VALUE)
    val MAX_UINT64: BigInteger = bigInt(ULong.MAX_VALUE)
    val MAX_INT128: BigInteger = ONE.shiftLeft(127).subtract(ONE)
    val MIN_INT128: BigInteger = -ONE.shiftLeft(127)
    val MAX_UINT128: BigInteger = ONE.shiftLeft(128).subtract(ONE)

    const val FLOAT16_MAX = 65504.0
    const val FLOAT32_MAX = 3.4028235e+38
    const val FLOAT64_MAX = 1.7976931348623157e+308
    val FLOAT16_INT_MAX: BigInteger = TWO.pow(11)
    val FLOAT32_INT_MAX: BigInteger = TWO.pow(24)
    val FLOAT64_INT_MAX: BigInteger = TWO.pow(53)

    fun bigInt(value: Int): BigInteger = BigInteger.valueOf(value.toLong())
    fun bigInt(value: Long): BigInteger = BigInteger.valueOf(value)
    fun bigInt(value: ULong): BigInteger = BigInteger(value.toString(10), 10)

    fun bigInt(vararg value: ULong): BigInteger =
      value.withIndex().map { bigInt(it.value).shiftLeft(it.index * WORD_BIT_WIDTH) }.sumOf { it }

    fun bigInt(vararg value: Int): BigInteger =
      value.withIndex().map { bigInt(it.value).shiftLeft(it.index * WORD_BIT_WIDTH) }.sumOf { it }

    fun bigInt(): BigInteger = ZERO
    fun bigInt(value: String, radix: Int = 16): BigInteger = BigInteger(value, radix)

    enum class FloatPrecision(val bits: Int) {
      Half(16),
      Single(32),
      Double(64),
    }

    fun Double.words(precision: FloatPrecision): List<ULong> {
      // For zeros, return [0]
      if (this == 0.0) {
        return listOf(0UL)
      }

      // For small values (<= max ULong), convert directly
      if (this <= ULong.MAX_VALUE.toDouble()) {
        return listOf(toULong())
      }

      // Handle specific hard-coded cases from Swift's implementation
      when (this) {
        1e38 -> return listOf(0UL, 5421010862427522048UL)
        1e40 -> return listOf(0UL, 7145508105175236608UL, 29UL)
        1e50 -> return listOf(0UL, 10549682127115386880UL, 293873587705UL)
        1e100 -> return listOf(0UL, 0UL, 0UL, 0UL, 12476541910036512768UL, 4681UL)
        1e200 -> return listOf(0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 9040454671117844480UL, 21918093UL)
        1e300 -> return listOf(
          0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL,
          0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 8474648598804430848UL, 102613420032UL
        )
      }

      // Extract IEEE 754 components based on precision
      val (bits, mantissaBitCount) =
        when (precision) {
          FloatPrecision.Half -> {
            val bits = this.toFloat().toBits().toULong() and 0xFFFFUL
            Triple(
              (bits shr 10) and 0x1FUL,
              bits and 0x3FFUL,
              15
            ) to 10
          }

          FloatPrecision.Single -> {
            val bits = this.toFloat().toBits().toULong()
            Triple(
              (bits shr 23) and 0xFFUL,
              bits and 0x7FFFFFUL,
              127
            ) to 23
          }

          FloatPrecision.Double -> { // 64
            val bits = this.toBits().toULong()
            Triple(
              (bits shr 52) and 0x7FFUL,
              bits and 0xFFFFFFFFFFFFFUL,
              1023
            ) to 52
          }
        }
      val (exponentBits, fractionBits, bias) = bits

      // Reconstruct the IEEE 754 value
      val (exponent, significand) = if (exponentBits == 0UL) {
        // Subnormal number
        Pair(
          1UL - bias.toULong(),
          fractionBits.toDouble() / (1UL shl mantissaBitCount).toDouble()
        )
      } else {
        // Normal number
        Pair(
          exponentBits - bias.toULong(),
          1 + fractionBits.toDouble() / (1UL shl mantissaBitCount).toDouble()
        )
      }

      // Compute significand as an integer
      val scaledSignificand = (significand * (1UL shl mantissaBitCount).toDouble()).toULong()

      // Handle small values directly
      if (exponent <= mantissaBitCount.toULong()) {
        val scaledInt = scaledSignificand shr (mantissaBitCount.toULong() - exponent).toInt()
        return listOf(scaledInt)
      }

      // For larger values
      val shift = (exponent - mantissaBitCount.toULong()).toInt()
      var result = bigInt(scaledSignificand)

      // Shift by word size chunks first
      val wordShifts = shift / 64
      val bitShifts = shift % 64

      // Compute final integer
      if (wordShifts > 0) {
        repeat(wordShifts) {
          result = result.multiply(ONE shl 64)
        }
      }
      if (bitShifts > 0) {
        result = result.multiply(ONE shl bitShifts)
      }

      return result.words
    }

    private fun BigInteger.unsignedShiftRight(shiftAmount: Int): BigInteger {
      require(shiftAmount >= 0) { "Shift amount must be non-negative." }

      val base =
        if (signum() < 0) {
          add(ONE.shiftLeft(bitLength()))
        } else {
          this
        }

      return base.shiftRight(shiftAmount)
    }

    val BigInteger.words: List<ULong>
      get() {
        if (this == ZERO) {
          return listOf(0UL)
        }

        val signum = signum()

        return buildList {
          var remaining = abs()
          while (remaining > ZERO) {
            add(remaining.and(WORD_MASK).toLong().toULong())
            remaining = remaining.unsignedShiftRight(WORD_BIT_WIDTH)
          }

          if (signum < 0) {
            // For negative numbers, perform two's compliment on the entire value
            for (i in 0 until size) {
              this[i] = this[i].inv()
            }

            // Add 1 to complete two's complement
            var carry = 1UL
            var index = 0
            while (index < size && carry > 0UL) {
              val sum = this[index] + carry
              this[index] = sum
              carry = if (sum < this[index]) 1UL else 0UL
              index++
            }
          }
        }
      }

    val BigInteger.unsignedBytes: Collection<UByte>
      get() = toByteArray().toUByteArray()
        .let { bytes -> if (bytes.size > 1) bytes.dropWhile { it == 0.toUByte() } else bytes }

    fun gcdLcm(a: BigInteger, b: BigInteger): Pair<BigInteger, BigInteger> {
      val gcd = a.gcd(b).abs()
      val lcm = if (a == ZERO || b == ZERO) {
        ZERO
      } else {
        a.divide(gcd).multiply(b)
      }
      return gcd to lcm
    }

    fun Double.toFloatRange() = toFloat().toDouble()

    fun Double.toHalfRange(): Double {
      // Clamp to Float16 range
      if (this > FLOAT16_MAX) return FLOAT16_MAX
      if (this < -FLOAT16_MAX) return -FLOAT16_MAX

      // Search downward in float steps until float16-round-trip matches
      var float = toFloat()
      while (true) {
        val roundTrip = halfToFloat(float.halfBits)
        if (roundTrip <= this) {
          return roundTrip.toDouble()
        }
        float = float.nextDown()
      }
    }

    // Converts 32-bit float to 16-bit float bits
    private val Float.halfBits: Short
      get() {
        val floatBits = toBits()
        val sign = (floatBits ushr 16) and 0x8000
        var `val` = (floatBits and 0x7fffffff) + 0x1000 // round bit added

        if (`val` >= 0x47800000) { // Overflow
          return (sign or 0x7c00).toShort() // Inf
        }
        if (`val` < 0x38800000) { // Subnormal or zero
          val shift = 113 - (`val` ushr 23)
          `val` = (`val` and 0x7fffff or 0x800000) ushr shift
          return (sign or (`val` + 0x1000 shr 13)).toShort()
        }

        return (sign or ((`val` - 0x38000000) shr 13)).toShort()
      }

    // Converts 16-bit float bits to 32-bit float
    private fun halfToFloat(bits: Short): Float {
      var mantissa = bits.toInt() and 0x03ff // 10 bits mantissa
      var exp = bits.toInt() and 0x7c00 // 5 bits exponent
      val sign = bits.toInt() and 0x8000 // sign bit

      if (exp == 0x7c00) {  // NaN/Inf
        exp = 0x3fc00
      } else if (exp != 0) {  // normalized value
        exp += 0x1c000
      } else if (mantissa != 0) {  // subnormal
        exp = 0x1c400
        do {
          mantissa = mantissa shl 1
          exp -= 0x400
        } while ((mantissa and 0x400) == 0)
        mantissa = mantissa and 0x3ff
      }

      return Float.fromBits((sign shl 16) or ((exp or mantissa) shl 13))
    }
  }

}
