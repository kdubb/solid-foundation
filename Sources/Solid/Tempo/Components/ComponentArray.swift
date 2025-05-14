//
//  ComponentArray.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/30/25.
//

public struct ComponentArray: Equatable, Hashable, Sendable {

  fileprivate var values: [ComponentValue]

  public init(_ values: some Sequence<ComponentValue>) {
    self.values = Array(values)
  }

}

extension ComponentArray: CustomStringConvertible {

  public var description: String {
    var entries: [String] = []
    for value in values.sorted(by: { $0.component.id < $1.component.id }) {
      entries.append("- (\(value.component.name)) \(value.value)")
    }
    return entries.joined(separator: "\n")
  }

}

extension ComponentArray: CustomReflectable {

  public var customMirror: Mirror {
    Mirror(
      self,
      children: values.map { ($0.component.name, $0.value) },
      displayStyle: .struct,
      ancestorRepresentation: .suppressed
    )
  }

}

extension ComponentArray: MutableComponentContainer {

  public var availableComponentIds: Set<Component.Id> {
    Set(values.map(\.component.id))
  }

  public func valueIfPresent<C>(for component: C) -> C.Value? where C: Component {
    guard let value = values.first(where: { $0.component.id == component.id }) else {
      return nil
    }
    return value.value as? C.Value
  }

  public mutating func setValue<C>(_ value: C.Value, for component: C) where C: Component {
    values.removeAll { $0.component.id == component.id }
    values.append(ComponentValue(component: component, value: value))
  }

  public mutating func removeValue<C>(for component: C) -> C.Value? where C: Component {
    let value = valueIfPresent(for: component)
    values.removeAll { $0.component.id == component.id }
    return value
  }

  public subscript<C>(_ component: C) -> C.Value? where C: Component {
    get { valueIfPresent(for: component) }
    set {
      if let newValue = newValue {
        setValue(newValue, for: component)
      } else {
        _ = removeValue(for: component)
      }
    }
  }

}

extension ComponentArray: ComponentBuildable {

  public static var requiredComponentIds: Set<Component.Id> { [] }

  public init(components: some ComponentContainer) {
    let values = components.values(for: Self.requiredComponentIds)
    self.init(values)
  }

}

extension ComponentArray: RandomAccessCollection, RangeReplaceableCollection {

  public var startIndex: Int { values.startIndex }
  public var endIndex: Int { values.endIndex }

  public init() {
    self.values = []
  }

  public subscript(index: Int) -> ComponentValue {
    get { values[index] }
    set { values[index] = newValue }
  }

  public mutating func replaceSubrange<C>(
    _ subrange: Range<Int>,
    with newElements: C
  ) where C: Collection, C.Element == ComponentValue {
    values.replaceSubrange(subrange, with: newElements)
  }

}

extension ComponentArray: ExpressibleByArrayLiteral {

  public init(arrayLiteral elements: ComponentValue...) {
    self.init(elements)
  }

}

extension Array: ComponentContainer where Element == ComponentValue {

  public var availableComponentIds: Set<Components.Id> { Set(map(\.component.id)) }

  public func valueIfPresent<C>(for component: C) -> C.Value? where C: Component {
    guard let value = first(where: { $0.component.id == component.id }) else {
      return nil
    }
    return value.value as? C.Value
  }

}
