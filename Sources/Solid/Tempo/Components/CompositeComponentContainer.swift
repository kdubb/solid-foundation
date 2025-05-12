//
//  CompositeComponentContainer.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/30/25.
//


struct CompositeComponentContainer {

  public let containers: [any ComponentContainer]

  public init(containers: [any ComponentContainer]) {
    self.containers = containers
  }
}


extension CompositeComponentContainer: CustomStringConvertible {

  public var description: String {
    var entries: [Component.Id: String] = [:]
    for container in containers {
      for componentId in container.availableComponentIds.sorted() {
        guard
          entries[componentId] == nil,
          let value = container.valueIfPresent(for: componentId.component)
        else {
          continue
        }
        entries[componentId] = "- (\(componentId.name)) \(value)"
      }
    }
    return entries.sorted { $0.key < $1.key }.map { $0.value }.joined(separator: "\n")
  }

}

extension CompositeComponentContainer: ComponentContainer {

  public var availableComponentIds: Set<Component.Id> {
    var all = Set<Component.Id>()
    for container in containers {
      all.formUnion(container.availableComponentIds)
    }
    return all
  }

  public func valueIfPresent<C>(for component: C) -> C.Value? where C: Component {
    for container in containers {
      if let value = container.valueIfPresent(for: component) {
        return value
      }
    }
    return nil
  }

}
