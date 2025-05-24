//
//  ComponentBuildable.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/30/25.
//


public protocol ComponentBuildable {
  static var requiredComponents: Set<AnyComponent> { get }
  init(components: some ComponentContainer)
}

extension LinkedComponentContainer where Self: ComponentBuildable {

  public static var requiredComponents: Set<AnyComponent> {
    return Set(links.map { $0.component.any })
  }

}
