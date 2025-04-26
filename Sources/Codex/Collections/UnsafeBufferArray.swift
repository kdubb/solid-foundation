//
//  UnsafeBufferArray.swift
//  Codex
//
//  Created by Kevin Wooten on 4/16/25.
//

import Algorithms
import Collections

/// A wrapper around `UnsafeMutableBufferPointer` that provides a mutable collection interface.
///
/// This struct is designed to manage a buffer of elements, allowing for dynamic resizing similar to a standard
/// Swift array up to the buffer's count.
///
/// Element access is bounds checked accoring the the current size of the array. If using one of the temporary
/// initlaizers that provides manages an uninitialized buffer
/// (e.g. ``Code/withUnsafeTemporaryBufferArray(repeating:count:_:)``) , you must use
/// ``UnsafeBufferArray/resize(to:)`` to enable access to the uninitialized elements.
///
@usableFromInline
internal struct UnsafeBufferArray<Element> {

  public private(set) var buffer: UnsafeMutableBufferPointer<Element>
  public private(set) var count: Int

  public var capacity: Int { buffer.count }

  @usableFromInline
  init(buffer: UnsafeMutableBufferPointer<Element>, count: Int) {
    precondition(buffer.count >= count, "Buffer count must be greater than or equal to count")
    self.buffer = buffer
    self.count = count
  }

  @usableFromInline
  mutating func resize(to newCount: Int) {
    precondition(newCount <= buffer.count, "New count must be less than or equal to buffer capacity")
    count = newCount
  }

}

extension UnsafeBufferArray: RandomAccessCollection {

  public typealias Index = Int

  public var startIndex: Int { 0 }
  public var endIndex: Int { count }

  public subscript(position: Int) -> Element {
    get {
      assert(position >= 0 && position < count, "Index out of bounds")
      return buffer[position]
    }
    set {
      assert(position >= 0 && position < count, "Index out of bounds")
      buffer[position] = newValue
      count = Swift.max(count, position + 1)
    }
  }

}

extension UnsafeBufferArray: MutableCollection {}

extension UnsafeBufferArray: RangeReplaceableCollection {

  public init() {
    self.init(buffer: UnsafeMutableBufferPointer(start: nil, count: 0), count: 0)
  }

  public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C)
  where C: Collection, Element == C.Element {
    // Handle empty cases first
    guard !subrange.isEmpty || !newElements.isEmpty else { return }

    // Calculate new count after replacement
    let replacementCount = newElements.count
    let diff = replacementCount - subrange.count
    let newCount = count + diff
    precondition(newCount <= buffer.count, "New elements would exceed buffer capacity")

    // Shift remaining elements left or right
    buffer[subrange.upperBound + diff..<count + diff].initializeAll(fromContentsOf: buffer[subrange.upperBound..<count])

    // Copy new elements into place
    buffer[subrange.lowerBound..<subrange.lowerBound + replacementCount].initializeAll(fromContentsOf: newElements)

    // Update count
    count = newCount
  }

}

@inline(__always)
internal func withUnsafeTemporaryBufferArray<Element, R>(
  repeating: Element,
  count: Int,
  _ body: (inout UnsafeBufferArray<Element>) throws -> R
) rethrows -> R {
  try withUnsafeTemporaryAllocation(of: Element.self, capacity: count) { buffer in
    buffer.initialize(repeating: repeating)
    var array = UnsafeBufferArray(buffer: buffer, count: 0)
    return try body(&array)
  }
}

@inline(__always)
internal func withUnsafeTemporaryBufferArray<Element, R>(
  from source: some Collection<Element>,
  additional: (repeating: Element, count: Int)? = nil,
  _ body: (inout UnsafeBufferArray<Element>) throws -> R
) rethrows -> R {
  try withUnsafeTemporaryAllocation(of: Element.self, capacity: source.count + (additional?.count ?? 0)) { buffer in
    if let (additionalElement, additionalCount) = additional {
      let unitializedIndex = buffer.initialize(fromContentsOf: source)
      buffer[unitializedIndex...]
        .initializeAll(fromContentsOf: repeatElement(additionalElement, count: additionalCount))
    } else {
      buffer.initializeAll(fromContentsOf: source)
    }
    var array = UnsafeBufferArray(buffer: buffer, count: source.count)
    return try body(&array)
  }
}

@inline(__always)
internal func withUnsafeTemporaryBufferArray<R>(count: Int, _ body: (inout UnsafeBufferArray<UInt>) -> R) -> R {
  return withUnsafeTemporaryAllocation(of: UInt.self, capacity: count) { wordBuffer in
    var array = wordBuffer.extractingArray(0..<count)
    return body(&array)
  }
}

@inline(__always)
internal func withUnsafeTemporaryBufferArrays<Element, R>(
  counts: (Int, Int),
  body: (inout UnsafeBufferArray<Element>, inout UnsafeBufferArray<Element>) -> R
) -> R {
  return withUnsafeTemporaryAllocation(of: Element.self, capacity: counts.0 + counts.1) { wordBuffer in
    var a = wordBuffer.extractingArray(0..<counts.0)
    var b = wordBuffer.extractingArray(counts.0..<(counts.0 + counts.1))
    return body(&a, &b)
  }
}

extension UnsafeMutableBufferPointer {

  @inlinable
  internal func extractingArray(_ range: Range<Index>) -> UnsafeBufferArray<Element> {
    return UnsafeBufferArray(buffer: extracting(range), count: 0)
  }

}
