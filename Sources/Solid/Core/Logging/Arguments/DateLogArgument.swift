//
//  DateLogArgument.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

import Foundation


public struct DateLogArgument: LogArgument {

  public enum Format: Sendable {
    case `default`
    case dateTime(date: Date.FormatStyle.DateStyle, time: Date.FormatStyle.TimeStyle)
    case date(Date.FormatStyle.DateStyle)
    case time(Date.FormatStyle.TimeStyle)
  }

  public var value: @Sendable () -> Date
  public var format: Format
  public var privacy: LogPrivacy

  public init(_ value: @escaping @Sendable () -> Date, format: Format = .default, privacy: LogPrivacy = .public) {
    self.value = value
    self.format = format
    self.privacy = privacy
  }

  public var constantValue: String {
    value().formatted(.iso8601)
  }

  public var formattedValue: String {
    let value = value()
    return switch format {
    case .default:
      value.formatted()
    case .dateTime(let dateStyle, let timeStyle):
      value.formatted(date: dateStyle, time: timeStyle)
    case .date(let dateStyle):
      value.formatted(date: dateStyle, time: .omitted)
    case .time(let timeStyle):
      value.formatted(date: .omitted, time: timeStyle)
    }
  }

}
