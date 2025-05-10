//
//  ZoneRulesLoader.swift
//  Codex
//
//  Created by Kevin Wooten on 5/1/25.
//

extension Tempo {

  public protocol ZoneRulesLoader: Sendable {

    func load(identifier: String) throws -> ZoneRules
  }
}
