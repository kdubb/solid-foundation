//
//  ComponentBuildable.swift
//  Codex
//
//  Created by Kevin Wooten on 4/30/25.
//

extension Tempo {

  public protocol ComponentBuildable {
    static var requiredComponentIds: Set<Component.Id> { get }
    init(components: some ComponentContainer)
  }

}

extension Tempo.LinkedComponentContainer where Self: Tempo.ComponentBuildable {

  public static var requiredComponentIds: Set<Tempo.Component.Id> {
    return Set(links.map { $0.component.id })
  }

}
