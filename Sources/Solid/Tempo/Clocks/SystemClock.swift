//
//  SystemClock.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/26/25.
//

/// A clock that provides the current time using the ``SystemInstantSource``.
///
public struct SystemClock: Clock {

  public static let utc = Self(zone: .utc)

  public let source = SystemInstantSource.instance
  public private(set) var zone: Zone

  public init(zone: Zone) {
    self.zone = zone
  }

  public var instant: Instant {
    return source.instant
  }
}

extension Clock where Self == SystemClock {

  /// The system clock that provides the current time in UTC.
  ///
  public static var system: Self {
    return SystemClock.utc
  }

}
