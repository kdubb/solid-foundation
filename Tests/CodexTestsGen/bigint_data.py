import math
import numpy as np
import shared
from shared import *

def int_to_words(n):
    """Convert integer to little-endian hex word array with sign flag as first word"""
    sign = np.sign(n)
    if sign == -1:
      signFlag = 0
    elif sign == 0:
      signFlag = 1
    else:
      signFlag = 2
    return [signFlag] + shared.int_to_words(abs(n))

def generate_twos_complement_init_tests():
    """Generate test cases for BigInt initializing from two's complement words."""
    test_cases = []

    test_values = [
        # Positive numbers
        0,
        1,
        42,
        0xFF,
        0xFFFF,
        0xFFFFFFFF,
        0x7FFFFFFFFFFFFFFF,  # Int64.max
        0xFFFFFFFFFFFFFFFF,  # UInt64.max
        0x1000000000000000,
        0x123456789ABCDEF0,
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,  # Large multi-word value
        0x123456789ABCDEF0123456789ABCDEF0,  # Large multi-word value
        # Negative numbers
        -1,
        -42,
        -0xFF,
        -0xFFFF,
        -0xFFFFFFFF,
        -0x7FFFFFFFFFFFFFFF,  # -Int64.max
        -0x8000000000000000,  # Int64.min
        -0xFFFFFFFFFFFFFFFF,  # -UInt64.max
        -0x123456789ABCDEF0,
        -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
        -0x123456789ABCDEF0123456789ABCDEF0,
    ]
    
    for value in test_values:
        # For two's complement representation
        tc_words = []
        if value >= 0:
            # For positive numbers, use unsigned int_to_words and ensure MSB is 0
            tc_words = shared.int_to_words(value)
            
            # Ensure most significant bit is clear (indicating positive)
            if len(tc_words) > 0 and tc_words[-1] & (1 << 63) != 0:
                tc_words.append(0)  # Add an extra word with MSB=0
        else:
            # For negative numbers, compute two's complement
            abs_val = abs(value)
            abs_words = shared.int_to_words(abs_val)
            
            # Apply two's complement: invert all bits and add 1
            tc_words = []
            carry = 1
            for word in abs_words:
                inverted = (~word) & 0xFFFFFFFFFFFFFFFF
                sum_val = (inverted + carry) & 0xFFFFFFFFFFFFFFFF
                carry = 1 if inverted + carry > 0xFFFFFFFFFFFFFFFF else 0
                tc_words.append(sum_val)          
            # If the highest bit is set, add another word with all bits set
            if len(tc_words) == 0 or (abs_words[-1] >> 63) == 1:
                tc_words.append(0xFFFFFFFFFFFFFFFF)
            
        # Expected results in sign-flag representation
        expected_words = int_to_words(value)
        
        test_case = {
            "twosComplementWords": tc_words,
            "expectedWords": expected_words
        }
        test_cases.append(test_case)
    
    return test_cases

def generate_string_init_tests():
    tests = []

    # Small numbers
    for i in [-100, -1, 0, 1, 42, 100, 255, 256, 65535, 65536]:
        tests.append({
            "input": str(i),
            "expectedWords": int_to_words(i)
        })

    # Medium numbers
    for i in [-10**6, -10**9, -10**18, -(2**63), 10**6, 10**9, 10**18, 2**63-1]:
        tests.append({
            "input": str(i),
            "expectedWords": int_to_words(i)
        })

    # Large numbers
    for i in [-10**50, -10**100, 10**50, 10**100]:
        tests.append({
            "input": str(i),
            "expectedWords": int_to_words(i)
        })

    # Bad strings
    tests.append({
        "input": "",
        "expectedWords": None
    })
    tests.append({
        "input": " ",
        "expectedWords": None
    })
    tests.append({
        "input": " 123",
        "expectedWords": None
    })
    tests.append({
        "input": "123 ",
        "expectedWords": None
    })

    return tests

def generate_bitwidth_tests():
    tests = []

    # Test various bit widths for positive numbers
    for i in [0, 1, 2, 3, 7, 8, 16, 32, 63, 64, 65, 127, 128]:
        if i == 0:
            n = 0
        else:
            n = (1 << i) - 1
        tests.append({
            "words": int_to_words(n),
            "bitWidth": n.bit_length() + 1,
            "leadingZeroBitCount": 0,
            "trailingZeroBitCount": count_trailing_zeros(n)
        })

    # Test various bit widths for negative numbers
    for i in [1, 2, 3, 7, 8, 16, 32, 63, 64, 65, 127, 128]:
        n = -((1 << i) - 1)
        tests.append({
            "words": int_to_words(n),
            "bitWidth": n.bit_length() + 1,
            "leadingZeroBitCount": 0,
            "trailingZeroBitCount": count_trailing_zeros(n)
        })

    # Test specific values (both positive and negative)
    specific_values = [42, -42, 0xFF, -0xFF, 0xFFFF, -0xFFFF, 0xFFFFFFFF, -0xFFFFFFFF]
    for v in specific_values:
        tests.append({
            "words": int_to_words(v),
            "bitWidth": v.bit_length() + 1,
            "leadingZeroBitCount": 0,
            "trailingZeroBitCount": count_trailing_zeros(v)
        })

    return tests

def generate_addition_tests():
    tests = []

    # Small additions with mixed signs
    pairs = [
        (0, 0), (1, 0), (0, 1), (1, 1), (42, 58),
        (-1, 0), (0, -1), (-1, -1), (-42, -58),
        (1, -1), (-1, 1), (100, -100), (-100, 100)
    ]

    # Word boundary tests
    boundary_pairs = [
        (0x7FFFFFFFFFFFFFFF, 1),       # Max Int64 + 1
        (-0x8000000000000000, -1),     # Min Int64 - 1
        (0x7FFFFFFFFFFFFFFF, -1),      # Max Int64 + (-1)
        (-0x8000000000000000, 1)       # Min Int64 + 1
    ]

    # Large additions
    large_pairs = [
        (10**50, 10**50),
        (-10**50, -10**50),
        (10**50, -10**50),
        (-10**50, 10**50),
        (10**100, 10**100),
        (-10**100, -10**100)
    ]

    for a, b in pairs + boundary_pairs + large_pairs:
        tests.append({
            "lWords": int_to_words(a),
            "rWords": int_to_words(b),
            "expectedWords": int_to_words(a + b),
        })

    return tests

def generate_subtraction_tests():
    tests = []

    # Small subtractions with mixed signs
    pairs = [
        (0, 0), (1, 0), (1, 1), (100, 42),
        (0, 1), (42, 100),             # Result becomes negative
        (-1, 0), (0, -1), (-1, -1),
        (-100, -42), (-42, -100),      # Various negative combinations
        (-1, 1), (1, -1)               # Opposite signs
    ]

    # Word boundary tests
    boundary_pairs = [
        (0x7FFFFFFFFFFFFFFF, 0x7FFFFFFFFFFFFFFF),  # Max Int64 - Max Int64
        (-0x8000000000000000, -0x8000000000000000),  # Min Int64 - Min Int64
        (0x7FFFFFFFFFFFFFFF, -0x8000000000000000),  # Max Int64 - Min Int64
        (-0x8000000000000000, 0x7FFFFFFFFFFFFFFF)   # Min Int64 - Max Int64
    ]

    # Large subtractions
    large_pairs = [
        (10**50, 10**40),
        (-10**50, -10**40),
        (10**50, -10**40),
        (-10**50, 10**40),
        (10**100, 10**90),
        (-10**100, -10**90)
    ]

    for a, b in pairs + boundary_pairs + large_pairs:
        tests.append({
            "lWords": int_to_words(a),
            "rWords": int_to_words(b),
            "expectedWords": int_to_words(a - b)
        })

    return tests

def generate_multiplication_tests():
    tests = []

    # Small multiplications with mixed signs
    pairs = [
        (0, 0), (1, 0), (0, 1), (1, 1), (2, 3), (42, 58),
        (-1, 0), (0, -1), (-1, -1), (-2, 3), (2, -3), (-2, -3),
        (-42, 58), (42, -58), (-42, -58)
    ]

    # Word boundary tests
    boundary_pairs = [
        (0x7FFFFFFFFFFFFFFF, 2),            # Max Int64 * 2
        (-0x8000000000000000, 2),           # Min Int64 * 2
        (0x7FFFFFFFFFFFFFFF, -1),           # Max Int64 * (-1)
        (-0x8000000000000000, -1),          # Min Int64 * (-1)
        (0x7FFFFFFFFFFFFFFF, 0x7FFFFFFFFFFFFFFF),  # Max Int64 * Max Int64
        (-0x8000000000000000, -0x8000000000000000)  # Min Int64 * Min Int64
    ]

    # Algorithm coverage tests
    algo_pairs = [
        (0x1234567890ABCDEF, 0xFEDCBA0987654321),  # Large positive * large positive
        (-0x1234567890ABCDEF, 0xFEDCBA0987654321),  # Large negative * large positive
        (0x1234567890ABCDEF, -0xFEDCBA0987654321),  # Large positive * large negative
        (-0x1234567890ABCDEF, -0xFEDCBA0987654321),  # Large negative * large negative
        
        # Cases that will trigger carry propagation
        (0x7FFFFFFFFFFFFFFF, 0x7FFFFFFFFFFFFFFF),  # Max Int64 squared
        (-0x8000000000000000, 0x7FFFFFFFFFFFFFFF),  # Min Int64 * Max Int64
        
        # Multi-word values
        (words_to_int([1, 2, 3, 4]), words_to_int([5, 6, 7, 8])),
        (words_to_int([-1, 2, 3, 4]), words_to_int([5, 6, 7, 8])),
        (words_to_int([1, 2, 3, 4]), words_to_int([-5, 6, 7, 8])),
        (words_to_int([-1, 2, 3, 4]), words_to_int([-5, 6, 7, 8]))
    ]

    # Large multiplications
    large_pairs = [
        (10**20, 10**20),
        (-10**20, 10**20),
        (10**20, -10**20),
        (-10**20, -10**20),
        (10**50, 10**50),
        (-10**50, -10**50)
    ]

    for a, b in pairs + boundary_pairs + algo_pairs + large_pairs:
        tests.append({
            "lWords": int_to_words(a),
            "rWords": int_to_words(b),
            "expectedWords": int_to_words(a * b)
        })

    return tests

def generate_division_modulus_tests():
    tests = []

    # Small divisions with mixed signs
    pairs = [
        (0, 1), (1, 1), (2, 1), (4, 2), (100, 3),
        (0, -1), (1, -1), (2, -1), (4, -2), (100, -3),
        (-1, 1), (-2, 1), (-4, 2), (-100, 3),
        (-1, -1), (-2, -1), (-4, -2), (-100, -3)
    ]

    # Word boundary tests
    boundary_pairs = [
        (0x7FFFFFFFFFFFFFFF, 1),            # Max Int64 / 1
        (-0x8000000000000000, 1),           # Min Int64 / 1
        (0x7FFFFFFFFFFFFFFF, -1),           # Max Int64 / (-1)
        (-0x8000000000000000, -1),          # Min Int64 / (-1)
        (0x7FFFFFFFFFFFFFFF, 0x7FFFFFFFFFFFFFFF),  # Max Int64 / Max Int64
        (-0x8000000000000000, -0x8000000000000000)  # Min Int64 / Min Int64
    ]

    # Algorithm coverage
    algo_pairs = [
        (0x1234567890ABCDEF, 0x123456),     # Large positive / smaller positive
        (-0x1234567890ABCDEF, 0x123456),    # Large negative / smaller positive
        (0x1234567890ABCDEF, -0x123456),    # Large positive / smaller negative
        (-0x1234567890ABCDEF, -0x123456),   # Large negative / smaller negative
        
        # Multi-word values
        (words_to_int([1, 2, 3, 4]), words_to_int([5, 0, 0, 0])),
        (words_to_int([-1, 2, 3, 4]), words_to_int([5, 0, 0, 0])),
        (words_to_int([1, 2, 3, 4]), words_to_int([-5, 0, 0, 0])),
        (words_to_int([-1, 2, 3, 4]), words_to_int([-5, 0, 0, 0]))
    ]

    # Large divisions
    large_pairs = [
        (10**50, 10**25),
        (-10**50, 10**25),
        (10**50, -10**25),
        (-10**50, -10**25),
        (10**100, 10**50),
        (-10**100, 10**50)
    ]

    for a, b in pairs + boundary_pairs + algo_pairs + large_pairs:
        if b == 0:
            continue  # Skip division by zero
        q, r = truncdivmod(a, b)
        tests.append({
            "dividendWords": int_to_words(a),
            "divisorWords": int_to_words(b),
            "quotientWords": int_to_words(q),
            "remainderWords": int_to_words(r)
        })

    return tests

def generate_negation_tests():
    tests = []
    
    # Test various values
    values = [0, 1, -1, 42, -42, 0x7FFFFFFFFFFFFFFF, -0x8000000000000000,
              10**20, -10**20, 10**50, -10**50]
    
    for v in values:
        tests.append({
            "valueWords": int_to_words(v),
            "expectedWords": int_to_words(-v)
        })
    
    return tests

def generate_abs_tests():
    tests = []
    
    # Test various values
    values = [0, 1, -1, 42, -42, 0x7FFFFFFFFFFFFFFF, -0x8000000000000000,
              10**20, -10**20, 10**50, -10**50]
    
    for v in values:
        tests.append({
            "valueWords": int_to_words(v),
            "expectedWords": int_to_words(abs(v))
        })
    
    return tests

def generate_bitwise_ops_tests():
    tests = []

    # Values to test (focusing on signed integer representation)
    pairs = [
        (0b1010, 0b1100),                 # Basic bit patterns
        (-0b1010, 0b1100),                # Negative with positive
        (0b1010, -0b1100),                # Positive with negative
        (-0b1010, -0b1100),               # Negative with negative
        (0x7FFFFFFFFFFFFFFF, 0xFFFFFFFF), # Max Int64 with smaller value
        (-0x8000000000000000, 0xFFFFFFFF) # Min Int64 with smaller value
    ]

    for a, b in pairs:
        # For signed integers, we need to handle the bitwise operations correctly
        # using two's complement
        tests.append({
            "lWords": int_to_words(a),
            "rWords": int_to_words(b),
            "expectedAndWords": int_to_words(a & b),
            "expectedOrWords": int_to_words(a | b),
            "expectedXorWords": int_to_words(a ^ b),
            "expectedNotLWords": int_to_words(~a),
            "expectedNotRWords": int_to_words(~b)
        })

    return tests

def generate_bitwise_shift_tests():
    tests = []

    # Basic values to test (including negative values)
    values = [0b1010, -0b1010, 0x5555, -0x5555, 0x7FFFFFFFFFFFFFFF, -0x8000000000000000]

    # Shift amounts to test
    shifts = [1, 4, 8, 16, 32, 63, 64, 65, 127, 128]

    for value in values:
        for shift in shifts:
            try:
                left_shifted = value << shift
                right_shifted = value >> shift
            except OverflowError:
                # Skip if Python can't handle the shift
                continue

            tests.append({
                "words": int_to_words(value),
                "shift": shift,
                "expectedLeftWords": int_to_words(left_shifted),
                "expectedRightWords": int_to_words(right_shifted)
            })

    return tests

def generate_comparison_tests():
    tests = []

    # Values to test (with both positive and negative values)
    pairs = [
        (0, 0),                            # Equal zeros
        (1, 1), (-1, -1),                  # Equal positive and negative
        (0x7FFFFFFFFFFFFFFF, 0x7FFFFFFFFFFFFFFF),  # Equal Max Int64
        (-0x8000000000000000, -0x8000000000000000),  # Equal Min Int64
        
        (0, 1), (1, 2),                    # Less than (positive)
        (-2, -1), (-1, 0),                 # Less than (negative to positive)
        
        (1, 0), (2, 1),                    # Greater than (positive)
        (-1, -2), (0, -1),                 # Greater than (positive to negative)
        
        (-0x8000000000000000, 0x7FFFFFFFFFFFFFFF),  # Min Int64 < Max Int64
        (0x7FFFFFFFFFFFFFFF, -0x8000000000000000),  # Max Int64 > Min Int64
        
        # Multi-word comparisons
        (words_to_int([1, 2, 3, 4]), words_to_int([1, 2, 3, 4])),  # Equal
        (words_to_int([1, 2, 3, 4]), words_to_int([5, 6, 7, 8])),  # Less than
        (words_to_int([5, 6, 7, 8]), words_to_int([1, 2, 3, 4])),  # Greater than
        
        # Negative multi-word comparisons
        (words_to_int([-1, 2, 3, 4]), words_to_int([-1, 2, 3, 4])),  # Equal
        (words_to_int([-5, 6, 7, 8]), words_to_int([-1, 2, 3, 4])),  # Less than
        (words_to_int([-1, 2, 3, 4]), words_to_int([-5, 6, 7, 8]))   # Greater than
    ]

    for a, b in pairs:
        tests.append({
            "lWords": int_to_words(a),
            "rWords": int_to_words(b),
            "expectedEq": a == b,
            "expectedLt": a < b,
            "expectedLtEq": a <= b,
            "expectedGt": a > b,
            "expectedGtEq": a >= b
        })

    return tests

def generate_power_tests():
    tests = []

    # Simple cases (with both positive and negative bases)
    simple_cases = [
        (0, 0),  # 0^0 = 1 (mathematical convention)
        (0, 1),  # 0^1 = 0
        (1, 0),  # 1^0 = 1
        (1, 1),  # 1^1 = 1
        (-1, 0),  # (-1)^0 = 1
        (-1, 1),  # (-1)^1 = -1
        (-1, 2),  # (-1)^2 = 1
        (2, 0),  # 2^0 = 1
        (2, 1),  # 2^1 = 2
        (2, 2),  # 2^2 = 4
        (-2, 2),  # (-2)^2 = 4
        (-2, 3),  # (-2)^3 = -8
        (3, 2),  # 3^2 = 9
        (-3, 2),  # (-3)^2 = 9
    ]

    for base, exponent in simple_cases:
        tests.append({
            "baseWords": int_to_words(base),
            "exponent": exponent,
            "expectedWords": int_to_words(base ** exponent)
        })

    # Powers of 2, -2, 10, and -10
    for exponent in [1, 2, 3, 10, 20, 50]:
        result2 = 2 ** exponent
        resultN2 = (-2) ** exponent
        result10 = 10 ** exponent
        resultN10 = (-10) ** exponent
        
        tests.append({
            "baseWords": int_to_words(2),
            "exponent": exponent,
            "expectedWords": int_to_words(result2)
        })
        
        tests.append({
            "baseWords": int_to_words(-2),
            "exponent": exponent,
            "expectedWords": int_to_words(resultN2)
        })
        
        tests.append({
            "baseWords": int_to_words(10),
            "exponent": exponent,
            "expectedWords": int_to_words(result10)
        })
        
        tests.append({
            "baseWords": int_to_words(-10),
            "exponent": exponent,
            "expectedWords": int_to_words(resultN10)
        })

    # Other interesting bases
    other_bases = [
        (3, 10),    # 3^10
        (-3, 10),   # (-3)^10
        (-3, 11),   # (-3)^11
        (5, 7),     # 5^7
        (-5, 7),    # (-5)^7
    ]

    for base, exponent in other_bases:
        tests.append({
            "baseWords": int_to_words(base),
            "exponent": exponent,
            "expectedWords": int_to_words(base ** exponent)
        })

    return tests

def generate_float_init_tests():
    tests = []

    # Import numpy for proper float handling - it's required
    try:
        import numpy as np
    except ImportError:
        print("ERROR: NumPy is required for generating float tests. Please install numpy and try again.")
        return []

    # Define basic values to test for both signs
    values = [
        0.0, 1.0, -1.0, 2.0, -2.0, 10.0, -10.0, 
        100.0, -100.0, 1000.0, -1000.0,
        1.5, -1.5, 2.5, -2.5, 3.14, -3.14
    ]
    
    # Power of 2 values (positive and negative)
    pow2_values = [2.0**i for i in range(1, 10)] + [-(2.0**i) for i in range(1, 10)]
    
    # Larger values
    larger_values = [10.0**i for i in range(2, 10)] + [-(10.0**i) for i in range(2, 10)]
    
    # Edge cases for each precision
    # Float16 has 11 bits of precision (10 fraction bits + 1 implicit bit)
    float16_exact_max = 2048.0  # 2^11
    float32_exact_max = 16777216.0  # 2^24
    float64_exact_max = 9007199254740992.0  # 2^53
    
    edge_values = [
        float16_exact_max, -float16_exact_max,
        float32_exact_max, -float32_exact_max,
        float64_exact_max, -float64_exact_max
    ]
    
    # Special values
    special_values = [float('inf'), float('-inf'), float('nan')]
    
    all_test_values = values + pow2_values + larger_values + edge_values + special_values
    
    for value in all_test_values:
        # For Float16
        if abs(value) <= 65504.0 and not math.isnan(value) and math.isfinite(value):  # Max representable in Float16
            tests.append({
                "floatValue": float(value),
                "precision": 16,
                "expectedWords": int_to_words(int(np.float16(value)))
            })
            
        # For Float32
        if abs(value) <= 3.4028235e+38 and not math.isnan(value) and math.isfinite(value):  # Max representable in Float32
            tests.append({
                "floatValue": float(value),
                "precision": 32,
                "expectedWords": int_to_words(int(np.float32(value)))
            })
            
        # For Float64
        if math.isfinite(value) and not math.isnan(value):
            tests.append({
                "floatValue": float(value),
                "precision": 64,
                "expectedWords": int_to_words(int(value))
            })

    return tests

def generate_encoding_tests():
    tests = []
    
    # Test values covering various cases (both positive and negative)
    test_values = [
        0,                      # Zero
        1,                      # Small positive value
        -1,                     # Small negative value
        127,                    # Positive 7-bit value
        -128,                   # Negative 8-bit value (two's complement boundary)
        128,                    # Positive 8-bit value
        -129,                   # Negative 9-bit value
        255,                    # One byte boundary (positive)
        -256,                   # One byte boundary (negative)
        256,                    # Multi-byte small value (positive)
        -257,                   # Multi-byte small value (negative)
        0x7FFF,                 # Positive 15-bit value
        -0x8000,                # Negative 16-bit value (two's complement boundary)
        0x8000,                 # Positive 16-bit value
        -0x8001,                # Negative 17-bit value
        0xFFFF,                 # Two bytes boundary (positive)
        -0x10000,               # Two bytes boundary (negative)
        0x7FFFFFFF,             # Positive 31-bit value
        -0x80000000,            # Negative 32-bit value (two's complement boundary)
        0xFFFFFFFF,             # Four bytes (32-bit boundary positive)
        -0x100000000,           # Four bytes (32-bit boundary negative)
        0x7FFFFFFFFFFFFFFF,     # Positive 63-bit value (Int64.max)
        -0x8000000000000000,    # Negative 64-bit value (Int64.min)
        0xFFFFFFFFFFFFFFFF,     # Eight bytes (64-bit boundary positive)
        -0x10000000000000000,   # Eight bytes (64-bit boundary negative)
        0x10000000000000000,    # Requires more than 8 bytes (positive)
        -0x10000000000000001,   # Requires more than 8 bytes (negative)
        10**20,                 # Large power of 10 (positive)
        -10**20,                # Large power of 10 (negative)
        10**50,                 # Very large power of 10 (positive)
        -10**50,                # Very large power of 10 (negative)
    ]
    
    for value in test_values:
        # Calculate minimum bytes needed (ceiling division of bit_length by 8)
        byte_length = max(1, (value.bit_length() + 8) // 8)

        # Convert to big-endian bytes
        big_endian_bytes = value.to_bytes(byte_length, byteorder='big', signed=True)
        
        tests.append({
            "value": str(value),
            "encodedBytes": list(big_endian_bytes),
            "words": int_to_words(value)
        })
    
    # Edge case tests for sign bit handling
    
    # Powers of 2 boundary cases (positive and negative)
    for i in range(3, 12):  # Test 2^3 through 2^11 and their negatives
        pos_power = 2**i
        neg_power = -pos_power
        
        pos_bytes = pos_power.to_bytes((pos_power.bit_length() + 8) // 8, byteorder='big', signed=True)
        neg_bytes = neg_power.to_bytes(max(1, (abs(neg_power).bit_length() + 8) // 8), byteorder='big', signed=True)
        
        tests.append({
            "value": str(pos_power),
            "encodedBytes": list(pos_bytes),
            "words": int_to_words(pos_power)
        })
        
        tests.append({
            "value": str(neg_power),
            "encodedBytes": list(neg_bytes),
            "words": int_to_words(neg_power)
        })
    
    # Test values around Int64.min and Int64.max
    int64_max = 0x7FFFFFFFFFFFFFFF
    int64_min = -0x8000000000000000
    
    for offset in [-10, -2, -1, 0, 1, 2, 10]:
        if offset == 0:
            # Just test the boundary values themselves
            val_max = int64_max
            val_min = int64_min
        else:
            # Test values near the boundaries
            val_max = int64_max + offset
            val_min = int64_min + offset
        
        max_bytes_length = max(1, (val_max.bit_length() + 8) // 8)
        max_bytes = val_max.to_bytes(max_bytes_length, byteorder='big', signed=True)
        min_bytes_length = max(1, (val_min.bit_length() + 8) // 8)
        min_bytes = val_min.to_bytes(min_bytes_length, byteorder='big', signed=True)
        
        tests.append({
            "value": str(val_max),
            "encodedBytes": list(max_bytes),
            "words": int_to_words(val_max)
        })
        
        tests.append({
            "value": str(val_min),
            "encodedBytes": list(min_bytes),
            "words": int_to_words(val_min)
        })
    
    # Leading zero bytes should be handled correctly for positive numbers
    # Leading 0xFF bytes should be handled correctly for negative numbers
    for padding in [1, 2, 4]:
        # Positive values with leading zeros
        for val in [1, 0x7F, 0x80, 0xFF]:
            val_bytes = val.to_bytes((val.bit_length() + 8) // 8, byteorder='big', signed=False)
            padded_bytes = bytes([0] * padding) + val_bytes
            
            tests.append({
                "value": str(val),
                "encodedBytes": list(val_bytes),  # Swift will strip leading zeros
                "words": int_to_words(val),
                "inputBytes": list(padded_bytes)  # Special input for decoding test
            })
        
        # Negative values with leading 0xFF bytes
        for val in [-1, -0x80, -0x81, -0x100]:
            min_bytes = (val.bit_length() + 8) // 8
            val_bytes = val.to_bytes(min_bytes, byteorder='big', signed=True)
            # Add leading 0xFF bytes (sign extension)
            padded_bytes = bytes([0xFF] * padding) + val_bytes
            
            tests.append({
                "value": str(val),
                "encodedBytes": list(val_bytes),  # Swift will normalize
                "words": int_to_words(val),
                "inputBytes": list(padded_bytes)  # Special input for decoding test
            })
    
    return tests

def generate_gcd_lcm_tests():
    tests = []

    # Simple test cases with both positive and negative values
    pairs = [
        (0, 0),           # (0, 0) -> gcd=0, lcm=0
        (1, 0),           # (1, 0) -> gcd=1, lcm=0
        (0, 1),           # (0, 1) -> gcd=1, lcm=0
        (1, 1),           # (1, 1) -> gcd=1, lcm=1
        (2, 3),           # (2, 3) -> gcd=1, lcm=6
        (6, 8),           # (6, 8) -> gcd=2, lcm=24
        (12, 18),         # (12, 18) -> gcd=6, lcm=36
        (35, 49),         # (35, 49) -> gcd=7, lcm=245
        (48, 180),        # (48, 180) -> gcd=12, lcm=720
        
        # Negative values (GCD is always positive, LCM preserves sign of product)
        (-12, 18),        # (-12, 18) -> gcd=6, lcm=-36
        (12, -18),        # (12, -18) -> gcd=6, lcm=-36
        (-12, -18),       # (-12, -18) -> gcd=6, lcm=36
        (-35, 49),        # (-35, 49) -> gcd=7, lcm=-245
        (35, -49),        # (35, -49) -> gcd=7, lcm=-245
        (-35, -49),       # (-35, -49) -> gcd=7, lcm=245
    ]

    # Edge cases and larger numbers
    edge_pairs = [
        (0x7FFFFFFFFFFFFFFF, 0x7FFFFFFFFFFFFFFE),  # Max Int64 and Max Int64-1
        (0x7FFFFFFFFFFFFFFF, 0x8000000000000000),  # Max Int64 and Min Int64
        (-0x8000000000000000, 0x8000000000000000), # Min Int64 and its absolute value
        (10**20, 10**21),                          # Powers of 10
        (-10**20, 10**21),                         # Negative and positive powers of 10
        (10**50, 10**49),                          # Larger powers of 10
    ]

    for a, b in pairs + edge_pairs:
        # Compute GCD (always positive)
        gcd = abs(math.gcd(a, b))
        
        # Compute LCM
        if a == 0 or b == 0:
            lcm = 0
        else:
            abs_lcm = abs(a) // gcd * abs(b)
            # LCM preserves the sign of the product
            lcm = abs_lcm if (a < 0) == (b < 0) else -abs_lcm
        
        tests.append({
            "lWords": int_to_words(a),
            "rWords": int_to_words(b),
            "expectedGcdWords": int_to_words(gcd),
            "expectedLcmWords": int_to_words(lcm)
        })

    return tests

def generate_integer_conversion_tests():
    tests = []
    
    # Define maximum values for each integer type
    max_int8 = 2**7 - 1           # 127
    min_int8 = -2**7              # -128
    max_uint8 = 2**8 - 1          # 255
    
    max_int16 = 2**15 - 1         # 32767
    min_int16 = -2**15            # -32768
    max_uint16 = 2**16 - 1        # 65535
    
    max_int32 = 2**31 - 1         # 2147483647
    min_int32 = -2**31            # -2147483648
    max_uint32 = 2**32 - 1        # 4294967295
    
    max_int64 = 2**63 - 1         # 9223372036854775807
    min_int64 = -2**63            # -9223372036854775808
    max_uint64 = 2**64 - 1        # 18446744073709551615
    
    max_int128 = 2**127 - 1       # Very large number
    min_int128 = -2**127          # Very large negative number
    max_uint128 = 2**128 - 1      # Very large number
    
    # Define test values including positive and negative numbers
    test_values = [
        0,                  # Zero
        1,                  # One
        -1,                 # Negative one
        max_int8,           # Max Int8
        min_int8,           # Min Int8
        -max_int8,          # -Max Int8
        max_uint8,          # Max UInt8
        max_int16,          # Max Int16
        min_int16,          # Min Int16
        -max_int16,         # -Max Int16
        max_uint16,         # Max UInt16
        max_int32,          # Max Int32
        min_int32,          # Min Int32
        -max_int32,         # -Max Int32
        max_uint32,         # Max UInt32
        max_int64,          # Max Int64
        min_int64,          # Min Int64
        -max_int64,         # -Max Int64
        max_uint64,         # Max UInt64
        max_int128,         # Max Int128
        min_int128,         # Min Int128
        -max_int128,        # -Max Int128
        max_uint128,        # Max UInt128
        10**20,             # Large positive power of 10
        -10**20,            # Large negative power of 10
        10**50,             # Very large positive power of 10
        -10**50,            # Very large negative power of 10
    ]
    
    # Create test cases for all values
    for value in test_values:
        # Determine which integer types can exactly represent this value
        int8_value = value if min_int8 <= value <= max_int8 else None
        uint8_value = value if 0 <= value <= max_uint8 else None
        int16_value = value if min_int16 <= value <= max_int16 else None
        uint16_value = value if 0 <= value <= max_uint16 else None
        int32_value = value if min_int32 <= value <= max_int32 else None
        uint32_value = value if 0 <= value <= max_uint32 else None
        int64_value = value if min_int64 <= value <= max_int64 else None
        uint64_value = value if 0 <= value <= max_uint64 else None
        int128_value = value if min_int128 <= value <= max_int128 else None
        uint128_value = value if 0 <= value <= max_uint128 else None
        
        # Create test case
        test_case = {
            "sourceWords": int_to_words(value),
            "expectedInt8": int8_value,
            "expectedUInt8": uint8_value,
            "expectedInt16": int16_value,
            "expectedUInt16": uint16_value,
            "expectedInt32": int32_value,
            "expectedUInt32": uint32_value,
            "expectedInt64": int64_value,
            "expectedUInt64": uint64_value,
            "expectedInt128": int128_value,
            "expectedUInt128": uint128_value,
            "expectedInt": int64_value,  # Assuming Int is 64-bit
            "expectedUInt": uint64_value  # Assuming UInt is 64-bit
        }
        
        tests.append(test_case)
    
    return tests

def generate():
    """Test data for BigIntTests"""
    tests = {
        "stringInitialization": generate_string_init_tests(),
        "floatInitialization": generate_float_init_tests(),
        "bitWidth": generate_bitwidth_tests(),
        "addition": generate_addition_tests(),
        "subtraction": generate_subtraction_tests(),
        "multiplication": generate_multiplication_tests(),
        "divisionModulus": generate_division_modulus_tests(),
        "negation": generate_negation_tests(),
        "abs": generate_abs_tests(),
        "bitwiseOps": generate_bitwise_ops_tests(),
        "bitwiseShift": generate_bitwise_shift_tests(),
        "comparison": generate_comparison_tests(),
        "power": generate_power_tests(),
        "gcdLcm": generate_gcd_lcm_tests(),
        "integerConversion": generate_integer_conversion_tests(),
        "twosComplementInit": generate_twos_complement_init_tests(),
        "encoding": generate_encoding_tests(),
    }

    return {
        "BigIntTestData": tests
    }