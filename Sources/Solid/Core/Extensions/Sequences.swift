//
//  Sequences.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/6/25.
//

package extension Sequence {

  func anySatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
    for element in self where try predicate(element) {
      return true
    }
    return false
  }

  func noneSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
    for element in self where try predicate(element) {
      return false
    }
    return true
  }

}

package extension Sequence where Element: Hashable {

  func unique() -> some Sequence<Element> {
    return Set(self)
  }

}

public extension Sequence where Element: Hashable {

  func associated<V>(with valueTransform: (Element) -> V) -> [Element: V] {
    map { (key: $0, value: valueTransform($0)) }.associated()
  }

}

public extension Sequence {

  func associated<K: Hashable>(by keyTransform: (Element) -> K) -> [K: Element] {
    map { (key: keyTransform($0), value: $0) }.associated()
  }

  func associated<K: Hashable, V>(by keyTransform: (Element) -> K, with valueTransform: (Element) -> V) -> [K: V] {
    map { (key: keyTransform($0), value: valueTransform($0)) }.associated()
  }

}

public extension Sequence {

  func associated<K: Hashable, V>() -> [K: V] where Element == (K, V) {
    return Dictionary<K, V>(uniqueKeysWithValues: self)
  }

}

public extension Sequence {

  func sorted<K: Comparable>(by keySelector: KeyPath<Element, K>) -> [Element] {
    sorted { $0[keyPath: keySelector] < $1[keyPath: keySelector] }
  }

}
