//
//  PathQuery+Value.swift
//  Codex
//
//  Created by Kevin Wooten on 1/30/25.
//

extension Value {

  public subscript(path: Path, delegate delegate: PathQuery.Delegate? = nil) -> PathQuery.Result {
    PathQuery.query(path: path, from: self, delegate: delegate)
  }

}
