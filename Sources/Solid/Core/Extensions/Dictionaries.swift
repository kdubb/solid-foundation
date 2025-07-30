//
//  Dictionaries.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/23/25.
//

import Collections

extension Dictionary {

  public mutating func updateValue(_ value: Value, forAbsentKey key: Key) {
    guard self.index(forKey: key) == nil else { return }
    self[key] = value
  }

}
