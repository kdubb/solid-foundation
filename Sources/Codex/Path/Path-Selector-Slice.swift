//
//  Path-Selector-Slice.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

extension Path.Selector {

  public struct Slice {
    var start: Int?
    var end: Int?
    var step: Int?
  }

}

extension Path.Selector.Slice : Sendable {}

extension Path.Selector.Slice : Hashable {}
extension Path.Selector.Slice : Equatable {}

extension Path.Selector.Slice : CustomStringConvertible {

  public var description: String {
    var desc = ""
    if let start = start {
      desc += "\(start)"
    }
    desc += ":"
    if let end = end {
      desc += "\(end)"
    }
    if let step = step {
      desc += ":\(step)"
    }
    return desc
  }
}
