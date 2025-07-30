//
//  FloatLogArgument.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

import Foundation


public struct FloatLogArgument<F: BinaryFloatingPoint & Sendable>: LogArgument {

  public enum Format: Sendable {
    case `default`
    case number(FloatingPointFormatStyle<F>.Configuration.Precision)
    case percent(FloatingPointFormatStyle<F>.Percent.Configuration.Precision)
    case currency(code: String, precision: FloatingPointFormatStyle<F>.Currency.Configuration.Precision)
  }

  public var float: @Sendable () -> F
  public var format: Format
  public var privacy: LogPrivacy

  public init(float: @escaping @Sendable () -> F, format: Format? = nil, privacy: LogPrivacy? = nil) {
    self.float = float
    self.format = format ?? .default
    self.privacy = privacy ?? .public
  }

  private let constantFormatStyle = ConstantFormatStyles.for(F.self)

  public var constantValue: String {
    float().formatted(constantFormatStyle)
  }

  public var formattedValue: String {
    let value = float()
    return switch format {
    case .default:
      value.formatted()
    case .number(let precision):
      FloatingPointFormatStyle<F>().precision(precision).format(value)
    case .percent(let precision):
      FloatingPointFormatStyle<F>.Percent().precision(precision).format(value)
    case .currency(let code, let precision):
      FloatingPointFormatStyle<F>.Currency(code: code).precision(precision).format(value)
    }
  }

}
