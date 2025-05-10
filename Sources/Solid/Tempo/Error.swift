//
//  Errors.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

import Foundation

extension Tempo {

  public enum Error: Swift.Error {

    public enum SkippedLocalTimeResolutionFailureReason: Sendable {
      case failedToResolve
      case rejectedByStrategy
    }

    public enum AmbiguousLocalTimeResolutionFailureReason: Sendable {
      case failedToResolve
      case noValidInstant
      case rejectedByStrategy
    }

    public enum ValidationFailureReason: Sendable {
      case outOfRange(value: String, range: String)
      case invalidZoneId(id: String)
      case unsupportedInContainer(String)
      case unknown(reason: String)
    }

    public enum ComponentResolutionFailureReason: Sendable {
      case invalidComponentType
    }

    case instantResolutionFailed
    case skippedTimeResolutionFailed(reason: SkippedLocalTimeResolutionFailureReason)
    case ambiguousTimeResolutionFailed(reason: AmbiguousLocalTimeResolutionFailureReason)
    case calendarInconsistency(details: String)
    case missingComponent(component: String)
    case invalidComponentValue(component: String, reason: ValidationFailureReason)
    case componentResolutionFailed(component: String, reason: ComponentResolutionFailureReason)
    case invalidRegionalTimeZone(identifier: String)
    case invalidFixedOffsetTimeZone(offset: Int)
  }

}

extension Tempo.Error: LocalizedError {

  public var errorDescription: String? {
    switch self {
    case .instantResolutionFailed:
      return "Resolution of instant failed"
    case .skippedTimeResolutionFailed:
      return "Skipped local time could not be resolved"
    case .ambiguousTimeResolutionFailed:
      return "Ambiguous local time could not be resolved"
    case .calendarInconsistency:
      return "Calendar inconsistency encountered"
    case .invalidComponentValue(let component, _):
      return "Invalid \(component) value"
    case .missingComponent(let component):
      return "\(component) is missing"
    case .componentResolutionFailed(let component, _):
      return "Resolution of \(component) failed"
    case .invalidRegionalTimeZone:
      return "Invalid regional time zone"
    case .invalidFixedOffsetTimeZone:
      return "Invalid fixed offset time zone"
    }
  }

  public var failureReason: String? {
    switch self {
    case .instantResolutionFailed:
      "Instant resolution failed for an unknown reason."
    case .skippedTimeResolutionFailed(let reason):
      switch reason {
      case .failedToResolve:
        "A local time falling within a skipped (gap) period could not be resolved."
      case .rejectedByStrategy:
        "A local time was rejected by the resolution strategy due to a skipped period."
      }
    case .ambiguousTimeResolutionFailed(let reason):
      switch reason {
      case .noValidInstant:
        "A local time during an ambiguous period had no valid instant."
      case .failedToResolve:
        "A local time during an ambiguous period could not be resolved."
      case .rejectedByStrategy:
        "A local time was rejected by the resolution strategy due to ambiguity."
      }
    case .calendarInconsistency(details: let details):
      "Encountered an inconsistency between Tempo and the backing calendar: \(details)"
    case .invalidComponentValue(let component, reason: let reason):
      switch reason {
      case .outOfRange(let value, let range):
        "Value \(value) is outside valid range \(range)."
      case .invalidZoneId(let id):
        "The zone ID '\(id)' is invalid."
      case .unsupportedInContainer(let container):
        "The component \(component) is not supported in the a \(container)."
      case .unknown(reason: let reason):
        reason
      }
    case .missingComponent(let component):
      "The converted date is missing the required \(component) component."
    case .componentResolutionFailed(component: let component, reason: let reason):
      switch reason {
      case .invalidComponentType:
        "The component '\(component)' is not a valid component type for calendar resolution."
      }
    case .invalidRegionalTimeZone(identifier: let identifier):
      "The regional time zone identifier '\(identifier)' is invalid."

    case .invalidFixedOffsetTimeZone(offset: let offset):
      "The time zone offset '\(offset)' is invalid."
    }
  }
}
