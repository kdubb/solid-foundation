//
//  Path-Segment.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

extension Path {

  /// A segment of a ``Path`` expression.
  ///
  /// ``Path`` expressions are made up of one or more ``Segment``s. Each of which takes as input
  /// the previous segment's result and returns a new result. The inputs and results of segments
  /// are always node lists. In the case of the root segment, the input node list consists of the single
  /// ``Value`` instance the path is being evaluated against.
  ///
  /// Segments produce results by selecting nodes from the input node list. The result of each
  /// segment is the node list selected by the segment. Each segment performs node selection by
  /// applying one or more ``Selector``s to the input node list, with different segment types allowing
  /// different selector types to be used.
  ///
  /// > Note: The input/result dependency chain of Segments means that if, at any point, a Segment
  /// produces an empty node list as a result, the entire path will produce an empty node list and
  /// execution will stop.
  ///
  /// # Segment Types
  ///
  /// - ``child(_:)``:   Applies name (`.name`) and index (`[2]`) selectors to the
  ///   immediate children of the values in the node list.
  /// - ``descendant(_:)``:   Applies name (`.name`) and index (`[2]`) selectors recursively
  ///   to all descendants of the values in the node list.
  ///
  /// # Examples
  ///
  /// ```swift
  /// // Root segment
  /// let root = Path("$")
  /// // root.segments == [.root]
  ///
  /// // Current segment
  /// let current = Path("$[@]")
  /// // current.segments == [.root, .child([.current])]
  ///
  /// // Child segment with name selector
  /// let child = Path("$.user")
  /// // child.segments == [.root, .child([.name("user")])]
  ///
  /// // Descendant segment with wildcard selector
  /// let descendant = Path("$..*")
  /// // descendant.segments == [.root, .descendant([.wildcard])]
  ///
  ///
  /// ```
  ///
  /// - SeeAlso:
  ///   - ``Path``
  ///   - ``Path/Selector``
  ///   -  [RFC-9535](https://tools.ietf.org/html/rfc9535)
  ///
  public enum Segment {

    /// Direct child access with selectors.
    ///
    /// Represents accessing immediate children of the current node using one or more selectors.
    /// Selectors can be names, indices, wildcards, or filter expressions.
    ///
    /// - Parameters:
    ///   - _: The selectors to apply when accessing children.
    ///   - shorthand: If `true`, the selector is output in shorthand form.
    ///
    case child([Selector], shorthand: Bool = false)

    /// Recursive descent with selectors.
    ///
    /// Represents accessing all descendants of the current node using one or more selectors.
    /// The selectors are applied at each level of the hierarchy.
    ///
    /// - Parameters:
    ///   - _: The selectors to apply when accessing descendants.
    ///   - shorthand: If `true`, the selector is output in shorthand form.
    ///
    case descendant([Selector], shorthand: Bool = false)
  }

}

extension Path.Segment: Sendable {}

extension Path.Segment: Hashable {

  /// Hashes the essential components of the segment.
  ///
  /// This method hashes the segment type and its selectors to ensure that
  /// each segment can be uniquely identified.
  ///
  /// - Note: The `shorthand` property of segments are not included in hashing.
  ///
  /// - Parameter hasher: The hasher to use for hashing the segment.
  ///
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .child(let selectors, _):
      hasher.combine(0)
      hasher.combine(selectors)
    case .descendant(let selectors, _):
      hasher.combine(1)
      hasher.combine(selectors)
    }
  }

}

extension Path.Segment: Equatable {

  /// Checks if two segments are equal.
  ///
  /// This method compares the segment types and their selectors to determine equality.
  ///
  /// - Note: The `shorthand` property of segments are not considered for equality.
  ///
  /// - Parameters:
  ///   - lhs: The left-hand side segment to compare.
  ///   - rhs: The right-hand side segment to compare.
  /// - Returns: `true` if the segments are equal, `false` otherwise.
  ///
  public static func == (lhs: Path.Segment, rhs: Path.Segment) -> Bool {
    switch (lhs, rhs) {
    case (.child(let lhsSelectors, _), .child(let rhsSelectors, _)):
      return lhsSelectors == rhsSelectors
    case (.descendant(let lhsSelectors, _), .descendant(let rhsSelectors, _)):
      return lhsSelectors == rhsSelectors
    default:
      return false
    }
  }

}

extension Path.Segment: CustomStringConvertible {

  /// A string representation of the segment.
  ///
  /// The string representation follows the JSONPath syntax:
  /// - Child segments are represented as `.` followed by the selectors
  /// - Descendant segments are represented as `..` followed by the selectors
  ///
  /// - Returns: A string representation of the segment in JSONPath syntax.
  public var description: String {
    switch self {
    case .child(let selectors, true):
      ".\(selectors.codexDescription)"
    case .child(let selectors, _):
      "[\(selectors.codexDescription)]"
    case .descendant(let selectors, true):
      "..\(selectors.codexDescription)"
    case .descendant(let selectors, _):
      "..[\(selectors.codexDescription)]"
    }
  }
}

extension Array where Element == Path.Segment {

  /// A string representation of an array of segments.
  ///
  /// This property concatenates the string representations of all segments
  /// in the array to form a complete JSONPath expression.
  ///
  /// - Returns: A string representation of the segments in JSONPath syntax.
  internal var codexDescription: String {
    map(\.description).joined(separator: "")
  }

}
