//
//  Collections.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/15/25.
//

import Foundation

package extension Collection {

  func nilIfEmpty() -> Self? {
    isEmpty ? nil : self
  }

  func joinedToList(prefix: String) -> String where Element: CustomStringConvertible {
    switch count {
    case 1:
      return "\(prefix) '\(self[startIndex])'"
    case 2:
      return "\(prefix) \(map { "'\($0)'" }.joined(separator: " or "))"
    default:
      let listItems = dropLast().map { "'\($0)'" }.joined(separator: ", ")
      let lastItem = self[index(endIndex, offsetBy: -1)]
      return "\(prefix) \(listItems) or '\(lastItem)'"
    }
  }

}
