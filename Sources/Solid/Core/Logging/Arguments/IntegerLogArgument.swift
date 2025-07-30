//
//  IntegerLogArgument.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/28/25.
//

import Foundation


public struct IntegerLogArgument<I: FixedWidthInteger & Sendable>: LogArgument {

  public enum Format: Sendable {
    case `default`
    case decimal
    case percent(IntegerFormatStyle<I>.Percent)
    case currency(IntegerFormatStyle<I>.Currency)
  }

  public var int: @Sendable () -> I
  public var format: Format
  public var privacy: LogPrivacy

  public init(int: @escaping @Sendable () -> I, format: Format? = nil, privacy: LogPrivacy? = nil) {
    self.int = int
    self.format = format ?? .decimal
    self.privacy = privacy ?? .public
  }

  private let constantFormatStyle = ConstantFormatStyles.for(I.self)

  public var constantValue: String {
    int().formatted(constantFormatStyle)
  }

  public var formattedValue: String {
    let value = int()
    switch format {
    case .default, .decimal:
      return value.formatted()
    case .percent(let style):
      return style.format(value)
    case .currency(let style):
      return style.format(value)
    }
  }

}
