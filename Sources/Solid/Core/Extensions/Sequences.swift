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
