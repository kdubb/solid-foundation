//
//  Duration+Foundation.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/12/25.
//

import Foundation

extension Duration {

  /// Initialize a `Duration` from a `Foundation.TimeInterval`.
  ///
  /// - Parameter timeInterval: The time interval in seconds.
  ///
  public init(timeInterval: TimeInterval) {
    self.init(nanoseconds: Int128(timeInterval * 1_000_000_000))
  }

  /// Returns a `Foundation.TimeInterval` representing the duration in seconds.
  ///
  public var timeInterval: TimeInterval {
    return Double(nanoseconds) / 1_000_000_000
  }

}
