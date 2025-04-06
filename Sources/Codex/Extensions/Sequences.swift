//
//  Sequences.swift
//  Codex
//
//  Created by Kevin Wooten on 2/6/25.
//

extension Sequence {

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

  func asArray() -> [Element] {
    return Array(self)
  }

}

extension Sequence where Element: Hashable {

  func asSet() -> Set<Element> {
    return Set(self)
  }

}
