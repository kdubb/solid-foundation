package io.github.solidswift.numeric

import space.kscience.kmath.operations.DoubleField.pow
import java.math.BigDecimal
import java.math.BigDecimal.TWO
import java.math.BigDecimal.ZERO
import java.math.MathContext
import java.math.RoundingMode


class BigDecimalTestGenerator : NumericTestGenerator() {

  override fun generateTests() = buildMap {
    put("stringInitialization", generateStringInitTestCases())
    put("addition", generateAdditionTestCases())
    put("subtraction", generateSubtractionTestCases())
    put("multiplication", generateMultiplicationTestCases())
    put("division", generateDivisionTestCases())
    put("remainder", generateRemainderTestCases())
    put("integerPower", generateIntegerPowerTestCases())
    put("floatingPointPower", generateFloatingPointPowerTestCases())
    put("comparison", generateComparisonTestCases())
    put("rounding", generateRoundingTestCases())
    put("stringFormatting", generateStringFormatTestCases())
  }

  private val BigDecimal.components: Map<String, Any>
    get() {
      val sign = (signum() + 1).toULong()
      val unscaled = unscaledValue().abs()
      val scale = scale()

      return mapOf(
        "mantissaWords" to (listOf(sign) + unscaled.words),
        "scale" to scale
      )
    }

  private fun BigDecimal.remainderNear(divisor: BigDecimal): BigDecimal {
    if (divisor == ZERO) throw ArithmeticException("Division by zero")

    val quotient = this.divide(divisor, MathContext(10, RoundingMode.HALF_EVEN))
    val roundedQuotient = quotient.setScale(0, RoundingMode.HALF_EVEN)
    return this.subtract(divisor.multiply(roundedQuotient))
  }

  private fun generateStringInitTestCases() = buildList {
    fun case(input: String, expected: BigDecimal?) = mapOf(
      "input" to input,
      "expected" to expected?.components
    )

    // Small numbers
    listOf(
      "0", "1", "42", "100", "255", "256", "65535", "65536",
      "-1", "-42", "-100", "-255", "-256", "-65535", "-65536"
    ).forEach { add(case(it, it.toBigDecimal())) }

    // Decimal numbers
    listOf(
      "0.1", "0.01", "0.001", "1.1", "1.01", "1.001", "42.42",
      "-0.1", "-1.1", "-42.42"
    ).forEach { add(case(it, it.toBigDecimal())) }

    // Scientific notation
    listOf(
      "1e5", "1e-5", "1.23e5", "1.23e-5",
      "-1e5", "-1e-5", "-1.23e5", "-1.23e-5"
    ).forEach { add(case(it, it.toBigDecimal())) }

    // Large numbers
    listOf(
      "10e20", "10e50", "10e100",
      "-10e20", "-10e50", "-10e100"
    ).forEach { add(case(it, it.toBigDecimal())) }

    // Precise decimals
    listOf(
      "0.12345678901234567890", "1.12345678901234567890",
      "-0.12345678901234567890", "-1.12345678901234567890"
    ).forEach { add(case(it, it.toBigDecimal())) }

    // Bad strings
    listOf("", " ", " 123", "123 ", "1.2.3", "1..2", "1e2e3")
      .forEach { add(case(it, null)) }
  }

  private fun generateAdditionTestCases() = buildList {
    fun case(lhs: String, rhs: String) {
      val a = lhs.toBigDecimal()
      val b = rhs.toBigDecimal()
      val result = a.add(b)
      val components = result.components
      add(
        mapOf(
          "lhs" to lhs,
          "rhs" to rhs,
          "expected" to components
        )
      )
    }

    // Simple additions with small numbers
    listOf(
      "0" to "0",
      "1" to "0",
      "0" to "1",
      "1" to "1",
      "42" to "58",
      "-1" to "0",
      "0" to "-1",
      "-1" to "-1",
      "-42" to "-58",
      "1" to "-1",
      "-1" to "1",
      "100" to "-100",
      "-100" to "100"
    ).forEach { (a, b) -> case(a, b) }

    // Decimal additions
    listOf(
      "0.1" to "0.2",
      "0.01" to "0.02",
      "1.1" to "2.2",
      "-1.1" to "2.2",
      "1.1" to "-2.2",
      "-1.1" to "-2.2",
      "0.1" to "0.01",
      "0.001" to "0.0001",
      "1.234" to "5.678",
      "-1.234" to "5.678",
      "1.234" to "-5.678",
      "-1.234" to "-5.678"
    ).forEach { (a, b) -> case(a, b) }

    // Scientific notation
    listOf(
      "1e2" to "2e2",
      "1e-2" to "2e-2",
      "1.5e2" to "2.5e2",
      "1.5e-2" to "2.5e-2",
      "1e2" to "1e-2",
      "1e-2" to "1e2",
      "-1e2" to "2e2",
      "1e2" to "-2e2",
      "-1e2" to "-2e2"
    ).forEach { (a, b) -> case(a, b) }

    // Large numbers
    listOf(
      "1e20" to "2e20",
      "1e-20" to "2e-20",
      "1e20" to "1e-20",
      "-1e20" to "2e20",
      "1e20" to "-2e20",
      "-1e20" to "-2e20",
      "1e50" to "1e50",
      "-1e50" to "-1e50"
    ).forEach { (a, b) -> case(a, b) }
  }

  private fun generateSubtractionTestCases() = buildList {
    fun case(lhs: String, rhs: String) {
      val a = lhs.toBigDecimal()
      val b = rhs.toBigDecimal()
      val result = a.subtract(b)
      val components = result.components
      add(
        mapOf(
          "lhs" to lhs,
          "rhs" to rhs,
          "expected" to components
        )
      )
    }

    // Simple subtractions with small numbers
    listOf(
      "0" to "0",
      "1" to "0",
      "0" to "1",
      "1" to "1",
      "100" to "42",
      "42" to "100",
      "-1" to "0",
      "0" to "-1",
      "-1" to "-1",
      "-100" to "-42",
      "-42" to "-100",
      "1" to "-1",
      "-1" to "1"
    ).forEach { (a, b) -> case(a, b) }

    // Decimal subtractions
    listOf(
      "0.3" to "0.1",
      "0.1" to "0.3",
      "0.03" to "0.01",
      "0.01" to "0.03",
      "3.3" to "1.1",
      "1.1" to "3.3",
      "-1.1" to "2.2",
      "1.1" to "-2.2",
      "-1.1" to "-2.2",
      "-2.2" to "-1.1",
      "0.1" to "0.01",
      "0.01" to "0.1",
      "0.001" to "0.0001",
      "0.0001" to "0.001",
      "1.234" to "5.678",
      "5.678" to "1.234",
      "-1.234" to "5.678",
      "5.678" to "-1.234",
      "1.234" to "-5.678",
      "-5.678" to "1.234",
      "-1.234" to "-5.678",
      "-5.678" to "-1.234"
    ).forEach { (a, b) -> case(a, b) }

    // Scientific notation
    listOf(
      "3e2" to "1e2",
      "1e2" to "3e2",
      "3e-2" to "1e-2",
      "1e-2" to "3e-2",
      "3.5e2" to "1.5e2",
      "1.5e2" to "3.5e2",
      "3.5e-2" to "1.5e-2",
      "1.5e-2" to "3.5e-2",
      "1e2" to "1e-2",
      "1e-2" to "1e2",
      "-1e2" to "2e2",
      "2e2" to "-1e2",
      "1e2" to "-2e2",
      "-2e2" to "1e2",
      "-1e2" to "-2e2",
      "-2e2" to "-1e2"
    ).forEach { (a, b) -> case(a, b) }

    // Large numbers
    listOf(
      "3e20" to "1e20",
      "1e20" to "3e20",
      "3e-20" to "1e-20",
      "1e-20" to "3e-20",
      "1e20" to "1e-20",
      "1e-20" to "1e20",
      "-1e20" to "2e20",
      "2e20" to "-1e20",
      "1e20" to "-2e20",
      "-2e20" to "1e20",
      "-1e20" to "-2e20",
      "-2e20" to "-1e20",
      "1e50" to "1e50",
      "-1e50" to "-1e50"
    ).forEach { (a, b) -> case(a, b) }
  }

  private fun generateMultiplicationTestCases() = buildList {
    fun case(lhs: String, rhs: String) {
      val a = lhs.toBigDecimal()
      val b = rhs.toBigDecimal()
      val result = a.multiply(b)
      val components = result.components
      add(
        mapOf(
          "lhs" to lhs,
          "rhs" to rhs,
          "expected" to components
        )
      )
    }

    // Simple multiplications with small numbers
    listOf(
      "0" to "0",
      "1" to "0",
      "0" to "1",
      "1" to "1",
      "2" to "3",
      "42" to "58",
      "-1" to "0",
      "0" to "-1",
      "-1" to "-1",
      "-2" to "3",
      "2" to "-3",
      "-2" to "-3",
      "-42" to "58",
      "42" to "-58",
      "-42" to "-58"
    ).forEach { (a, b) -> case(a, b) }

    // Decimal multiplications
    listOf(
      "0.1" to "0.2",
      "0.01" to "0.02",
      "1.1" to "2.2",
      "-1.1" to "2.2",
      "1.1" to "-2.2",
      "-1.1" to "-2.2",
      "0.5" to "0.5",
      "0.25" to "4",
      "1.234" to "5.678",
      "-1.234" to "5.678",
      "1.234" to "-5.678",
      "-1.234" to "-5.678"
    ).forEach { (a, b) -> case(a, b) }

    // Scientific notation
    listOf(
      "1e2" to "2e2",
      "1e-2" to "2e-2",
      "1.5e2" to "2.5e2",
      "1.5e-2" to "2.5e-2",
      "1e2" to "1e-2",
      "1e-2" to "1e2",
      "-1e2" to "2e2",
      "1e2" to "-2e2",
      "-1e2" to "-2e2"
    ).forEach { (a, b) -> case(a, b) }

    // Large numbers
    listOf(
      "1e10" to "2e10",
      "1e-10" to "2e-10",
      "1e10" to "1e-10",
      "-1e10" to "2e10",
      "1e10" to "-2e10",
      "-1e10" to "-2e10",
      "1e25" to "1e25",
      "-1e25" to "-1e25"
    ).forEach { (a, b) -> case(a, b) }
  }

  private fun generateDivisionTestCases() = buildList {
    fun case(lhs: String, rhs: String) {
      val a = lhs.toBigDecimal()
      val b = rhs.toBigDecimal()
      if (b != ZERO) {
        try {
          val result = a.divide(b, MathContext(10, RoundingMode.HALF_EVEN))
          val components = result.components
          add(
            mapOf(
              "lhs" to lhs,
              "rhs" to rhs,
              "expected" to components
            )
          )
        } catch (e: ArithmeticException) {
          verbose("Error generating division test case: $e")
        }
      }
    }

    // Simple divisions with small numbers
    listOf(
      "0" to "1",
      "1" to "1",
      "2" to "1",
      "4" to "2",
      "100" to "4",
      "-1" to "1",
      "-4" to "2",
      "-100" to "4",
      "1" to "-1",
      "4" to "-2",
      "100" to "-4",
      "-1" to "-1",
      "-4" to "-2",
      "-100" to "-4"
    ).forEach { (a, b) -> case(a, b) }

    // Decimal divisions
    listOf(
      "0.1" to "0.2",
      "0.01" to "0.02",
      "1.1" to "2.2",
      "-1.1" to "2.2",
      "1.1" to "-2.2",
      "-1.1" to "-2.2",
      "1" to "3",
      "1" to "0.3",
      "0.1" to "0.3",
      "1.234" to "5.678",
      "-1.234" to "5.678",
      "1.234" to "-5.678",
      "-1.234" to "-5.678"
    ).forEach { (a, b) -> case(a, b) }

    // Scientific notation
    listOf(
      "1e2" to "2e2",
      "1e-2" to "2e-2",
      "1.5e2" to "2.5e2",
      "1.5e-2" to "2.5e-2",
      "1e2" to "1e-2",
      "1e-2" to "1e2",
      "-1e2" to "2e2",
      "1e2" to "-2e2",
      "-1e2" to "-2e2"
    ).forEach { (a, b) -> case(a, b) }

    // Large numbers
    listOf(
      "1e20" to "2e10",
      "1e-20" to "2e-10",
      "1e20" to "1e-10",
      "-1e20" to "2e10",
      "1e20" to "-2e10",
      "-1e20" to "-2e10"
    ).forEach { (a, b) -> case(a, b) }
  }

  private fun generateRemainderTestCases() = buildList {
    fun case(lhs: String, rhs: String) {
      val a = lhs.toBigDecimal()
      val b = rhs.toBigDecimal()
      if (b != ZERO) {
        try {
          val remainderResult = a.remainderNear(b)
          val truncatedRemainderResult = a.remainder(b)
          val components = remainderResult.components
          val truncatedComponents = truncatedRemainderResult.components
          add(
            mapOf(
              "lhs" to lhs,
              "rhs" to rhs,
              "expected" to components,
              "expectedTruncating" to truncatedComponents
            )
          )
        } catch (e: ArithmeticException) {
          verbose("Error generating remainder test case: $e")
        }
      }
    }

    // Simple remainders with small numbers
    listOf(
      "10" to "3",
      "10.5" to "3",
      "10" to "3.5",
      "10.5" to "3.5",
      "-10" to "3",
      "10" to "-3",
      "-10" to "-3",
      "-10.5" to "3",
      "10.5" to "-3",
      "-10.5" to "-3",
      "3" to "10"
    ).forEach { (a, b) -> case(a, b) }

    // Various scales
    listOf(
      "10.123" to "3.45",
      "10.123" to "0.45",
      "10.123" to "0.0045",
      "1234.5678" to "33.22",
      "-1234.5678" to "33.22",
      "1234.5678" to "-33.22",
      "-1234.5678" to "-33.22"
    ).forEach { (a, b) -> case(a, b) }

    // Scientific notation
    listOf(
      "1.23e5" to "4.56e4",
      "1.23e-5" to "4.56e-6",
      "-1.23e5" to "4.56e4",
      "1.23e5" to "-4.56e4",
      "-1.23e5" to "-4.56e4"
    ).forEach { (a, b) -> case(a, b) }
  }

  private fun generateIntegerPowerTestCases() = buildList {
    fun case(base: String, exponent: Int) {
      val b = base.toBigDecimal()
      try {
        val result = b.pow(exponent, MathContext(5, RoundingMode.HALF_EVEN))
        val components = result.components
        add(
          mapOf(
            "base" to base,
            "exponent" to exponent,
            "expected" to components
          )
        )
      } catch (e: ArithmeticException) {
        verbose("Error generating integer power test case: $e")
      }
    }

    // Base cases
    val bases = listOf(
      "0", "1", "2", "10", "0.1", "0.5", "1.5",
      "-1", "-2", "-0.5", "-1.5"
    )

    // Exponents
    val exponents = listOf(0, 1, 2, 3, 10, -1, -2, -3, -10)

    for (base in bases) {
      for (exponent in exponents) {
        // Skip IEEE 754 indeterminate forms
        if (base == "0" && exponent == 0) continue
        if (base == "0" && exponent < 0) continue
        if (base.startsWith("-") && exponent % 2 == 0 && base.contains(".")) continue
        case(base, exponent)
      }
    }
  }

  private fun generateFloatingPointPowerTestCases() = buildList {
    fun case(base: BigDecimal, exponent: BigDecimal) {
      try {
        val result = base.toDouble().pow(exponent).toBigDecimal().stripTrailingZeros()
        val components = result.round(MathContext(5, RoundingMode.HALF_EVEN)).components
        add(
          mapOf(
            "base" to base.toString(),
            "exponent" to exponent.toString(),
            "expected" to components
          )
        )
      } catch (e: ArithmeticException) {
        verbose("Error generating floating point power test case (base=$base, exponent=$exponent): $e")
      }
    }

    // Base cases
    val bases = listOf(
      "0", "1", "2", "0.1", "0.5", "1.5",
      "-1", "-2", "-0.5", "-1.5"
    )

    // Exponents
    val exponents = listOf(
      "0", "0.5", "1", "1.5", "2", "2.5", "3", "3.14159",
      "-0.5", "-1", "-1.5", "-2", "-2.5", "-3", "-3.14159"
    )

    for (base in bases) {
      for (exponent in exponents) {
        val bdExp = exponent.toBigDecimal()
        val bdBase = base.toBigDecimal()
        // Skip IEEE 754 indeterminate forms
        if (bdBase.compareTo(ZERO) == 0 && bdExp.compareTo(ZERO) == 0) continue
        if (bdBase.compareTo(ZERO) == 0 && bdExp.signum() == -1) continue
        if (bdBase.signum() == -1 && exponent.contains(".")) continue
        if (bdBase.signum() == -1 && bdExp % TWO == ZERO && base.contains(".")) continue
        case(bdBase, bdExp)
      }
    }
  }

  private fun generateComparisonTestCases() = buildList {
    fun case(lhs: String, rhs: String) {
      val a = lhs.toBigDecimal()
      val b = rhs.toBigDecimal()
      add(
        mapOf(
          "lhs" to lhs,
          "rhs" to rhs,
          "expectedEq" to (a.compareTo(b) == 0),
          "expectedLt" to (a < b),
          "expectedLtEq" to (a <= b),
          "expectedGt" to (a > b),
          "expectedGtEq" to (a >= b)
        )
      )
    }

    // Equal values with different representations
    listOf(
      "1" to "1.0",
      "1" to "1.00",
      "1.0" to "1.00",
      "1e2" to "100",
      "1e2" to "100.0",
      "0.1e1" to "1",
      "0.01e2" to "1",
      "1.000" to "1",
      "-1" to "-1.0",
      "-1e2" to "-100"
    ).forEach { (a, b) -> case(a, b) }

    // Unequal pairs
    listOf(
      "1" to "2",
      "1.1" to "1.2",
      "1.01" to "1.02",
      "1" to "0.999",
      "1" to "1.001",
      "1e2" to "101",
      "1" to "-1",
      "-1" to "-2",
      "-1.1" to "-1.2",
      "-1.2" to "-1.1"
    ).forEach { (a, b) -> case(a, b) }
  }

  private fun generateRoundingTestCases() = buildList {
    fun case(value: String, scale: Int, mode: RoundingMode) {
      val v = value.toBigDecimal()
      try {
        val rounded = v.setScale(scale, mode)
        val components = rounded.components
        add(
          mapOf(
            "value" to value,
            "scale" to scale,
            "mode" to mode.swiftName,
            "expected" to components
          )
        )
      } catch (e: ArithmeticException) {
        verbose("Error generating rounding test case: $e")
      }
    }

    // Values to test rounding on
    val values = listOf(
      "1.234", "1.235", "1.236", "1.245", "1.250", "1.251",
      "1.4", "1.5", "1.6",
      "-1.234", "-1.235", "-1.236", "-1.245", "-1.250", "-1.251",
      "-1.4", "-1.5", "-1.6"
    )

    // Places to round to
    val places = listOf(0, 1, 2)

    // Rounding modes
    val modes = listOf(
      RoundingMode.DOWN,      // towardZero
      RoundingMode.UP,        // up
      RoundingMode.FLOOR,     // down
      RoundingMode.HALF_EVEN, // toNearestOrEven
      RoundingMode.HALF_UP    // toNearestOrAwayFromZero
    )

    for (value in values) {
      for (place in places) {
        for (mode in modes) {
          case(value, place, mode)
        }
      }
    }
  }

  private fun generateStringFormatTestCases() = buildList {
    fun case(value: String) {
      val v = value.toBigDecimal()
      add(
        mapOf(
          "value" to value,
          "expectedString" to v.toString(),
          "expectedNormalizedString" to v.stripTrailingZeros().toString(),
          "expectedScientificString" to v.toEngineeringString()
        )
      )
    }

    // Values to test string formatting
    listOf(
      "0", "1", "123",
      "0.1", "0.01", "0.001",
      "1.1", "1.01", "1.001",
      "1.234", "123.456",
      "0.0", "1.0", "1.00",
      "123.0", "123.00",
      "-1", "-0.1", "-1.1",
      "-123.456",
      "1e5", "1e-5",
      "1.23e5", "1.23e-5",
      "-1e5", "-1e-5"
    ).forEach { case(it) }
  }

  val RoundingMode.swiftName: String
    get() = when (this) {
      RoundingMode.UP -> "up"
      RoundingMode.DOWN -> "towardZero"
      RoundingMode.CEILING -> "up"
      RoundingMode.FLOOR -> "down"
      RoundingMode.HALF_UP -> "toNearestOrAwayFromZero"
      RoundingMode.HALF_DOWN -> "toNearestOrTowardZero"
      RoundingMode.HALF_EVEN -> "toNearestOrEven"
      RoundingMode.UNNECESSARY -> "towardZero"
    }
}
