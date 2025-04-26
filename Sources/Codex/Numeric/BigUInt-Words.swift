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
  /// The collection can store a single word "inline" or any number
  /// of words using a standard Swift array.
  public enum Words {

    /// A single word representing the number.
    case inline(UInt)

    /// An array of words representing the number.
    case dynamic([UInt])

    /// The zero value.
    public static let zero = Self.inline(0)
  }

}

extension BigUInt.Words: Equatable {}
extension BigUInt.Words: Hashable {}
extension BigUInt.Words: Sendable {}

extension BigUInt.Words {

  @inlinable
  public var leastSignificant: UInt {
    return self[0]
  }

  @inlinable
  public var leastSignificantZeroCount: Int {
    switch self {
    case .inline(let word):
      return word == 0 ? 1 : 0
    case .dynamic(let words):
      return words.endOfPrefix { $0 == 0 }
    }
  }

  @inlinable
  public var mostSignificant: UInt {
    return self[self.count - 1]
  }

  @inlinable
  public var mostSignificantZeroCount: Int {
    switch self {
    case .inline(let word):
      return word == 0 ? 1 : 0
    case .dynamic(let words):
      let lastNonZeroIndex = words.startOfSuffix { $0 == 0 }
      return words.count - lastNonZeroIndex
    }
  }

}

extension BigUInt.Words: RandomAccessCollection {

  public typealias Element = UInt
  public typealias Index = Int

  @inlinable
  public init(_ source: some Collection<UInt>) {
    var sourceIterator = source.makeIterator()
    guard let first = sourceIterator.next() else {
      fatalError("words is empty")
    }
    guard let second = sourceIterator.next() else {
      // No second word, so we can use an inline representation.
      self = .inline(first)
      return
    }
    var words = [UInt](repeating: 0, count: source.count)
    words[0] = first
    words[1] = second
    var wordIndex = 2
    while let nextWord = sourceIterator.next() {
      words[wordIndex] = nextWord
      wordIndex += 1
    }
    self = .dynamic(words)
  }

  @inlinable
  public init(count: Int) {
    switch count {
    case 0, 1:
      self = .inline(0)
    default:
      self = .dynamic(Array(repeating: 0, count: count))
    }
  }

  @inlinable
  public var count: Int {
    switch self {
    case .inline: return 1
    case .dynamic(let words): return words.count
    }
  }

  @inlinable
  public var startIndex: Int {
    return 0
  }

  @inlinable
  public var endIndex: Int {
    return count
  }

  @inlinable
  public subscript(position: Int) -> UInt {
    get {
      switch self {
      case .inline(let word):
        assert(position == 0, "Index out of bounds")
        return word
      case .dynamic(let words):
        assert(position < words.count, "Index out of bounds")
        return words[position]
      }
    }
    set {
      switch self {
      case .inline:
        assert(position == 0, "Index out of bounds")
        self = .inline(newValue)
      case .dynamic(var words):
        assert(position < words.count, "Index out of bounds")
        words[position] = newValue
        self = .dynamic(words)
      }
    }
  }

  @inlinable
  public mutating func append(_ word: UInt) {
    switch self {
    case .inline(let currentWord):
      self = .dynamic([currentWord, word])
    case .dynamic(var words):
      words.append(word)
      self = .dynamic(words)
    }
  }

  @inlinable
  public func appending(_ word: UInt) -> Self {
    var result = self
    result.append(word)
    return result
  }

  @inlinable
  public mutating func insert(contentsOf source: some Collection<UInt>, at index: Index) {
    assert(index >= startIndex && index <= endIndex, "Index out of bounds")
    switch self {
    case .inline(let currentWord):
      var words = [UInt](repeating: 0, count: source.count + 1)
      words[index == 0 ? words.count - 1 : 0] = currentWord
      for (idx, word) in source.enumerated() {
        words[idx + index] = word
      }
      self = .dynamic(words)
    case .dynamic(var words):
      words.insert(contentsOf: source, at: index)
      self = .dynamic(words)
    }
  }

  @inlinable
  public mutating func removeFirst(_ count: Int = 1) {
    assert(count >= 0 && count <= self.count, "Count out of bounds")
    guard count > 0 else { return }
    switch self {
    case .inline:
      fatalError("Cannot remove element from inline words")
    case .dynamic(var words):
      words.removeFirst(count)
      if words.count == 1 {
        self = .inline(words[0])
      } else {
        self = .dynamic(words)
      }
    }
  }

  @inlinable
  public mutating func removeLast(_ count: Int = 1) {
    assert(count >= 0 && count <= self.count, "Count out of bounds")
    guard count > 0 else { return }
    switch self {
    case .inline:
      fatalError("Cannot remove last element from inline words")
    case .dynamic(var words):
      words.removeLast(count)
      if words.count == 1 {
        self = .inline(words[0])
      } else {
        self = .dynamic(words)
      }
    }
  }

  @inlinable
  public mutating func replaceAll(with newWords: some Collection<UInt>) {
    switch self {
    case .inline:
      if newWords.count == 1, let newWord = newWords.first {
        self = .inline(newWord)
      } else {
        self = .dynamic(Array(newWords))
      }
    case .dynamic(var words):
      if newWords.count == 1, let newWord = newWords.first {
        self = .inline(newWord)
      } else {
        words.replaceSubrange(0..<words.count, with: newWords)
        self = .dynamic(words)
      }
    }
  }
}

extension BigUInt.Words: ExpressibleByArrayLiteral {
  @inlinable
  public init(arrayLiteral elements: UInt...) {
    self.init(elements)
  }
}
