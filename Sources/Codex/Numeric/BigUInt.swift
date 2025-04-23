//
//  BigUInt.swift
//  Codex
//
//  Created by Kevin Wooten on 4/16/25.
//


/// arbitrary‑precision unsigned integer.
///
/// An arbitrary-precision unsigned integer that implements Swift's numeric protocols.
/// The value is backed by a little‑endian array of machine words (`UInt`).
/// The array never contains leading‑zero words *unless* the value is exactly zero
/// (represented by a single `0` word).
///
public struct BigUInt {

  internal static let wordBits = UInt.bitWidth
  internal static let wordMask = UInt.max

  internal static let wordBitsDW = UInt128(Self.wordBits)
  internal static let wordMaskDW = UInt128(Self.wordMask)

  internal static let msbShift = UInt.bitWidth - 1

  public private(set) var words: Words

  public init() {
    self.words = [0]
  }

  internal init<S>(words: S) where S: Sequence, S.Element == UInt {
    self.init(words: Words(words))
  }

  internal init(words: Words) {
    precondition(words.count > 0, "words must not be empty")
    self.words = words
    normalize()
  }

  // Remove leading‑zero words so that `words.last! != 0`, except for zero.
  @inline(__always) internal mutating func normalize() {
    while words.count > 1 && words.mostSignificant == 0 { words.removeLast() }
  }

  internal var isZero: Bool {
    return words.count == 1 && words.leastSignificant == 0
  }

  public static let zero = Self()
  public static let one = Self(words: [1])
  public static let two = Self(words: [2])
  public static let ten = Self(words: [10])
}

extension BigUInt: Sendable {}
extension BigUInt: Equatable {}
extension BigUInt: Hashable {}

extension BigUInt: Numeric, BinaryInteger, UnsignedInteger {

  public typealias Words = ContiguousArray<UInt>

  public typealias Magnitude = BigUInt

  public static let isSigned: Bool = false

  // MARK - Integer initializers

  public init?<T>(exactly source: T) where T: BinaryInteger {
    guard source >= 0 else { return nil }
    self.init(words: Words(source.magnitude.words))
  }

  public init<T>(_ source: T) where T: BinaryInteger {
    precondition(source >= 0, "negative integer '\(source)' overflows when stored into unsigned type 'BigUInt'")
    self.init(words: Words(source.magnitude.words))
  }

  public init<T>(truncatingIfNeeded source: T) where T: BinaryInteger {
    let totalBits = source.bitWidth
    guard totalBits != 0 else {
      self = .zero
      return
    }
    let neededWords = (totalBits + Self.wordBits - 1) / Self.wordBits
    var w = Words(repeating: 0, count: neededWords)
    // copy the low‑order words verbatim (little‑endian)
    for (i, word) in source.words.enumerated() where i < neededWords {
      w[i] = UInt(word)
    }
    // mask off unused high bits in the last word so that only `totalBits` remain
    let highBits = totalBits % Self.wordBits
    if highBits != 0 {
      let mask = (UInt(1) << UInt(highBits)) - 1
      w[neededWords - 1] &= mask
    }
    self.init(words: w)
  }

  public init<T>(clamping source: T) where T: BinaryInteger {
    if source < 0 {
      self = .zero
    } else {
      self.init(source)
    }
  }

  // MARK - Floating point initializers

  public init<T>(_ source: T) where T: BinaryFloatingPoint {
    precondition(
      source.isFinite,
      "\(String(describing: type(of: source))) value cannot be converted to BigUInt because it is either infinite or NaN"
    )
    precondition(source >= 0, "Negative value is not representable")

    guard source != 0 else {
      self = .zero
      return
    }

    // Decompose: value = significand × 2^exponent (significand in [1,2))
    let exponent = source.exponent
    let significand = source.significand

    // Initialize with the normalized significand (a value between 1 and 2)
    self = Self(UInt(significand * T(1 << T.significandBitCount)))

    // Scale by the exponent, accounting for the bits we've already used
    let bitsToShift = Int(exponent) - T.significandBitCount

    if bitsToShift > 0 {
      self.shiftLeft(bitsToShift)
    } else if bitsToShift < 0 {
      self.shiftRight(-bitsToShift)
    }
  }

  /// Exact conversion from a floating‑point value.
  ///
  /// Converts the floating point value to an exact representation if it can
  /// be represented exactly. Fails if the value is NaN, ±∞, negative, or not
  /// an integer in base‑10.
  public init?<T: BinaryFloatingPoint>(exactly source: T) {
    // must be finite, non‑negative, and an *integer*
    guard source.isFinite,
      source >= 0,
      source.rounded(.towardZero) == source
    else {
      return nil
    }

    self.init(source)
  }

  // MARK - Properties

  public var magnitude: Magnitude {
    return self
  }

  public var bitWidth: Int {
    return (words.count - 1) * Self.wordBits + (Self.wordBits - words.mostSignificant.leadingZeroBitCount)
  }

  public var leadingZeroBitCount: Int {
    return 0
  }

  public var trailingZeroBitCount: Int {
    for (i, w) in words.enumerated() where w != 0 {
      return i * Self.wordBits + w.trailingZeroBitCount
    }
    return 0
  }

  // MARK: - Arithmetic

  public static func + (lhs: Self, rhs: Self) -> Self {
    var result = Words()
    let count = Swift.max(lhs.words.count, rhs.words.count)
    var carry: UInt = 0
    for i in 0..<count {
      let a = i < lhs.words.count ? lhs.words[i] : 0
      let b = i < rhs.words.count ? rhs.words[i] : 0
      let (sum1, ov1) = a.addingReportingOverflow(b)
      let (sum2, ov2) = sum1.addingReportingOverflow(carry)
      result.append(sum2)
      carry = (ov1 ? 1 : 0) + (ov2 ? 1 : 0)
    }
    if carry != 0 { result.append(carry) }
    return Self(words: result)
  }

  public static func += (lhs: inout Self, rhs: Self) {
    lhs = lhs + rhs
  }

  public static func - (lhs: Self, rhs: Self) -> Self {
    precondition(lhs >= rhs, "arithmetic operation '\(lhs) - \(rhs)' (on type 'BigUInt') results in an underflow")
    var result = Words()
    var borrow: UInt = 0
    for i in 0..<lhs.words.count {
      let a = lhs.words[i]
      let b = i < rhs.words.count ? rhs.words[i] : 0
      let (sub1, ov1) = a.subtractingReportingOverflow(b)
      let (sub2, ov2) = sub1.subtractingReportingOverflow(borrow)
      result.append(sub2)
      borrow = (ov1 ? 1 : 0) + (ov2 ? 1 : 0)
    }
    return Self(words: result)
  }

  public static func -= (lhs: inout Self, rhs: Self) {
    lhs = lhs - rhs
  }

  public static func * (lhs: Self, rhs: Self) -> Self {
    if lhs.isZero || rhs.isZero { return Self.zero }
    // Ensure lhs is the longer number
    let (a, b) = lhs.words.count >= rhs.words.count ? (lhs, rhs) : (rhs, lhs)
    var result = Words(repeating: 0, count: a.words.count + b.words.count)
    for i in 0..<a.words.count {
      var carry: UInt = 0
      for j in 0..<b.words.count {
        let idx = i + j
        let (hi, lo) = a.words[i].multipliedFullWidth(by: b.words[j])

        // add lo to current limb
        let (sumLo, ovLo) = result[idx].addingReportingOverflow(lo)

        // add hi + old carry + overflow‑from‑lo to next limb
        let hiPlusCarry = hi &+ carry &+ (ovLo ? 1 : 0)
        let (sumHi, ovHi) =
          result[idx + 1].addingReportingOverflow(hiPlusCarry)
        result[idx] = sumLo
        result[idx + 1] = sumHi
        carry = ovHi ? 1 : 0    // propagate overflow
      }

      // propagate remaining carry
      var k = i + b.words.count
      while carry != 0 {
        print("Carry: \(lhs) * \(rhs)")
        let (s, ov) = result[k].addingReportingOverflow(carry)
        result[k] = s
        carry = ov ? 1 : 0
        k += 1
      }
    }
    return Self(words: result)
  }

  public static func *= (lhs: inout Self, rhs: Self) {
    lhs = lhs * rhs
  }

  private static let divBeta = UInt128(UInt64.max) + 1

  // Long division (Knuth D, radix 2⁶⁴)
  public func quotientAndRemainder(dividingBy v: Self) -> (quotient: Self, remainder: Self) {
    precondition(!v.isZero, "division by zero")

    // Knuth D: m >= n
    if self < v { return (.zero, self) }
    // Knuth D: n >= 2
    guard v.words.count >= 2 else {
      let d = v.words.leastSignificant
      var q = Words(repeating: 0, count: words.count)
      var r: UInt = 0
      for i in stride(from: words.count &- 1, through: 0, by: -1) {
        (q[i], r) = d.dividingFullWidth((high: r, low: words[i]))
      }
      return (Self(words: q), Self(r))
    }

    let m = self.words.count    // dividend length
    let n = v.words.count    // divisor length

    // ────────────────────────────────────────────────────────────────────
    // D1  normalise  (shift so v₁ ≥ β/2)
    let shift = v.words.mostSignificant.leadingZeroBitCount
    var un = (self << shift).words + [0]
    let vn = (v << shift).words

    var q = Words(repeating: 0, count: m - n + 1)    // final quotient

    // ────────────────────────────────────────────────────────────────────
    // D2 … D7
    for j in stride(from: m - n, through: 0, by: -1) {

      let un0 = UInt128(un[j + n])
      let un1 = UInt128(un[j + n - 1])
      let un2 = UInt128(un[j + n - 2])
      let vn1 = UInt128(vn[n - 1])
      let vn2 = UInt128(vn[n - 2])

      // ---------- D3  estimate q̂
      var (qHat, rHat) = (un0 << Self.wordBits | un1).quotientAndRemainder(dividingBy: vn1)

      // correct if q̂ = β or q̂·v₂ > (r̂·β + u₀)
      while (qHat == Self.divBeta) || (qHat * vn2 > (rHat * Self.divBeta + un2)) {
        qHat -= 1
        rHat += vn1
        if rHat >= Self.divBeta { break }    // at most one more loop
      }

      // ---------- D4  multiply‑subtract
      var borrow: UInt = 0
      for i in 0..<n {
        let prod = UInt128(vn[i]) * qHat    // 128‑bit product
        let prodLo = UInt(prod & UInt128(UInt.max))    // low 64 product
        let prodHi = UInt(prod >> 64)    // high 64 product

        //  ui ← ui - lo - borrow
        let (u1, ov1) = un[i + j].subtractingReportingOverflow(prodLo)
        let (u2, ov2) = u1.subtractingReportingOverflow(borrow)
        un[i + j] = u2
        borrow = prodHi &+ (ov1 ? 1 : 0) &+ (ov2 ? 1 : 0)    // 0,1, or 2
      }

      // top word
      let (top, ov3) = un[j + n].subtractingReportingOverflow(borrow)
      un[j + n] = top
      var qWord = UInt(qHat & UInt128(UInt.max))

      // ---------- D5  q̂ one too large →  add divisor back
      if ov3 {
        qWord &-= 1
        var carry: UInt = 0
        for i in 0..<n {
          let (s1, ov1) = un[i + j].addingReportingOverflow(vn[i])
          let (s2, ov2) = s1.addingReportingOverflow(carry)
          un[i + j] = s2
          carry = (ov1 ? 1 : 0) &+ (ov2 ? 1 : 0)
        }
        un[j + n] &+= carry
      }
      q[j] = qWord
    }

    // ---------- D8  un‑normalise remainder, normalise quotient
    var rem = Self(words: un)
    rem.shiftRight(shift)
    rem.normalize()

    var quo = Self(words: q)
    quo.normalize()

    return (quo, rem)
  }

  public func remainder(dividingBy divisor: Self) -> Self {
    return quotientAndRemainder(dividingBy: divisor).remainder
  }

  public static func / (lhs: Self, rhs: Self) -> Self {
    return lhs.quotientAndRemainder(dividingBy: rhs).quotient
  }

  public static func /= (lhs: inout Self, rhs: Self) {
    lhs = lhs / rhs
  }

  public static func % (lhs: Self, rhs: Self) -> Self {
    return lhs.remainder(dividingBy: rhs)
  }

  public static func %= (lhs: inout Self, rhs: Self) {
    lhs = lhs % rhs
  }

  public static prefix func ~ (x: Self) -> Self {
    if x.isZero { return .zero }
    // 2^n - 1 - x
    var mask = Self.one
    mask.shiftLeft(x.bitWidth)
    mask -= .one
    return mask - x
  }

  /// Raises the value to the specified power.
  ///
  /// - Parameter power: The power to raise the value to.
  /// - Returns: The result of raising the value to the specified power.
  ///
  public func raised(to power: Int) -> Self {
    precondition(power >= 0, "Negative powers are not supported")
    if power == 0 { return .one }
    if power == 1 { return self }

    var result = Self.one
    var base = self
    var exp = power

    while exp > 0 {
      if (exp & 1) == 1 {    // low bit set → multiply
        result *= base
      }
      exp >>= 1    // shift exponent
      if exp != 0 {    // square only if more bits remain
        base *= base
      }
    }

    return result
  }

  /// Returns the greatest common divisor of this value and another value.
  /// - Parameter other: The other value
  /// - Returns: The greatest common divisor
  public func greatestCommonDivisor(_ other: Self) -> Self {
    var a = self
    var b = other
    while !b.isZero {
      let temp = b
      b = a % b
      a = temp
    }
    return a
  }

  /// Returns the least common multiple of this value and another value.
  /// - Parameter other: The other value
  /// - Returns: The least common multiple
  public func lowestCommonMultiple(_ other: Self) -> Self {
    if isZero || other.isZero {
      return .zero
    }
    return (self / greatestCommonDivisor(other)) * other
  }

  // MARK: - Bitwise

  internal static func bitwiseOperation(lhs: Self, rhs: Self, _ op: (UInt, UInt) -> UInt) -> Self {
    let count = Swift.max(lhs.words.count, rhs.words.count)
    var result = Words(repeating: 0, count: count)
    for i in 0..<count {
      let a = i < lhs.words.count ? lhs.words[i] : 0
      let b = i < rhs.words.count ? rhs.words[i] : 0
      result[i] = op(a, b)
    }
    return Self(words: result)
  }

  public static func & (lhs: Self, rhs: Self) -> Self {
    return bitwiseOperation(lhs: lhs, rhs: rhs, &)
  }

  public static func &= (lhs: inout Self, rhs: Self) {
    lhs = lhs & rhs
  }

  public static func | (lhs: Self, rhs: Self) -> Self {
    return bitwiseOperation(lhs: lhs, rhs: rhs, |)
  }

  public static func |= (lhs: inout Self, rhs: Self) {
    lhs = lhs | rhs
  }

  public static func ^ (lhs: Self, rhs: Self) -> Self {
    return bitwiseOperation(lhs: lhs, rhs: rhs, ^)
  }

  public static func ^= (lhs: inout Self, rhs: Self) {
    lhs = lhs ^ rhs
  }

  // MARK: - Shifts

  internal mutating func shiftLeft(_ k: Int) {
    guard k > 0 else { return }
    let wordShift = k / UInt.bitWidth
    let bitShift = k % UInt.bitWidth
    if bitShift == 0 {
      words.insert(contentsOf: repeatElement(0, count: wordShift), at: 0)
      return
    }
    var carry: UInt = 0
    for i in 0..<words.count {
      let newCarry = words[i] >> (UInt.bitWidth - bitShift)
      words[i] = (words[i] << bitShift) | carry
      carry = newCarry
    }
    if carry != 0 { words.append(carry) }
    if wordShift > 0 { words.insert(contentsOf: repeatElement(0, count: wordShift), at: 0) }
  }

  internal mutating func shiftRight(_ k: Int) {
    guard k > 0 else { return }
    let wordShift = k / UInt.bitWidth
    let bitShift = k % UInt.bitWidth
    if wordShift >= words.count {
      self = .zero
      return
    }
    words.removeFirst(wordShift)
    if bitShift == 0 { return }
    var carry: UInt = 0
    for i in stride(from: words.count - 1, through: 0, by: -1) {
      let newCarry = words[i] << (UInt.bitWidth - bitShift)
      words[i] = (words[i] >> bitShift) | carry
      carry = newCarry
    }
    normalize()
  }

  public static func << <RHS>(lhs: Self, rhs: RHS) -> Self where RHS: BinaryInteger {
    var result = lhs
    result.shiftLeft(Int(rhs))
    return result
  }

  public static func <<= <RHS>(lhs: inout Self, rhs: RHS) where RHS: BinaryInteger {
    lhs = lhs << rhs
  }

  public static func >> <RHS>(lhs: Self, rhs: RHS) -> Self where RHS: BinaryInteger {
    var result = lhs
    result.shiftRight(Int(rhs))
    return result
  }

  public static func >>= <RHS>(lhs: inout Self, rhs: RHS) where RHS: BinaryInteger {
    lhs = lhs >> rhs
  }

}

// MARK: - Comparison

extension BigUInt {

  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.words == rhs.words
  }

}

extension BigUInt: Comparable {

  public static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.words.count != rhs.words.count {
      return lhs.words.count < rhs.words.count
    }
    for i in stride(from: lhs.words.count - 1, through: 0, by: -1) where lhs.words[i] != rhs.words[i] {
      return lhs.words[i] < rhs.words[i]
    }
    return false
  }

}

// MARK: - Literals

extension BigUInt: ExpressibleByIntegerLiteral {

  public init(integerLiteral value: StaticBigInt) {
    precondition(value.signum() >= 0, "BigUInt cannot represent a negative integer literal")
    let bitWidth = value.bitWidth
    guard bitWidth != 0 else {
      self = .zero
      return
    }
    let wordCount = (bitWidth + Self.wordBits - 1) / Self.wordBits
    var words: Words = Words(repeating: 0, count: wordCount)
    for i in 0..<wordCount {
      words[i] = UInt(value[i])
    }
    self.init(words: words)
  }

}

// MARK: - Strings

extension BigUInt: LosslessStringConvertible {

  public init?(_ description: some StringProtocol) {
    guard !description.isEmpty else {
      return nil
    }

    var start = description.startIndex
    if description[start] == "+" { start = description.index(after: start) }
    guard start < description.endIndex else {
      return nil
    }

    var value: Self = .zero
    for ch in description[start...] {
      guard ch.isASCII, let d = ch.wholeNumberValue else {
        return nil
      }
      value *= 10
      value += Self(UInt(d))
    }

    self = value
  }

}

extension BigUInt: CustomStringConvertible, CustomDebugStringConvertible {

  /// Decimal representation (no leading zeros, "0" for zero).
  public var description: String {
    // 0 and single‑limb fast paths
    guard !isZero else { return "0" }
    guard words.count > 1 else { return String(words.leastSignificant) }

    // Split the number into base‑10¹⁸ chunks
    let base: UInt = 1_000_000_000_000_000_000
    var chunks: [String] = []
    var n = self
    while !n.isZero {
      let (q, r) = n.quotientAndRemainder(dividingBy: BigUInt(base))
      chunks.append(String(r))
      n = q
    }

    // Most‑significant chunk is already un‑padded; pad the rest to 18 digits
    var result = chunks.removeLast()
    for chunk in chunks.reversed() {
      result += String(repeating: "0", count: 18 - chunk.count) + chunk
    }
    return result
  }

  public var debugDescription: String {
    return "BigUInt(\(self))"
  }

}

extension BigUInt.Words {

  internal var leastSignificant: UInt {
    return self[0]
  }

  internal var mostSignificant: UInt {
    return self[self.count - 1]
  }

}

// MARK: - Encode/Decode

extension BigUInt {

  /// Encodes the BigUInt as a byte array in big-endian format.
  ///
  /// - Returns: A byte array representing the BigUInt in big-endian format.
  ///
  public func encode() -> [UInt8] {

    var result: [UInt8] = []
    for i in stride(from: words.count - 1, through: 0, by: -1) {
      let word = words[i]
      for j in stride(from: UInt.bitWidth - 8, through: 0, by: -8) {
        result.append(UInt8((word >> j) & 0xFF))
      }
    }

    // Strip leading 0s (they're not meaningful in big-endian bignum)
    while result.first == 0 && result.count > 1 {
      result.removeFirst()
    }

    return result
  }

  public init<C>(encoded bytes: C) where C: RandomAccessCollection, C: Collection, C.Element == UInt8 {
    let wordBytes = UInt.bitWidth / 8
    let wordCount = (bytes.count + (wordBytes - 1)) / wordBytes
    var words = Words(repeating: 0, count: wordCount)

    let fill = (wordBytes - (bytes.count % wordBytes)) % wordBytes
    let msWordIndex = words.endIndex - 1
    var wordIndex = msWordIndex
    var byteIndex = bytes.startIndex

    while wordIndex >= words.startIndex {
      var word: UInt = 0
      let currentWordBytes = wordIndex == msWordIndex ? wordBytes - fill : wordBytes
      let wordEndIndex = bytes.index(byteIndex, offsetBy: currentWordBytes)
      while byteIndex < wordEndIndex {
        word <<= 8
        word |= UInt(bytes[byteIndex])
        byteIndex = bytes.index(after: byteIndex)
      }
      words[wordIndex] = word
      wordIndex = words.index(before: wordIndex)
    }

    self.init(words: words)
  }

}

// MARK: - String Extensions

extension String {
  /// Creates a new string from a ``BigUInt`` value.
  /// - Parameter integer: The value to convert to a string.
  public init(_ integer: BigUInt) {
    self = integer.description
  }
}
