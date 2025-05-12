//
//  ZoneRulesLoader.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/1/25.
//

public protocol ZoneRulesLoader: Sendable {

  func load(identifier: String) throws -> ZoneRules
}
