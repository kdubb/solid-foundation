//
//  Path+Pointer.swift
//  Codex
//
//  Created by Kevin Wooten on 2/3/25.
//

extension Path {

  /// Translates this path into a JSON Pointer.
  ///
  /// If this ``Path`` is a "normal" path, it will be converted to an
  /// equivalent ``Pointer``.
  ///
  /// - Returns: A ``Pointer`` if this path is a "normal" path, otherwise `nil`.
  ///
  public func pointer() -> Pointer? {
    let tokens: [Pointer.ReferenceToken]? = normalized?
      .map { segment in
        switch segment {
        case .name(let name): .name(name)
        case .index(let index): .index(index)
        }
      }
    guard let tokens else {
      return nil
    }
    return Pointer(tokens: tokens)
  }

}
