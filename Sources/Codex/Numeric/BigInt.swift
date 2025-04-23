//
//  BigInt.swift
//  Codex
//
//  Created by Kevin Wooten on 4/16/25.
//

import Foundation

/// Arbitrary‑precision unsigned integer.
///
/// Implements an arbitrary-precision unsigned integer in Swift's numeric protocols.
///
/// The value is a backed by a ``BigUInt`` magnitude and accompanying sign.
/// The sign is stored separately to allow for efficient arithmetic operations.
///
public struct BigInt {

  public private(set) var isNegative: Bool
  public private(set) var magnitude: Magnitude

  public init() {
    self.isNegative = false
    self.magnitude = BigUInt()
  }

  internal init(isNegative: Bool, magnitude: Magnitude) {
    self.isNegative = isNegative && !magnitude.isZero
    self.magnitude = magnitude
  }

  internal init(isNegative: Bool, words: BigUInt.Words) {
    self.init(isNegative: isNegative, magnitude: BigUInt(words: words))
  }

  internal init<S>(isNegative: Bool, words: S) where S: Sequence, S.Element == UInt {
    self.init(isNegative: isNegative, words: BigUInt.Words(words))
  }

  public init<S>(twosComplementWords words: S) where S: Collection, S.Element == UInt {
    precondition(!words.isEmpty, "words must not be empty")

    var resultWords = BigUInt.Words(words)

    // Check sign based on highest bit
    guard resultWords.mostSignificant >> BigUInt.msbShift == 1 else {
      // Positive: direct initialization
      self.isNegative = false
      self.magnitude = BigUInt(words: resultWords)
      return
    }

    // Negative: convert from two's complement
    var carry: UInt = 1
    for i in 0..<resultWords.count {
      resultWords[i] = ~resultWords[i]
      let (sum, overflow) = resultWords[i].addingReportingOverflow(carry)
      resultWords[i] = sum
      carry = overflow ? 1 : 0
    }
    assert(carry == 0, "Carry must be 0 or we're translating a positive number")

    self.isNegative = true
    self.magnitude = BigUInt(words: resultWords)
  }

  internal var isZero: Bool {
    return magnitude.isZero
  }

  public static let minusOne = BigInt(isNegative: true, magnitude: .one)
  public static let zero = BigInt()
  public static let one = BigInt(isNegative: false, magnitude: .one)
  public static let two = BigInt(isNegative: false, magnitude: .two)
  public static let ten = BigInt(isNegative: false, magnitude: .ten)

}

extension BigInt: Sendable {}
extension BigInt: Equatable {}
extension BigInt: Hashable {}

extension BigInt: Numeric, BinaryInteger, SignedInteger {

  public struct Words: RandomAccessCollection {

    public let value: BigInt
    public let count: Int

    public init(value: BigInt) {
      self.value = value
      self.count = (value.bitWidth + BigUInt.wordBits - 1) / BigUInt.wordBits
    }

    public var startIndex: Int { 0 }
    public var endIndex: Int { count }

    public subscript(position: Int) -> UInt {
      guard position < value.magnitude.words.count else {
        // Sign-extend beyond magnitude
        return value.isNegative ? UInt.max : 0
      }

      let magWord = value.magnitude.words[position]
      guard value.isNegative else {
        return magWord
      }

      // Invert and add 1 across the range (two's complement)
      var word = ~magWord

      if position == 0 {
        word &+= 1
      } else {
        // Add carry if all lower words were 0
        var carry = true
        for i in 0..<position where value.magnitude.words[i] != 0 {
          carry = false
          break
        }
        if carry {
          word &+= 1
        }
      }

      return word
    }

    internal subscript(i: Int, defaultSignExtended negative: Bool) -> UInt {
      if i < count {
        return self[i]
      }
      return negative ? UInt.max : 0
    }
  }

  public typealias Magnitude = BigUInt

  public static let isSigned = true

  // MARK - Integer initializers

  public init<T: BinaryInteger>(_ source: T) {
    self.isNegative = T.isSigned && source < 0
    self.magnitude = BigUInt(source.magnitude)
  }

  @inlinable
  public init?<T: BinaryInteger>(exactly source: T) {
    self.init(source)
  }

  /// Truncates the value to the nearest representable positive or negative integer.
  ///
  /// - Note: Since `BigInt` has no bounds this is identical to the plain initializer.
  ///
  public init<T: BinaryInteger>(truncatingIfNeeded source: T) {
    self.init(source)
  }

  /// Clamps values to the nearest representable positive or negative integer.
  ///
  /// - Note: Since `BigInt` has no bounds this is identical to the plain initializer.
  ///
  public init<T: BinaryInteger>(clamping source: T) {
    self.init(source)
  }

  // MARK: - Floating point initializers

  /// Conversion from any finite floating-point value.
  ///
  /// If the value cannot be represented (e.g., it is a `NaN` or `±∞`), this initializer faults.
  ///
  public init<T: BinaryFloatingPoint>(_ source: T) {
    precondition(
      source.isFinite,
      "\(String(describing: type(of: source))) value cannot be converted to BigInt because it is either infinite or NaN"
    )
    guard source != 0 else {
      self = .zero
      return
    }
    self.isNegative = source < 0
    self.magnitude = BigUInt(source.magnitude)
  }

  /// Exact conversion from a floating-point value.
  ///
  /// If the value cannot be representedd eactly, (`NaN`,` ±∞`, or has a fractional part), this initialize fails.
  ///
  public init?<T: BinaryFloatingPoint>(exactly source: T) {
    // finite and integral
    guard source.isFinite,
      source.rounded(.towardZero) == source
    else { return nil }

    self.init(source)    // magnitude + sign delegate
  }

  // MARK: - Properties

  public var words: Words { Words(value: self) }

  public var bitWidth: Int {
    return magnitude.bitWidth + 1
  }

  public var leadingZeroBitCount: Int {
    0
  }

  public var trailingZeroBitCount: Int {
    magnitude.trailingZeroBitCount
  }

  public func signum() -> Self {
    guard !isZero else { return .zero }
    return isNegative ? BigInt.minusOne : BigInt.one
  }

  // MARK: - Arithmetic

  public mutating func negate() {
    guard !isZero else { return }
    isNegative.toggle()
  }

  public static prefix func - (value: Self) -> Self {
    var value = value
    value.negate()
    return value
  }

  public static func + (lhs: Self, rhs: Self) -> Self {
    switch (lhs.isNegative, rhs.isNegative) {
    case (false, false):
      return Self(isNegative: false, magnitude: lhs.magnitude + rhs.magnitude)
    case (true, true):
      return Self(isNegative: true, magnitude: lhs.magnitude + rhs.magnitude)
    case (false, true):
      guard lhs.magnitude >= rhs.magnitude else {
        return Self(isNegative: true, magnitude: rhs.magnitude - lhs.magnitude)
      }
      return Self(isNegative: false, magnitude: lhs.magnitude - rhs.magnitude)
    case (true, false):
      guard lhs.magnitude >= rhs.magnitude else {
        return Self(isNegative: false, magnitude: rhs.magnitude - lhs.magnitude)
      }
      return Self(isNegative: true, magnitude: lhs.magnitude - rhs.magnitude)
    }
  }

  public static func += (lhs: inout Self, rhs: Self) {
    lhs = lhs + rhs
  }

  public static func - (lhs: Self, rhs: Self) -> Self { lhs + (-rhs) }

  public static func -= (lhs: inout Self, rhs: Self) {
    lhs = lhs - rhs
  }

  public static func * (lhs: Self, rhs: Self) -> Self {
    let isNegative = lhs.isNegative != rhs.isNegative
    let magnitude = lhs.magnitude * rhs.magnitude
    return Self(isNegative: isNegative, magnitude: magnitude)
  }

  public static func *= (lhs: inout Self, rhs: Self) { lhs = lhs * rhs }

  public func quotientAndRemainder(dividingBy divisor: BigInt) -> (quotient: BigInt, remainder: BigInt) {
    precondition(!divisor.isZero, "Division by zero")

    // Calculate quotient and remainder magnitudes first
    let (qMag, rMag) = magnitude.quotientAndRemainder(dividingBy: divisor.magnitude)

    // Determine signs
    let quotientNeg = isNegative != divisor.isNegative
    let remainderNeg = isNegative

    let quotient = Self(isNegative: quotientNeg, magnitude: qMag)
    let remainder = Self(isNegative: remainderNeg, magnitude: rMag)

    return (quotient, remainder)
  }

  public func remainder(dividingBy divisor: BigInt) -> BigInt {
    quotientAndRemainder(dividingBy: divisor).remainder
  }

  public static func / (lhs: Self, rhs: Self) -> Self {
    return lhs.quotientAndRemainder(dividingBy: rhs).quotient
  }

  public static func /= (lhs: inout Self, rhs: Self) { lhs = lhs / rhs }

  public static func % (lhs: Self, rhs: Self) -> Self {
    return lhs.remainder(dividingBy: rhs)
  }

  public static func %= (lhs: inout Self, rhs: Self) { lhs = lhs % rhs }

  /// Returns the value raised to the specified power.
  ///
  public func raised(to power: Int) -> BigInt {
    precondition(power >= 0, "Negative powers are not supported")
    if power == 0 { return .one }
    if power == 1 { return self }

    let isNegative = self.isNegative && power % 2 == 1
    let result = BigInt(isNegative: isNegative, magnitude: magnitude.raised(to: power))
    return result
  }

  /// Returns the greatest common divisor of this value and another value.
  ///
  /// The result is always positive, regardless of the signs of the inputs.
  ///
  /// - Parameter other: The other value
  /// - Returns: The greatest common divisor
  ///
  public func greatestCommonDivisor(_ other: BigInt) -> BigInt {
    // GCD is always positive, so we can work with magnitudes
    return BigInt(isNegative: false, magnitude: magnitude.greatestCommonDivisor(other.magnitude))
  }

  /// Returns the least common multiple of this value and another value.
  ///
  /// The sign of the result is the product of the signs of the inputs.
  ///
  /// - Parameter other: The other value
  /// - Returns: The least common multiple
  ///
  public func lowestCommonMultiple(_ other: BigInt) -> BigInt {
    if isZero || other.isZero {
      return .zero
    }
    // LCM preserves the sign of the product
    let isNegative = self.isNegative != other.isNegative
    return BigInt(isNegative: isNegative, magnitude: magnitude.lowestCommonMultiple(other.magnitude))
  }

  // MARK: - Bitwise

  internal static func bitwiseOp(
    _ lhs: BigInt,
    _ rhs: BigInt,
    operation: (UInt, UInt) -> UInt
  ) -> BigInt {

    // Operate directly on two's complement representation
    let lhsWords = lhs.words
    let rhsWords = rhs.words
    let maxCount = Swift.max(lhsWords.count, rhsWords.count)
    var resultWords = BigUInt.Words(repeating: 0, count: maxCount)

    for i in 0..<maxCount {
      let lhsWord = lhsWords[i, defaultSignExtended: lhs.isNegative]
      let rhsWord = rhsWords[i, defaultSignExtended: rhs.isNegative]
      resultWords[i] = operation(lhsWord, rhsWord)
    }

    // Initialize from two's complement words directly
    return BigInt(twosComplementWords: resultWords)
  }

  public static prefix func ~ (value: BigInt) -> BigInt {
    // Two's complement identity: ~x = -(x + 1)
    return -(value + 1)
  }

  public static func & (lhs: BigInt, rhs: BigInt) -> BigInt {
    bitwiseOp(lhs, rhs, operation: &)
  }

  public static func &= (lhs: inout BigInt, rhs: BigInt) {
    lhs = lhs & rhs
  }

  public static func | (lhs: BigInt, rhs: BigInt) -> BigInt {
    bitwiseOp(lhs, rhs, operation: |)
  }

  public static func |= (lhs: inout BigInt, rhs: BigInt) {
    lhs = lhs | rhs
  }

  public static func ^ (lhs: BigInt, rhs: BigInt) -> BigInt {
    bitwiseOp(lhs, rhs, operation: ^)
  }

  public static func ^= (lhs: inout BigInt, rhs: BigInt) {
    lhs = lhs ^ rhs
  }

  /// Shifts

  public static func << <RHS>(lhs: BigInt, rhs: RHS) -> BigInt where RHS: BinaryInteger {
    var t = lhs
    t <<= rhs
    return t
  }

  public static func <<= <RHS>(lhs: inout BigInt, rhs: RHS) where RHS: BinaryInteger {
    lhs.magnitude.shiftLeft(Int(rhs))
  }

  public static func >> <RHS>(lhs: BigInt, rhs: RHS) -> BigInt where RHS: BinaryInteger {
    var t = lhs
    t >>= rhs
    return t
  }

  public static func >>= <RHS>(lhs: inout BigInt, rhs: RHS) where RHS: BinaryInteger {
    guard rhs > 0 else {
      return
    }
    if lhs.isNegative {
      // arithmetic shift
      var add = BigUInt(1)
      add.shiftLeft(Int(rhs))
      add -= 1
      lhs.magnitude += add
    }
    lhs.magnitude.shiftRight(Int(rhs))
    if lhs.magnitude.isZero {
      lhs.isNegative = false
    }
  }

}

// MARK: - Comparison

extension BigInt {

  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.isNegative == rhs.isNegative && lhs.magnitude == rhs.magnitude
  }

}

extension BigInt: Comparable {

  public static func < (lhs: BigInt, rhs: BigInt) -> Bool {
    if lhs.isNegative != rhs.isNegative { return lhs.isNegative }
    if lhs.isNegative { return rhs.magnitude < lhs.magnitude }
    return lhs.magnitude < rhs.magnitude
  }

}

// MARK: - Literals

extension BigInt: ExpressibleByIntegerLiteral {

  public init(integerLiteral value: StaticBigInt) {
    let bitWidth = value.bitWidth
    guard bitWidth > 0 else {
      self.init(isNegative: false, magnitude: .zero)
      return
    }
    let wordCount = (bitWidth + BigUInt.wordBits - 1) / BigUInt.wordBits
    var words = BigUInt.Words(repeating: 0, count: wordCount + 1)
    for i in 0..<words.count {
      words[i] = UInt(value[i])
    }
    if value.signum() < 0 {
      self.init(twosComplementWords: words)
    } else {
      self.init(isNegative: false, magnitude: BigUInt(words: words))
    }
  }

}

// MARK: - Strings

extension BigInt: LosslessStringConvertible {

  public init?(_ description: some StringProtocol) {
    guard !description.isEmpty else {
      return nil
    }

    let isNegative = description.first == "-"
    let startIndex = isNegative ? description.index(after: description.startIndex) : description.startIndex
    guard let magnitude = BigUInt(description[startIndex...]) else {
      return nil
    }

    self.init(isNegative: isNegative, magnitude: magnitude)
  }

}

extension BigInt: CustomStringConvertible, CustomDebugStringConvertible {

  public var description: String {
    "\(isNegative ? "-" : "")\(magnitude.description)"
  }

  public var debugDescription: String {
    "BigInt(\(self))"
  }

}

// MARK: - String Extensions

extension String {
  /// Creates a new string from a ``BigInt`` value.
  /// - Parameter integer: The value to convert to a string.
  public init(_ integer: BigInt) {
    self = integer.description
  }
}

// MARK: - Encode/Decode

extension BigInt {

  /// Encodes the BigInt as a byte array in big-endian two's complement format.
  ///
  /// - Returns: A byte array representing the BigInt in big-endian two's complement format.
  ///
  public func encode() -> [UInt8] {
    guard !isZero else {
      return [0]
    }

    var encodedBytes = magnitude.encode()

    guard isNegative else {
      // For positive numbers, just encode the magnitude and ensure the high bit is clear

      // If the high bit is set, we need to prepend a zero byte to avoid
      // being interpreted as negative in two's complement
      if encodedBytes[0] & 0x80 != 0 {
        encodedBytes.insert(0, at: 0)
      }

      return encodedBytes
    }

    // Ensure we have room for the sign bit
    if encodedBytes[0] & 0x80 == 0x80 {
      encodedBytes.insert(0, at: 0)
    }

    // Invert all bits
    for i in 0..<encodedBytes.count {
      encodedBytes[i] = ~encodedBytes[i]
    }

    // Add 1
    var carry: UInt8 = 1
    for i in stride(from: encodedBytes.count - 1, through: 0, by: -1) {
      let (sum, overflow) = encodedBytes[i].addingReportingOverflow(carry)
      encodedBytes[i] = sum
      carry = overflow ? 1 : 0
      if carry == 0 {
        break
      }
    }

    return encodedBytes
  }

  /// Initializes a BigInt from a big-endian two's complement byte array.
  ///
  /// - Parameter bytes: A collection of bytes representing a BigInt in big-endian two's complement format.
  ///
  public init<C>(encoded bytes: C) where C: RandomAccessCollection, C: Collection, C.Element == UInt8 {
    guard !bytes.isEmpty else {
      self = .zero
      return
    }

    // Check the sign bit (most significant bit of first byte)
    let isNegative = bytes[bytes.startIndex] & 0x80 != 0

    guard isNegative else {
      // For positive numbers, initialize directly from the bytes
      self.init(isNegative: false, magnitude: BigUInt(encoded: bytes))
      return
    }

    // For negative numbers, apply two's complement to get the magnitude
    var decodedBytes = Array(bytes)

    // Invert all bits
    for i in 0..<decodedBytes.count {
      decodedBytes[i] = ~decodedBytes[i]
    }

    // Add 1
    var carry: UInt8 = 1
    for i in stride(from: decodedBytes.count - 1, through: 0, by: -1) {
      let (sum, overflow) = decodedBytes[i].addingReportingOverflow(carry)
      decodedBytes[i] = sum
      carry = overflow ? 1 : 0
      if carry == 0 {
        break
      }
    }

    self.init(isNegative: true, magnitude: BigUInt(encoded: decodedBytes))
  }
}
