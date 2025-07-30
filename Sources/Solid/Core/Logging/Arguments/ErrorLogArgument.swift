//
//  ErrorLogArgument.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

import Foundation


public struct ErrorLogArgument<E: Error>: LogArgument {

  public enum Format: Sendable {
    case `default`
    case standard
    case debug
    case localized
  }

  public var error: @Sendable () -> E
  public var format: Format
  public var privacy: LogPrivacy

  public init(error: @escaping @Sendable () -> E, format: Format? = nil, privacy: LogPrivacy? = nil) {
    self.error = error
    self.format = format ?? .default
    self.privacy = privacy ?? .public
  }

  public var constantValue: String { Format.debug.apply(error()) }

  public var formattedValue: String { format.apply(error()) }

}


public extension ErrorLogArgument.Format {

  func apply(_ error: Error) -> String {
    switch self {
    case .default, .debug:
      return (error as CustomDebugStringConvertible).debugDescription

    case .localized:
      if let localized = error as? LocalizedError {
        return localized.errorDescription ?? localized.localizedDescription
      }
      return (error as CustomDebugStringConvertible).debugDescription

    case .standard:
      return (error as CustomStringConvertible).description
    }
  }

}
