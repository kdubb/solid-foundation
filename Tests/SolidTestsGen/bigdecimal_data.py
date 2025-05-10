import decimal
from decimal import Decimal
from shared import *

# Set precision high enough for all test cases
decimal.getcontext().prec = 1000

def decimal_to_components(dec):
    """
    Convert Decimal to a dictionary of (value, scale)
    `value` is an array of [sign-flag] + [magnitude-words]
    `scale` is an integer
    """
    sign, digits, exponent = dec.as_tuple()

    # Skip NaN and infinity values - these have special exponent markers
    if exponent == 'F' or exponent == 'n' or exponent == 'N':
        return None

    # Convert the digits tuple to an integer
    value = 0
    for digit in digits:
        value = value * 10 + digit

    if sign == 0:
      sign_flag = 1 if value == 0 else 2
    else:
      sign_flag = 0

    value_words = [sign_flag] + int_to_words(value)
    scale = -exponent  # Scale is negative of exponent, ensure it's an integer

    return {
        "mantissaWords": value_words,
        "scale": scale
    }

def generate_string_init_tests():
    """Generate test cases for BigDecimal initialization from string."""
    tests = []

    # Small numbers
    for i in ["0", "1", "42", "100", "255", "256", "65535", "65536"]:
        try:
            dec = Decimal(i)
            components = decimal_to_components(dec)
            if components is not None:
                tests.append({
                    "input": i,
                    "expected": components
                })
        except (decimal.InvalidOperation, decimal.DecimalException):
            pass

    # Negative numbers
    for i in ["-1", "-42", "-100", "-255", "-256", "-65535", "-65536"]:
        try:
            dec = Decimal(i)
            components = decimal_to_components(dec)
            if components is not None:
                tests.append({
                    "input": i,
                    "expected": components
                })
        except (decimal.InvalidOperation, decimal.DecimalException):
            pass

    # Decimal numbers
    for i in ["0.1", "0.01", "0.001", "1.1", "1.01", "1.001", "42.42", "-0.1", "-1.1", "-42.42"]:
        try:
            dec = Decimal(i)
            components = decimal_to_components(dec)
            if components is not None:
                tests.append({
                    "input": i,
                    "expected": components
                })
        except (decimal.InvalidOperation, decimal.DecimalException):
            pass

    # Scientific notation
    for i in ["1e5", "1e-5", "1.23e5", "1.23e-5", "-1e5", "-1e-5", "-1.23e5", "-1.23e-5"]:
        try:
            dec = Decimal(i)
            components = decimal_to_components(dec)
            if components is not None:
                tests.append({
                    "input": i,
                    "expected": components
                })
        except (decimal.InvalidOperation, decimal.DecimalException):
            pass

    # Large numbers
    for i in ["10e20", "10e50", "10e100", "-10e20", "-10e50", "-10e100"]:
        try:
            dec = Decimal(i)
            components = decimal_to_components(dec)
            if components is not None:
                tests.append({
                    "input": i,
                    "expected": components
                })
        except (decimal.InvalidOperation, decimal.DecimalException):
            pass

    # Precise decimals
    for i in ["0.12345678901234567890", "1.12345678901234567890", "-0.12345678901234567890", "-1.12345678901234567890"]:
        try:
            dec = Decimal(i)
            components = decimal_to_components(dec)
            if components is not None:
                tests.append({
                    "input": i,
                    "expected": components
                })
        except (decimal.InvalidOperation, decimal.DecimalException):
            pass

    # Bad strings
    tests.append({
        "input": "",
        "expected": None
    })
    tests.append({
        "input": " ",
        "expected": None
    })
    tests.append({
        "input": " 123",
        "expected": None
    })
    tests.append({
        "input": "123 ",
        "expected": None
    })
    tests.append({
        "input": "1.2.3",
        "expected": None
    })
    tests.append({
        "input": "1..2",
        "expected": None
    })
    tests.append({
        "input": "1e2e3",
        "expected": None
    })

    return tests

def generate_addition_tests():
    """Generate test cases for BigDecimal addition."""
    tests = []

    # Simple additions with small numbers
    pairs = [
        ("0", "0"),
        ("1", "0"),
        ("0", "1"),
        ("1", "1"),
        ("42", "58"),
        ("-1", "0"),
        ("0", "-1"),
        ("-1", "-1"),
        ("-42", "-58"),
        ("1", "-1"),
        ("-1", "1"),
        ("100", "-100"),
        ("-100", "100")
    ]

    # Decimal additions
    decimal_pairs = [
        ("0.1", "0.2"),
        ("0.01", "0.02"),
        ("1.1", "2.2"),
        ("-1.1", "2.2"),
        ("1.1", "-2.2"),
        ("-1.1", "-2.2"),
        ("0.1", "0.01"),
        ("0.001", "0.0001"),
        ("1.234", "5.678"),
        ("-1.234", "5.678"),
        ("1.234", "-5.678"),
        ("-1.234", "-5.678")
    ]

    # Scientific notation
    sci_pairs = [
        ("1e2", "2e2"),
        ("1e-2", "2e-2"),
        ("1.5e2", "2.5e2"),
        ("1.5e-2", "2.5e-2"),
        ("1e2", "1e-2"),
        ("1e-2", "1e2"),
        ("-1e2", "2e2"),
        ("1e2", "-2e2"),
        ("-1e2", "-2e2")
    ]

    # Large numbers
    large_pairs = [
        ("1e20", "2e20"),
        ("1e-20", "2e-20"),
        ("1e20", "1e-20"),
        ("-1e20", "2e20"),
        ("1e20", "-2e20"),
        ("-1e20", "-2e20"),
        ("1e50", "1e50"),
        ("-1e50", "-1e50")
    ]

    # Process all pairs
    for a, b in pairs + decimal_pairs + sci_pairs + large_pairs:
        dec_a = Decimal(a)
        dec_b = Decimal(b)
        result = dec_a + dec_b

        # Only add if result can be properly converted
        components = decimal_to_components(result)
        if components is not None:
            tests.append({
                "lhs": a,
                "rhs": b,
                "expected": components
            })

    return tests

def generate_subtraction_tests():
    """Generate test cases for BigDecimal subtraction."""
    tests = []

    # Simple subtractions with small numbers
    pairs = [
        ("0", "0"),
        ("1", "0"),
        ("0", "1"),
        ("1", "1"),
        ("100", "42"),
        ("42", "100"),
        ("-1", "0"),
        ("0", "-1"),
        ("-1", "-1"),
        ("-100", "-42"),
        ("-42", "-100"),
        ("1", "-1"),
        ("-1", "1")
    ]

    # Decimal subtractions
    decimal_pairs = [
        ("0.3", "0.1"),
        ("0.1", "0.3"),
        ("0.03", "0.01"),
        ("0.01", "0.03"),
        ("3.3", "1.1"),
        ("1.1", "3.3"),
        ("-1.1", "2.2"),
        ("1.1", "-2.2"),
        ("-1.1", "-2.2"),
        ("-2.2", "-1.1"),
        ("0.1", "0.01"),
        ("0.01", "0.1"),
        ("0.001", "0.0001"),
        ("0.0001", "0.001"),
        ("1.234", "5.678"),
        ("5.678", "1.234"),
        ("-1.234", "5.678"),
        ("5.678", "-1.234"),
        ("1.234", "-5.678"),
        ("-5.678", "1.234"),
        ("-1.234", "-5.678"),
        ("-5.678", "-1.234")
    ]

    # Scientific notation
    sci_pairs = [
        ("3e2", "1e2"),
        ("1e2", "3e2"),
        ("3e-2", "1e-2"),
        ("1e-2", "3e-2"),
        ("3.5e2", "1.5e2"),
        ("1.5e2", "3.5e2"),
        ("3.5e-2", "1.5e-2"),
        ("1.5e-2", "3.5e-2"),
        ("1e2", "1e-2"),
        ("1e-2", "1e2"),
        ("-1e2", "2e2"),
        ("2e2", "-1e2"),
        ("1e2", "-2e2"),
        ("-2e2", "1e2"),
        ("-1e2", "-2e2"),
        ("-2e2", "-1e2")
    ]

    # Large numbers
    large_pairs = [
        ("3e20", "1e20"),
        ("1e20", "3e20"),
        ("3e-20", "1e-20"),
        ("1e-20", "3e-20"),
        ("1e20", "1e-20"),
        ("1e-20", "1e20"),
        ("-1e20", "2e20"),
        ("2e20", "-1e20"),
        ("1e20", "-2e20"),
        ("-2e20", "1e20"),
        ("-1e20", "-2e20"),
        ("-2e20", "-1e20"),
        ("1e50", "1e50"),
        ("-1e50", "-1e50")
    ]

    # Process all pairs
    for a, b in pairs + decimal_pairs + sci_pairs + large_pairs:
        dec_a = Decimal(a)
        dec_b = Decimal(b)
        result = dec_a - dec_b

        # Only add if result can be properly converted
        components = decimal_to_components(result)
        if components is not None:
            tests.append({
                "lhs": a,
                "rhs": b,
                "expected": components
            })

    return tests

def generate_multiplication_tests():
    """Generate test cases for BigDecimal multiplication."""
    tests = []

    # Simple multiplications with small numbers
    pairs = [
        ("0", "0"),
        ("1", "0"),
        ("0", "1"),
        ("1", "1"),
        ("2", "3"),
        ("42", "58"),
        ("-1", "0"),
        ("0", "-1"),
        ("-1", "-1"),
        ("-2", "3"),
        ("2", "-3"),
        ("-2", "-3"),
        ("-42", "58"),
        ("42", "-58"),
        ("-42", "-58")
    ]

    # Decimal multiplications
    decimal_pairs = [
        ("0.1", "0.2"),
        ("0.01", "0.02"),
        ("1.1", "2.2"),
        ("-1.1", "2.2"),
        ("1.1", "-2.2"),
        ("-1.1", "-2.2"),
        ("0.5", "0.5"),
        ("0.25", "4"),
        ("1.234", "5.678"),
        ("-1.234", "5.678"),
        ("1.234", "-5.678"),
        ("-1.234", "-5.678")
    ]

    # Scientific notation
    sci_pairs = [
        ("1e2", "2e2"),
        ("1e-2", "2e-2"),
        ("1.5e2", "2.5e2"),
        ("1.5e-2", "2.5e-2"),
        ("1e2", "1e-2"),
        ("1e-2", "1e2"),
        ("-1e2", "2e2"),
        ("1e2", "-2e2"),
        ("-1e2", "-2e2")
    ]

    # Large numbers
    large_pairs = [
        ("1e10", "2e10"),
        ("1e-10", "2e-10"),
        ("1e10", "1e-10"),
        ("-1e10", "2e10"),
        ("1e10", "-2e10"),
        ("-1e10", "-2e10"),
        ("1e25", "1e25"),
        ("-1e25", "-1e25")
    ]

    # Process all pairs
    for a, b in pairs + decimal_pairs + sci_pairs + large_pairs:
        dec_a = Decimal(a)
        dec_b = Decimal(b)
        result = dec_a * dec_b

        # Only add if result can be properly converted
        components = decimal_to_components(result)
        if components is not None:
            tests.append({
                "lhs": a,
                "rhs": b,
                "expected": components
            })

    return tests

def generate_division_tests():
    """Generate test cases for BigDecimal division."""
    tests = []

    # Simple divisions with small numbers
    pairs = [
        ("0", "1"),
        ("1", "1"),
        ("2", "1"),
        ("4", "2"),
        ("100", "4"),
        ("-1", "1"),
        ("-4", "2"),
        ("-100", "4"),
        ("1", "-1"),
        ("4", "-2"),
        ("100", "-4"),
        ("-1", "-1"),
        ("-4", "-2"),
        ("-100", "-4")
    ]

    # Decimal divisions
    decimal_pairs = [
        ("0.1", "0.2"),
        ("0.01", "0.02"),
        ("1.1", "2.2"),
        ("-1.1", "2.2"),
        ("1.1", "-2.2"),
        ("-1.1", "-2.2"),
        ("1", "3"),
        ("1", "0.3"),
        ("0.1", "0.3"),
        ("1.234", "5.678"),
        ("-1.234", "5.678"),
        ("1.234", "-5.678"),
        ("-1.234", "-5.678")
    ]

    # Scientific notation
    sci_pairs = [
        ("1e2", "2e2"),
        ("1e-2", "2e-2"),
        ("1.5e2", "2.5e2"),
        ("1.5e-2", "2.5e-2"),
        ("1e2", "1e-2"),
        ("1e-2", "1e2"),
        ("-1e2", "2e2"),
        ("1e2", "-2e2"),
        ("-1e2", "-2e2")
    ]

    # Large numbers
    large_pairs = [
        ("1e20", "2e10"),
        ("1e-20", "2e-10"),
        ("1e20", "1e-10"),
        ("-1e20", "2e10"),
        ("1e20", "-2e10"),
        ("-1e20", "-2e10")
    ]

    # Process all pairs
    for a, b in pairs + decimal_pairs + sci_pairs + large_pairs:
        dec_a = Decimal(a)
        dec_b = Decimal(b)

        try:
            with decimal.localcontext() as ctx:
              # mimic BigDecimal's division behavior
              exp = max(max(dec_a.as_tuple().exponent, dec_b.as_tuple().exponent), 2) * 5
              ctx.prec = exp
              result = (dec_a / dec_b)

            # Only add if result can be properly converted
            components = decimal_to_components(result)
            if components is not None:
                tests.append({
                    "lhs": a,
                    "rhs": b,
                    "expected": components
                })
        except (decimal.InvalidOperation, decimal.DivisionByZero, decimal.DivisionImpossible):
            # Skip cases that would cause errors (like division by zero)
            pass

    return tests

def generate_remainder_tests():
    """Generate test cases for BigDecimal remainder."""
    tests = []

    # Simple remainders with small numbers
    pairs = [
        ("10", "3"),
        ("10.5", "3"),
        ("10", "3.5"),
        ("10.5", "3.5"),
        ("-10", "3"),
        ("10", "-3"),
        ("-10", "-3"),
        ("-10.5", "3"),
        ("10.5", "-3"),
        ("-10.5", "-3"),
        ("3", "10"),
    ]

    # Various scales
    scale_pairs = [
        ("10.123", "3.45"),
        ("10.123", "0.45"),
        ("10.123", "0.0045"),
        ("1234.5678", "33.22"),
        ("-1234.5678", "33.22"),
        ("1234.5678", "-33.22"),
        ("-1234.5678", "-33.22")
    ]

    # Scientific notation
    sci_pairs = [
        ("1.23e5", "4.56e4"),
        ("1.23e-5", "4.56e-6"),
        ("-1.23e5", "4.56e4"),
        ("1.23e5", "-4.56e4"),
        ("-1.23e5", "-4.56e4")
    ]

    # Process all pairs
    for a, b in pairs + scale_pairs + sci_pairs:
        dec_a = Decimal(a)
        dec_b = Decimal(b)

        # Calculate remainder using remainder_near operation
        remainderResult = dec_a.remainder_near(dec_b)

        # Calculate truncated remainder using modulo operation
        truncatedRemainderResult = dec_a % dec_b

        tests.append({
            "lhs": a,
            "rhs": b,
            "expected": decimal_to_components(remainderResult),
            "expectedTruncating": decimal_to_components(truncatedRemainderResult)
        })

    return tests

def generate_integer_power_tests():
    """Generate test cases for BigDecimal integer power."""
    tests = []

    # Base cases
    bases = ["0", "1", "2", "10", "0.1", "0.5", "1.5", "-1", "-2", "-0.5", "-1.5"]

    # Exponents - for BigDecimal, only integer exponents should be supported
    exponents = [0, 1, 2, 3, 10, -1, -2, -3, -10]

    for base in bases:
        for exponent in exponents:
            dec_base = Decimal(base)

            # Skip negative bases with even exponents (would produce complex numbers for decimal fractions)
            if dec_base < 0 and (exponent % 2 == 0) and '.' in base:
                continue

            # Calculate power
            try:
                with decimal.localcontext() as ctx:
                  ctx.prec = 5
                  result = dec_base ** exponent

                # Only add if result can be properly converted
                components = decimal_to_components(result)
                if components is not None:
                    tests.append({
                        "base": str(base),
                        "exponent": exponent,
                        "expected": components
                    })
            except (decimal.InvalidOperation, decimal.DivisionByZero):
                # Skip cases that would cause errors (like 0^-1)
                pass

    return tests

def generate_floating_point_power_tests():
    """Generate test cases for BigDecimal floating-point power."""
    tests = []

    # Base cases
    bases = ["0", "1", "2", "0.1", "0.5", "1.5", "-1", "-2", "-0.5", "-1.5"]

    # Exponents - for BigDecimal, only integer exponents should be supported
    exponents = ["0", "0.5", "1", "1.5", "2", "2.5", "3", "3.14159", "-0.5", "-1", "-1.5", "-2", "-2.5", "-3", "-3.14159"]

    for base in bases:
        for exponent in exponents:
            dec_exponent = Decimal(exponent)
            dec_base = Decimal(base)

            # Skip negative bases with even exponents (would produce complex numbers for decimal fractions)
            if dec_base < 0 and (dec_exponent % 2 == 0) and '.' in base:
                continue

            # Calculate power
            try:
                with decimal.localcontext() as ctx:
                  ctx.prec = 5
                  result = dec_base ** dec_exponent

                # Only add if result can be properly converted
                components = decimal_to_components(result)
                if components is not None:
                    tests.append({
                        "base": str(base),
                        "exponent": exponent,
                        "expected": components
                    })
            except (decimal.InvalidOperation, decimal.DivisionByZero):
                # Skip cases that would cause errors (like 0^-1)
                pass

    return tests

def generate_comparison_tests():
    """Generate test cases for BigDecimal comparison."""
    tests = []

    # Equal values with different representations
    equal_pairs = [
        ("1", "1.0"),
        ("1", "1.00"),
        ("1.0", "1.00"),
        ("1e2", "100"),
        ("1e2", "100.0"),
        ("0.1e1", "1"),
        ("0.01e2", "1"),
        ("1.000", "1"),
        ("-1", "-1.0"),
        ("-1e2", "-100")
    ]

    # Unequal pairs
    unequal_pairs = [
        ("1", "2"),
        ("1.1", "1.2"),
        ("1.01", "1.02"),
        ("1", "0.999"),
        ("1", "1.001"),
        ("1e2", "101"),
        ("1", "-1"),
        ("-1", "-2"),
        ("-1.1", "-1.2"),
        ("-1.2", "-1.1")
    ]

    # Process equal pairs
    for a, b in equal_pairs:
        dec_a = Decimal(a)
        dec_b = Decimal(b)

        # Check if both values can be converted to BigDecimal
        if decimal_to_components(dec_a) is None or decimal_to_components(dec_b) is None:
            continue

        tests.append({
            "lhs": a,
            "rhs": b,
            "expectedEq": True,
            "expectedLt": False,
            "expectedLtEq": True,
            "expectedGt": False,
            "expectedGtEq": True
        })

    # Process unequal pairs
    for a, b in unequal_pairs:
        dec_a = Decimal(a)
        dec_b = Decimal(b)

        # Check if both values can be converted to BigDecimal
        if decimal_to_components(dec_a) is None or decimal_to_components(dec_b) is None:
            continue

        tests.append({
            "lhs": a,
            "rhs": b,
            "expectedEq": False,
            "expectedLt": dec_a < dec_b,
            "expectedLtEq": dec_a <= dec_b,
            "expectedGt": dec_a > dec_b,
            "expectedGtEq": dec_a >= dec_b
        })

    return tests

def generate_rounding_tests():
    """Generate test cases for BigDecimal rounding."""
    tests = []

    # Rounding modes in Decimal module
    # ROUND_DOWN, ROUND_UP, ROUND_HALF_UP, ROUND_HALF_EVEN, etc.
    # We'll use the ones that match Swift's BigDecimal rounding modes

    # Values to test rounding on
    values = [
        "1.234",
        "1.235",
        "1.236",
        "1.245",
        "1.250",
        "1.251",
        "1.4",
        "1.5",
        "1.6",
        "-1.234",
        "-1.235",
        "-1.236",
        "-1.245",
        "-1.250",
        "-1.251",
        "-1.4",
        "-1.5",
        "-1.6"
    ]

    # Places to round to
    places = [0, 1, 2]

    # Define rounding modes mapping
    rounding_modes = {
        "towardZero": decimal.ROUND_DOWN,
        "up": decimal.ROUND_UP,
        "down": decimal.ROUND_FLOOR,
        "toNearestOrEven": decimal.ROUND_HALF_EVEN,
        "toNearestOrAwayFromZero": decimal.ROUND_HALF_UP
    }

    for value in values:
        dec_value = Decimal(value)

        # Skip if the value itself can't be converted
        if decimal_to_components(dec_value) is None:
            continue

        for place in places:
            for mode_name, mode in rounding_modes.items():
                try:
                    # Create a new context with the specified rounding mode
                    with decimal.localcontext() as ctx:
                        ctx.rounding = mode

                        # Perform rounding
                        rounded = dec_value.quantize(Decimal('0.1') ** place)

                        # Only add if result can be properly converted
                        components = decimal_to_components(rounded)
                        if components is not None:
                            tests.append({
                                "value": value,
                                "scale": place,
                                "mode": mode_name,
                                "expected": components
                            })
                except (decimal.InvalidOperation, decimal.DecimalException):
                    # Skip cases that would cause errors
                    pass

    return tests

def generate_string_format_tests():
    """Generate test cases for BigDecimal string formatting."""
    tests = []

    # Values to test string formatting
    values = [
        "0",
        "1",
        "123",
        "0.1",
        "0.01",
        "0.001",
        "1.1",
        "1.01",
        "1.001",
        "1.234",
        "123.456",
        "0.0",
        "1.0",
        "1.00",
        "123.0",
        "123.00",
        "-1",
        "-0.1",
        "-1.1",
        "-123.456",
        "1e5",
        "1e-5",
        "1.23e5",
        "1.23e-5",
        "-1e5",
        "-1e-5"
    ]

    for value in values:
        dec = Decimal(value)

        # Skip if the value can't be converted to BigDecimal
        if decimal_to_components(dec) is None:
            continue

        try:
            # Regular string representation
            regular_str = str(dec)

            # Remove trailing zeros and decimal point if possible
            normalized = dec.normalize()
            normalized_str = str(normalized)

            # Scientific notation
            scientific_str = dec.to_eng_string()

            tests.append({
                "value": value,
                "expectedString": regular_str,
                "expectedNormalizedString": normalized_str,
                "expectedScientificString": scientific_str
            })
        except (decimal.InvalidOperation, decimal.DecimalException):
            # Skip cases that cause errors
            pass

    return tests

def generate():
  """Test data for BigDecimalTests"""
  tests = {
      "stringInitialization": generate_string_init_tests(),
      "addition": generate_addition_tests(),
      "subtraction": generate_subtraction_tests(),
      "multiplication": generate_multiplication_tests(),
      "division": generate_division_tests(),
      "remainder": generate_remainder_tests(),
      "integerPower": generate_integer_power_tests(),
      "floatingPointPower": generate_floating_point_power_tests(),
      "comparison": generate_comparison_tests(),
      "rounding": generate_rounding_tests(),
      "stringFormatting": generate_string_format_tests()
  }

  return {
      "BigDecimalTestData": tests
  }
