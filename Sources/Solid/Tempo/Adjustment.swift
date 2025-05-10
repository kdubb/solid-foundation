//
//  Adjustment.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/28/25.
//

extension Tempo {

  /// Defines whether zone or offset adjustments preserve the original instant or the original local time.
  ///
  public enum AdjustmentAnchor {
    /// Preserve the original instant, which may alter the local time.
    case sameInstant
    /// Preserve the original local time, which may alter the instant.
    case sameLocalTime
  }

}
