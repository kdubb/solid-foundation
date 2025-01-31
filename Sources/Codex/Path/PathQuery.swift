//
//  Path+Value.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

public struct PathQuery {

  public static func query(path: Path, from value: Value, functions: [PathQuery.Function] = [], delegate: Delegate? = nil) -> Result {
    let context = Context(root: value, current: .value(value), delegate: delegate)
      .withFunctions(functions)
    return query(segments: path.segments, context: context)
  }

}
