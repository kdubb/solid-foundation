//
//  Dictionaries.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/23/25.
//


extension Sequence {

  public func associate<Value>(with valueSelector: (Element) -> Value) -> [Element: Value] {
    reduce(into: [:]) { result, element in result[element] = valueSelector(element) }
  }

  public func associate<Key>(by keySelector: (Element) -> Key) -> [Key: Element] {
    reduce(into: [:]) { result, element in result[keySelector(element)] = element }
  }

  public func associate<Key, Value>(
    by keySelector: (Element) -> Key,
    with valueSelector: (Element) -> Value
  ) -> [Key: Value] where Key: Hashable {
    reduce(into: [:]) { result, element in result[keySelector(element)] = valueSelector(element) }
  }

}
