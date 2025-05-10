import pathlib
import json

word_bit_width = 64
word_max = 2**word_bit_width - 1

# Define maximum values for each integer type
max_int8 = 0x7F                              # 127
max_uint8 = 0xFF                             # 255
max_int16 = 0x7FFF                           # 32767
max_uint16 = 0xFFFF                          # 65535
max_int32 = 0x7FFFFFFF                       # 2147483647
max_uint32 = 0xFFFFFFFF                      # 4294967295
max_int64 = 0x7FFFFFFFFFFFFFFF               # 9223372036854775807
max_uint64 = 0xFFFFFFFFFFFFFFFF              # 18446744073709551615
max_int128 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  # 2^127 - 1
max_uint128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  # 2^128 - 1

def int_to_words(n, word_size=64):
    """Convert integer to little-endian hex word array"""
    if n == 0:
        return [0x0]

    mask = (1 << word_size) - 1
    words = []

    while n > 0:
        words.append(n & mask)
        n >>= word_size

    # remove trailing zeros if there is more than one word
    while len(words) > 1 and words[-1] == 0:
        words.pop()

    return words

def words_to_int(words, word_size=64):
    """Convert little-endian hex word array to integer"""
    if not words:
        return 0
    return sum(word << (i * word_size) for i, word in enumerate(words))

def count_trailing_zeros(n):
  n = abs(n)
  count = 0
  while n > 0 and (n & 1) == 0:
    n >>= 1
    count += 1
  return count

def truncdivmod(num : int, denom : int):
  if (num < 0) != (denom < 0):
    q, r = divmod(num, -denom)
    return [-q, r]
  else:
    return divmod(num, denom)

def write_test_data(test_data, file_name):
  current_dir = pathlib.Path(__file__).parent
  
  with open(current_dir / "../SolidTests/Resources" / file_name, "w") as f:
    json.dump(test_data, f, indent=2)

  print(f"Test data generated successfully and saved to {file_name}")
