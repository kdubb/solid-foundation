//
//  Path+Pointer.swift
//  Codex
//
//  Created by Kevin Wooten on 2/3/25.
//

extension Path {

  public func pointer() -> Pointer {
    let tokens: [Pointer.ReferenceToken] = normalized.map { segment in
      switch segment {
      case .name(let name): .name(name)
      case .index(let index): .index(index)
      }
    }
    return Pointer(tokens: tokens)
  }

}
