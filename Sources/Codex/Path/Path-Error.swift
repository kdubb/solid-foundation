//
//  Path-Error.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

extension Path {

  public enum Error: Swift.Error {
    case invalidArraySliceSelector(String)
    case invalidSegmentSelector(String)
  }

}
