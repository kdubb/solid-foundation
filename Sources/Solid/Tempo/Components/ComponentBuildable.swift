//
//  ComponentBuildable.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/30/25.
//


public protocol ComponentBuildable {
  static var requiredComponentKinds: Set<AnyComponentKind> { get }
  init(components: some ComponentContainer)
}

extension LinkedComponentContainer where Self: ComponentBuildable {

  public static var requiredComponentKinds: Set<AnyComponentKind> {
    return Set(links.map { AnyComponentKind($0.kind) })
  }

}
