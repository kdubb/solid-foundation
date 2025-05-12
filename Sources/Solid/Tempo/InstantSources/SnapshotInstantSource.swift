//
//  TickableInstantSource.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

import Synchronization

/// An ``InstantSource`` that takes snapshots of another ``InstantSource``.
///
/// ``SnapshotInstantSource`` is initialized with another ``InstantSource`` and
/// initializes its ``instant`` property with the current instant produced by the provided
/// source. The ``instant`` property maintains this snapshot until the ``update()``
/// method is called, which updates the snapshot to the current instant from the source.
///
/// This is useful for executing code with the same view of time throughout. Examples
/// include transactional sections and testing with a fixed instant. Any ``Clock`` using
/// a ``SnapshotInstantSource`` as its ``Clock/source`` will be similarly fixed to
/// the same instant.
///
public final class SnapshotInstantSource: InstantSource, Sendable {

  /// The ``InstantSource`` that this snapshot is based on.
  public let source: InstantSource

  private let lockedInstant: Mutex<Instant>

  /// The current instant snapshot, take from ``source``.
  public var instant: Instant {
    return lockedInstant.withLock { $0 }
  }

  /// Initializes a ``SnapshotInstantSource`` with another ``InstantSource``.
  ///
  /// During initialization, an initial snapshot of the provided source's instant is taken
  /// to initialize the ``instant`` property.
  ///
  /// - Parameter source: The ``InstantSource`` to take snapshots from.
  ///
  public init(source: InstantSource) {
    self.source = source
    self.lockedInstant = Mutex(source.instant)
  }

  /// Updates the snapshot by sampling ``source`` for its current instant.
  public func update() {
    lockedInstant.withLock { $0 = source.instant }
  }

}

extension InstantSource where Self == SnapshotInstantSource {

  /// Creates a new ``SnapshotInstantSource`` with the provided source.
  ///
  /// This is a convenience method for creating a ``SnapshotInstantSource`` using
  /// dot shorthand syntax.
  ///
  /// - Parameter source: The ``InstantSource`` to take snapshots from.
  /// - Returns: A new ``SnapshotInstantSource`` initialized with the provided source.
  ///
  public static func snapshot(of source: any InstantSource) -> Self {
    return Self(source: source)
  }

}
