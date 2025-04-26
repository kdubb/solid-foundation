//
//  BigUInt.swift
//  Codex
//
//  Created by Kevin Wooten on 4/16/25.
//

import Algorithms

extension BigUInt {

  /// A specialized collection for storing the words of a `BigUInt`.
  ///
  /// The collection can store up to two words "inline" or any number
  /// of words using a standard Swift array.
  ///
  /// - Note: The inline representations allow for efficient
  ///   initialization of `BigUInt` values for the vast majority
  ///   of cases. When the number of words exceeds the maximum available
  ///   for inline storage (currently 2 words), storage is transitioned
  ///   to a standard Swift Array, accommodating any number of words.
  ///   Once the storage has transitioned to a dynamic array, and the
  ///   cost of allocation has been paid, the representation will never
  ///   revert to being inline. This reduces the cases of vacillating
  ///   between inline and dynamic representations, which can cause
  ///   performance degredation. Additionally, it ensures that "large"
  ///   numbers can change size without undue cost.
  ///
  public enum Words {

    /// A single inline word.
    case inline1(UInt)

    /// Two inline words.
    case inline2(UInt, UInt)

    /// A dynamic array of words.
    case dynamic([UInt])

    /// The zero value.
    public static let zero = Self.inline1(0)
  }

}

extension BigUInt.Words: Equatable {

  /// Returns `true` if the two collections of words are equal.
  ///
  /// - Important: This equality check _must_ not consider
  ///   the representation (inline vs dynamic). Due to the
  ///   fact that dynamic instances are never transitioned back
  ///   to an inline representation, this check must consider
  ///   only the words themselves, not the representation.
  ///   Specifically, there is no single "zero" representation,
  ///   and `.inline(1) == .dynamic([0])` must evaluate to `true`.
  ///
  /// - Parameters:
  ///   - lhs: The left-hand side of the comparison.
  ///   - rhs: The right-hand side of the comparison.
  /// - Returns: `true` if the two words are equal, otherwise `false`.
  ///
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.inline1(let lword), .inline1(let rword)):
      return lword == rword
    case (.inline2(let lword1, let lword2), .inline2(let rword1, let rword2)):
      return lword1 == rword1 && lword2 == rword2
    case (.dynamic(let lwords), .dynamic(let rwords)):
      return lwords == rwords
    case (.dynamic(let lwords), .inline1(let rword)):
      return lwords.count == 1 && lwords[0] == rword
    case (.inline1(let lword), .dynamic(let rwords)):
      return rwords.count == 1 && rwords[0] == lword
    case (.dynamic(let lwords), .inline2(let rword1, let rword2)):
      return lwords.count == 2 && lwords[0] == rword1 && lwords[1] == rword2
    case (.inline2(let lword1, let lword2), .dynamic(let rwords)):
      return rwords.count == 2 && rwords[0] == lword1 && rwords[1] == lword2
    default:
      return false
    }
  }

}

extension BigUInt.Words: Hashable {

  /// Hashes the words in the collection.
  ///
  /// - Important: This hash value _must_ not consider
  ///   the representation (inline vs dynamic). Due to the
  ///   fact that dynamic instances are never transitioned back
  ///   to an inline representation, this hash value must consider
  ///   only the words themselves, not the representation.
  ///   Specifically, there is no single "zero" representation,
  ///   and `.inline(1).hashValue == .dynamic([0]).hashValue` must
  ///   evaluate to `true`.
  ///
  /// - Parameters:
  ///   - hasher: The hasher to use.
  ///
  @inlinable
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .inline1(let word):
      hasher.combine(word)
    case .inline2(let word1, let word2):
      hasher.combine(word1)
      hasher.combine(word2)
    case .dynamic(let words):
      words.forEach { hasher.combine($0) }
    }
  }

}

extension BigUInt.Words: Sendable {}

extension BigUInt.Words {

  /// Returns the least significant word in the collection.
  ///
  @inlinable
  public var leastSignificant: UInt {
    return self[0]
  }

  /// Returns the number of consecutive zero words at the least
  /// significant end of the collection.
  ///
  @inlinable
  public var leastSignificantZeroCount: Int {
    switch self {
    case .inline1(let word):
      return word == 0 ? 1 : 0
    case .inline2(let word1, let word2):
      return word1 == 0 ? (word2 == 0 ? 2 : 1) : 0
    case .dynamic(let words):
      return words.endOfPrefix { $0 == 0 }
    }
  }

  /// Returns the most significant word in the collection.
  ///
  @inlinable
  public var mostSignificant: UInt {
    return self[self.count - 1]
  }

  /// Returns the number of consecutive zero words at the most
  /// significant end of the collection.
  ///
  @inlinable
  public var mostSignificantZeroCount: Int {
    switch self {
    case .inline1(let word):
      return word == 0 ? 1 : 0
    case .inline2(let word1, let word2):
      return word2 == 0 ? (word1 == 0 ? 2 : 1) : 0
    case .dynamic(let words):
      let lastNonZeroIndex = words.startOfSuffix { $0 == 0 }
      return words.count - lastNonZeroIndex
    }
  }

}

extension BigUInt.Words: RandomAccessCollection {

  public typealias Element = UInt
  public typealias Index = Int

  /// Creates a new collection of words from a sequence of words.
  ///
  /// The initializer chooses the most efficient representation,
  /// either inline or dynamic, based on the number of words in
  /// the sequence.
  ///
  /// - Parameters:
  ///   - source: The sequence of words to convert to a collection.
  ///
  @inlinable
  public init(_ source: some Collection<UInt>) {
    var sourceIterator = source.makeIterator()
    guard let first = sourceIterator.next() else {
      fatalError("words is empty")
    }
    guard let second = sourceIterator.next() else {
      // No second word, use inline1 representation
      self = .inline1(first)
      return
    }
    guard let third = sourceIterator.next() else {
      // Only two words, use inline2 representation
      self = .inline2(first, second)
      return
    }
    var words = [UInt](repeating: 0, count: source.count)
    words[0] = first
    words[1] = second
    words[2] = third
    var wordIndex = 3
    while let nextWord = sourceIterator.next() {
      words[wordIndex] = nextWord
      wordIndex += 1
    }
    self = .dynamic(words)
  }

  /// Creates a new collection of words with a given count,
  /// initialized to zeros.
  ///
  /// The initializer chooses the most efficient representation,
  /// either inline or dynamic, based on the number of words in
  /// the sequence.
  ///
  /// - Parameters:
  ///   - count: The number of words in the collection.
  ///
  @inlinable
  public init(count: Int) {
    switch count {
    case 0, 1:
      self = .inline1(0)
    case 2:
      self = .inline2(0, 0)
    default:
      self = .dynamic(Array(repeating: 0, count: count))
    }
  }

  /// Returns the number of words in the collection.
  ///
  @inlinable
  public var count: Int {
    switch self {
    case .inline1: return 1
    case .inline2: return 2
    case .dynamic(let words): return words.count
    }
  }

  /// Returns the start index of the collection.
  ///
  @inlinable
  public var startIndex: Int {
    return 0
  }

  /// Returns the end index of the collection.
  ///
  @inlinable
  public var endIndex: Int {
    return count
  }

  /// Returns or assigns the word at the given index.
  ///
  /// - Precondition: The index must be within bounds.
  ///
  @inlinable
  public subscript(position: Int) -> UInt {
    get {
      switch self {
      case .inline1(let word):
        assert(position == 0, "Index out of bounds")
        return word
      case .inline2(let word1, let word2):
        assert(position < 2, "Index out of bounds")
        return position == 0 ? word1 : word2
      case .dynamic(let words):
        assert(position < words.count, "Index out of bounds")
        return words[position]
      }
    }
    set {
      switch self {
      case .inline1:
        assert(position == 0, "Index out of bounds")
        self = .inline1(newValue)
      case .inline2(var word1, var word2):
        assert(position < 2, "Index out of bounds")
        if position == 0 {
          word1 = newValue
        } else {
          word2 = newValue
        }
        self = .inline2(word1, word2)
      case .dynamic(var words):
        assert(position < words.count, "Index out of bounds")
        words[position] = newValue
        self = .dynamic(words)
      }
    }
  }

  /// Appends a word to the collection.
  ///
  /// - Parameters:
  ///   - word: The word to append.
  ///
  @inlinable
  public mutating func append(_ word: UInt) {
    switch self {
    case .inline1(let currentWord):
      self = .inline2(currentWord, word)
    case .inline2(let word1, let word2):
      self = .dynamic([word1, word2, word])
    case .dynamic(var words):
      words.append(word)
      self = .dynamic(words)
    }
  }

  /// Returns a new collection with the given word appended.
  ///
  /// - Parameters:
  ///   - word: The word to append.
  ///
  @inlinable
  public func appending(_ word: UInt) -> Self {
    var result = self
    result.append(word)
    return result
  }

  /// Inserts a sequence of words into the collection at the given index.
  ///
  /// - Parameters:
  ///   - source: The sequence of words to insert.
  ///   - index: The index at which to insert the words.
  ///
  @inlinable
  public mutating func insert(contentsOf source: some Collection<UInt>, at index: Index) {
    guard source.count > 0 else { return }
    assert(index >= startIndex && index <= endIndex, "Index out of bounds")

    switch self {
    case .inline1(let currentWord):
      guard source.count > 1 else {
        let newWord = source[source.startIndex]
        let word1 = index == 0 ? newWord : currentWord
        let word2 = index == 0 ? currentWord : newWord
        self = .inline2(word1, word2)
        return
      }

      var words = [UInt](repeating: 0, count: source.count + 1)
      words[index == 0 ? words.count - 1 : 0] = currentWord
      for (idx, word) in source.enumerated() {
        words[idx + index] = word
      }
      self = .dynamic(words)

    case .inline2(let word1, let word2):
      var words = [UInt](repeating: 0, count: source.count + 2)
      words[index == 0 ? words.count - 2 : 0] = word1
      words[index == 0 ? words.count - 1 : 1] = word2
      for (idx, word) in source.enumerated() {
        words[idx + index] = word
      }
      self = .dynamic(words)

    case .dynamic(var words):
      words.insert(contentsOf: source, at: index)
      self = .dynamic(words)
    }
  }

  /// Removes the first `count` words from the collection.
  ///
  /// - Parameters:
  ///   - count: The number of words to remove.
  ///
  @inlinable
  public mutating func removeFirst(_ count: Int = 1) {
    assert(count >= 0 && count <= self.count, "Count out of bounds")
    assert(count < self.count, "Cannot remove all words")
    guard count > 0 else { return }
    switch self {
    case .inline1:
      fatalError("Cannot remove all words")

    case .inline2(_, let secondWord):
      assert(count == 1)
      self = .inline1(secondWord)

    case .dynamic(var words):
      // Stay dynamic... not worth re-inlining after array allocation.
      words.removeFirst(count)
      self = .dynamic(words)
    }
  }

  /// Removes the last `count` words from the collection.
  ///
  /// - Parameters:
  ///   - count: The number of words to remove.
  ///
  @inlinable
  public mutating func removeLast(_ count: Int = 1) {
    assert(count >= 0 && count <= self.count, "Count out of bounds")
    assert(count < self.count, "Cannot remove all words")
    guard count > 0 else { return }
    switch self {
    case .inline1:
      fatalError("Cannot remove all words")

    case .inline2(let firstWord, _):
      assert(count == 1)
      self = .inline1(firstWord)

    case .dynamic(var words):
      // Stay dynamic... not worth re-inlining after array allocation.
      words.removeLast(count)
      self = .dynamic(words)
    }
  }

  /// Replaces all words in the collection with a new sequence of words.
  ///
  /// - Note: It is important to use `replaceAll(with:)` instead of
  ///   `self = Self(newWords)` to avoid unnecessarily allocating
  ///   a new dynamic representation and copying the elements. Instead,
  ///   this method will attempt to use the same representation as the
  ///   current collection; including re-using an already dynamically
  ///   allocated array.
  ///
  /// - Parameters:
  ///   - newWords: The new sequence of words to replace the existing words.
  ///
  @inlinable
  public mutating func replaceAll<C: Collection>(with newWords: C) where C.Element == UInt, C.Index == Int {
    guard newWords.count > 0 else {
      fatalError("Cannot replace all words with an empty collection")
    }
    switch self {
    case .inline1, .inline2:
      switch newWords.count {
      case 1:
        self = .inline1(newWords[0])
      case 2:
        self = .inline2(newWords[0], newWords[1])
      default:
        self = .dynamic(Array(newWords))
      }

    case .dynamic(var words):
      // Stay dynamic... not worth re-inlining after array allocation.
      words.replaceSubrange(0..<words.count, with: newWords)
      self = .dynamic(words)
    }
  }
}

extension BigUInt.Words: ExpressibleByArrayLiteral {
  @inlinable
  public init(arrayLiteral elements: UInt...) {
    self.init(elements)
  }
}
