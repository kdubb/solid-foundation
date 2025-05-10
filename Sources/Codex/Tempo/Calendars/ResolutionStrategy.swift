//
//  Resolutions.swift
//  Codex
//
//  Created by Kevin Wooten on 4/27/25.
//

extension Tempo {

  public struct ResolutionStrategy {

    public static let `default` = ResolutionStrategy()

    public enum Option {
      case skipped(ResolutionStrategy.SkippedLocalTime)
      case ambiguous(ResolutionStrategy.AmbiguousLocalTime)

      public func apply(to strategy: ResolutionStrategy) -> ResolutionStrategy {
        switch self {
        case .skipped(let skippedLocalTime):
          ResolutionStrategy(skippedLocalTime: skippedLocalTime, ambiguousLocalTime: strategy.ambiguousLocalTime)
        case .ambiguous(let ambiguousLocalTime):
          ResolutionStrategy(skippedLocalTime: strategy.skippedLocalTime, ambiguousLocalTime: ambiguousLocalTime)
        }
      }
    }

    public typealias Options = Set<Option>

    /// Strategy for handling skipped local times.
    ///
    /// Determines how times that fall withing a skipped time gap are resolved.
    ///
    public enum SkippedLocalTime {

      /// Specifies a skipped time gap boundary edge.
      public enum BoundaryEdge {
        /// The start of the skipped time gap.
        case start
        /// The end of the skipped time gap.
        case end
        /// The nearest edge of the skipped time gap to the
        /// original (invalid) time.
        case nearest
      }

      /// The next valid time after the skipped time gap.
      ///
      /// The time is chosen by adding the gap length to the original time to
      /// shift it into a valid period. This has the effect of keeping the unaffected
      /// time components the same. For example, if the time is `2:29:17.123` and
      /// the gap is 1 hour, the resolved time will be `3:29:17.123`. For an irregular
      /// gap of 30 minutes(e.g., Lord Howe Island) , the time would be `2:59:17.123`.
      ///
      case nextValid

      /// Selects the previous valid time before the skipped time gap.
      ///
      /// The time is chosen by subtracting the gap length from the original time to
      /// shift it into a valid period. This has the effect of keeping the unaffected
      /// time components the same. For example, if the time is `2:29:17.123` and
      /// the gap is 1 hour, the resolved time will be `1:29:17.123`. For an irregular
      /// gap of 30 minutes(e.g., Lord Howe Island) , the time would be `1:59:17.123`.
      ///
      case previousValid

      /// Selects one of the edges of the skipped time gap: the start (just before the gap),
      /// the end (just after), or the edge nearest to the original invalid time.
      ///
      case boundary(BoundaryEdge = .nearest)

      /// Rejects any time that falls within a skipped time gap.
      case reject
    }

    /// Strategy for resolving ambiguous local times.
    ///
    /// Applies to both overlapping periods (e.g., from daylight saving transitions)
    /// and structurally ambiguous times (e.g., resolving a `LocalDate` or partial
    /// `LocalDateTime` where not all components are specified).
    ///
    public enum AmbiguousLocalTime {

      /// Selects the earliest valid time in the ambiguous period.
      ///
      /// - For overlapping periods (e.g., during a "fall back" DST transition),
      ///   chooses the earlier of the two valid instants.
      /// - For underspecified times, fills missing components with their
      ///   lowest valid values (e.g., seconds = 0, nanoseconds = 0).
      ///
      case earliest

      /// Selects the latest valid time in the ambiguous period.
      ///
      /// - For overlapping periods, chooses the later of the two valid instants.
      /// - For underspecified times, fills missing components with their
      ///   highest valid values (e.g., seconds = 59, nanoseconds = 999_999_999).
      ///
      case latest

      /// Rejects any ambiguous time.
      ///
      /// This includes both overlaps (e.g., DST transitions with multiple possible instants)
      /// and structurally ambiguous values where required components are missing.
      ///
      case reject
    }

    /// Strategy for resolving local times that  fall within skipped time gaps.
    public let skippedLocalTime: SkippedLocalTime

    /// Strategy for resolving ambiguous local times.
    public let ambiguousLocalTime: AmbiguousLocalTime

    /// Initlalizes a resolution strategy with the provided skipped and ambiguous time strategies.
    ///
    /// - Parameters:
    ///  - skippedLocalTime: The strategy for resolving skipped local times.
    ///  - ambiguousLocalTime: The strategy for resolving ambiguous local times.
    ///
    public init(skippedLocalTime: SkippedLocalTime = .nextValid, ambiguousLocalTime: AmbiguousLocalTime = .earliest) {
      self.skippedLocalTime = skippedLocalTime
      self.ambiguousLocalTime = ambiguousLocalTime
    }

    /// Initializes a resolution strategy from the provided options.
    ///
    /// Instead of requiring the caller to create and pass a
    /// ``Tempo/ResolutionStrategy`` instance, functions that require a
    /// resolution strategy accept a set of ``Tempo/ResolutionStrategy/Option``
    /// values in a set; allowing the caller to specify only the options they care about.
    ///
    /// - Parameter options: A set of resolution strategy options, any missing
    ///  options will be set to their default values.
    ///
    public init(options: Options) {
      var strategy = ResolutionStrategy()
      for option in options {
        strategy = option.apply(to: strategy)
      }
      self = strategy
    }
  }

}

extension Tempo.ResolutionStrategy: Equatable {}
extension Tempo.ResolutionStrategy: Hashable {}
extension Tempo.ResolutionStrategy: Sendable {}

extension Tempo.ResolutionStrategy.SkippedLocalTime.BoundaryEdge: Equatable {}
extension Tempo.ResolutionStrategy.SkippedLocalTime.BoundaryEdge: Hashable {}
extension Tempo.ResolutionStrategy.SkippedLocalTime.BoundaryEdge: Sendable {}

extension Tempo.ResolutionStrategy.SkippedLocalTime: Equatable {}
extension Tempo.ResolutionStrategy.SkippedLocalTime: Hashable {}
extension Tempo.ResolutionStrategy.SkippedLocalTime: Sendable {}

extension Tempo.ResolutionStrategy.AmbiguousLocalTime: Equatable {}
extension Tempo.ResolutionStrategy.AmbiguousLocalTime: Hashable {}
extension Tempo.ResolutionStrategy.AmbiguousLocalTime: Sendable {}

extension Tempo.ResolutionStrategy.Option: Equatable {}
extension Tempo.ResolutionStrategy.Option: Hashable {}
extension Tempo.ResolutionStrategy.Option: Sendable {}

extension Tempo.ResolutionStrategy.Options {

  public static let strict: Self = [.skipped(.reject), .ambiguous(.reject)]

  public var strategy: Tempo.ResolutionStrategy {
    Tempo.ResolutionStrategy(options: self)
  }

}
