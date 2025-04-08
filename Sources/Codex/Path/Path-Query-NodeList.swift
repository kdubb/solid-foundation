//
//  Path-Query-NodeList.swift
//  Codex
//
//  Created by Kevin Wooten on 4/10/25.
//

extension Path.Query {

  /// A list of nodes.
  ///
  /// Node lists are returned from query evaluations and contain zero or more
  /// ``Node`` elements.
  ///
  public struct NodeList {

    private var storage: [Node]

    /// Initalizes a new node list with the given nodes.
    ///
    /// - Parameter nodes: The nodes to store in the list.
    ///
    public init(_ nodes: [Node]) {
      self.storage = nodes
    }

    /// Count of nodes in the list.
    public var count: Int {
      storage.count
    }

    /// Constant for an empty node list.
    public static let empty = NodeList([])
  }

}

extension Path.Query.NodeList: Sendable {}
extension Path.Query.NodeList: Hashable {}
extension Path.Query.NodeList: Equatable {}

extension Path.Query.NodeList: CustomStringConvertible {

  /// A string representation of the node list.
  ///
  public var description: String {
    storage.map { "\($0.description)" }
      .joined(separator: ", ")
  }

}

extension Path.Query.NodeList: ExpressibleByArrayLiteral {

  /// Initializes a new node list with the array of (``Value``, ``Path``) tuples.
  ///
  /// - Parameter elements: The array of (``Value``, ``Path``) tuples to store in the list.
  ///
  public init(arrayLiteral elements: (value: Value, path: Path)...) {
    storage = elements.map { .node($0.value, $0.path) }
  }

}

extension Path.Query.NodeList: Sequence {

  public typealias Element = Path.Query.Node

  public func makeIterator() -> [Element].Iterator {
    storage.makeIterator()
  }

  public func map(_ transform: (Element) throws -> Element) rethrows -> Self {
    try Path.Query.NodeList(storage.map(transform))
  }

  public func compactMap(_ transform: (Element) throws -> Element?) rethrows -> Self {
    try Path.Query.NodeList(storage.compactMap(transform))
  }

  public func flatMap(_ transform: (Element) throws -> some Sequence<Element>) rethrows -> Self {
    try Path.Query.NodeList(storage.flatMap(transform))
  }
}

extension Path.Query.NodeList: Collection {

  public typealias Index = [Element].Index

  public subscript(position: Int) -> Element {
    get {
      storage[position]
    }
    set {
      storage[position] = newValue
    }
  }

  public var startIndex: Int {
    storage.startIndex
  }

  public var endIndex: Int {
    storage.endIndex
  }

  public func index(after i: [Element].Index) -> [Element].Index {
    storage.index(after: i)
  }

}

extension Path.Query.NodeList: RandomAccessCollection {}

extension Path.Query.NodeList: RangeReplaceableCollection {

  public init() {
    self.init([])
  }

  public mutating func replaceSubrange<C>(
    _ subrange: Range<Array<Element>.Index>,
    with newElements: C
  ) where C: Collection, Path.Query.Node == C.Element {
    storage.replaceSubrange(subrange, with: newElements)
  }
}
