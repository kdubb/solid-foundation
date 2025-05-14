//
//  ValidZoneOffsets.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/13/25.
//


/// The valid zone offsets for a specific local date/time.
///
/// The enum provides semantic meaning for the results as well
/// as being a ``Swift/Collection`` of ``ZoneOffset``
/// values.
///
public enum ValidZoneOffsets {
  /// The associated local date/time is in a normal time period with a
  /// single valid offset.
  ///
  case normal(ZoneOffset)
  /// No offsets are valid for the associated local date/time because
  /// it is in a skipped time gap.
  ///
  case skipped(ZoneTransition)
  /// The associated local date/time is in an ambiguous time
  /// period with multiple valid offsets.
  ///
  /// Generally there will be two valid offsets associated with a
  /// zone transition. Although, in some esoteric cases there _could_
  /// be more than two valid offsets. The offsets are ordered from
  /// earliest to latest.
  ///
  case ambiguous([ZoneOffset])
}

extension ValidZoneOffsets: Sendable {}
extension ValidZoneOffsets: Equatable {}
extension ValidZoneOffsets: Hashable {}

extension ValidZoneOffsets: Collection {

  public typealias Element = ZoneOffset
  public typealias Index = Int

  public var startIndex: Int { 0 }

  public var endIndex: Int {
    switch self {
    case .skipped: 0
    case .normal: 1
    case .ambiguous(let offsets): offsets.count
    }
  }

  public var count: Int {
    switch self {
    case .skipped: 0
    case .normal: 1
    case .ambiguous(let offsets): offsets.count
    }
  }

  public func index(after i: Int) -> Int {
    precondition(i >= 0 && i < count, "Index out of bounds")
    return i + 1
  }

  public subscript(index: Int) -> ZoneOffset {
    switch self {
    case .skipped:
      preconditionFailure("No offsets in gap")
    case .normal(let offset):
      precondition(index == 0, "Index out of bounds")
      return offset
    case .ambiguous(let offsets):
      return offsets[index]
    }
  }
}

extension ValidZoneOffsets {

  public func apply(resolution: ResolutionStrategy, to instant: Instant) throws -> Instant {
    switch self {
    case .normal(let offset):
      return instant + .seconds(offset.totalSeconds)

    case .skipped(let transition):
      switch resolution.skippedLocalTime {
      case .nextValid:
        return instant + transition.duration
      case .previousValid:
        return instant - transition.duration
      case .boundary(.start):
        return transition.instant
      case .boundary(.end):
        return transition.instant + transition.duration
      case .boundary(.nearest):
        let midpoint = transition.instant + (transition.duration / 2)
        return instant < midpoint ? transition.instant : transition.instant + transition.duration
      case .reject:
        throw TempoError.skippedTimeResolutionFailed(reason: .rejectedByStrategy)
      }

    case .ambiguous(let offsets):
      switch resolution.ambiguousLocalTime {
      case .earliest:
        return instant - Duration(offsets[0])
      case .latest:
        return instant - Duration(offsets[offsets.index(before: offsets.endIndex)])
      case .reject:
        throw TempoError.ambiguousTimeResolutionFailed(reason: .rejectedByStrategy)
      }
    }
  }
}
