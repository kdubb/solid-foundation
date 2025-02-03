//
//  Pointer+Value.swift
//  Codex
//
//  Created by Kevin Wooten on 1/31/25.
//


extension Value {

  public subscript(pointer: Pointer) -> Value? {
    get {
      var current: Value? = self

      for token in pointer.tokens {

        switch token {

        case .name(let name):
          guard case .object(let object) = current else { return nil }
          current = object[.string(name)]

        case .index(let index):
          guard case .array(let array) = current else { return nil }
          current = array[index]

        case .append:
          return nil
        }
      }

      return current
    }
    set {

      func setMember(tokens: ArraySlice<Pointer.ReferenceToken>, in parent: Value?) -> Value? {
        guard let token = tokens.first else {
          return newValue
        }
        switch (token, parent) {
        case (.name(let name), .object(var object)):
          object[.string(name)] = setMember(tokens: tokens.dropFirst(), in: object[.string(name)])
          return .object(object)
        case (.index(let index), .array(var array)):
          guard index >= 0 && index < array.count else {
            return nil
          }
          if let value = setMember(tokens: tokens.dropFirst(), in: array[index]) {
            array[index] = value
          } else {
            array.remove(at: index)
          }
          return .array(array)
        case (.append, .array(var array)):
          if let value = setMember(tokens: tokens.dropFirst(), in: []) {
            array.append(value)
          }
          return .array(array)
        default:
          break
        }
        return nil
      }

      if let value = setMember(tokens: pointer.tokens.dropFirst(0), in: self) {
        self = value
      }
    }
  }

}
