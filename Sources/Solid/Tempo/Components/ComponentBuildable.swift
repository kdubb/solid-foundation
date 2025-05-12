//
//  ComponentBuildable.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/30/25.
//


public protocol ComponentBuildable {
  static var requiredComponentIds: Set<Component.Id> { get }
  init(components: some ComponentContainer)
}

extension LinkedComponentContainer where Self: ComponentBuildable {

  public static var requiredComponentIds: Set<Component.Id> {
    return Set(links.map { $0.component.id })
  }

}
