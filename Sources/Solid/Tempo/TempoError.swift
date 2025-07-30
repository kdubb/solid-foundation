//
//  Errors.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

import Foundation

public enum TempoError: Swift.Error, Equatable {

  public enum SkippedLocalTimeResolutionFailureReason: Sendable, Equatable {
    case failedToResolve
    case rejectedByStrategy
  }

  public enum AmbiguousLocalTimeResolutionFailureReason: Sendable, Equatable {
    case failedToResolve
    case noValidInstant
    case rejectedByStrategy
  }

  public enum ValidationFailureReason: Sendable, Equatable {
    case outOfRange(value: String, range: String)
    case invalidZoneId(id: String)
    case invalidZoneOffset(offset: String)
    case unsupportedInContainer(String)
    case extended(reason: String)
  }

  public enum ComponentResolutionFailureReason: Sendable, Equatable {
    case invalidComponentType
    case unsupportedForOperation
  }

  case instantResolutionFailed
  case skippedTimeResolutionFailed(reason: SkippedLocalTimeResolutionFailureReason)
  case ambiguousTimeResolutionFailed(reason: AmbiguousLocalTimeResolutionFailureReason)
  case calendarInconsistency(details: String)
  case missingComponent(component: ComponentId)
  case invalidComponentValue(component: ComponentId, reason: ValidationFailureReason)
  case componentResolutionFailed(component: ComponentId, reason: ComponentResolutionFailureReason)
  case unhandledOverflow
  case invalidRegionalTimeZone(identifier: String)
  case invalidFixedOffsetTimeZone(offset: Int)
}

extension TempoError: LocalizedError {

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
      return "Invalid \(component.errorName) value"
    case .missingComponent(let component):
      return "\(component.errorName) is missing"
    case .componentResolutionFailed(let component, _):
      return "Resolution of \(component.errorName) failed"
    case .unhandledOverflow:
      return "Unhandled overflow"
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
      case .invalidZoneOffset(let offset):
        "The zone offset '\(offset)' is invalid for the date/time."
      case .unsupportedInContainer(let container):
        "The component \(component.errorName) is not supported in the a \(container)."
      case .extended(reason: let reason):
        reason
      }
    case .missingComponent(let component):
      "The converted date is missing the required \(component.errorName) component."
    case .componentResolutionFailed(component: let component, reason: let reason):
      switch reason {
      case .invalidComponentType:
        "The component '\(component.errorName)' is not a valid component type for calendar resolution."
      case .unsupportedForOperation:
        "The component '\(component.errorName)' is not supported for this operation."
      }
    case .unhandledOverflow:
      "An overflow was encountered that was not handled by the operation."
    case .invalidRegionalTimeZone(identifier: let identifier):
      "The regional time zone identifier '\(identifier)' is invalid."

    case .invalidFixedOffsetTimeZone(offset: let offset):
      "The time zone offset '\(offset)' is invalid."
    }
  }
}
