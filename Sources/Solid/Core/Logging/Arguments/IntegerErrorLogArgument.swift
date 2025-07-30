//
//  IntegerErrorLogArgument.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

import Foundation
#if canImport(Darwin)
  import Darwin
#elseif canImport(Glibc)
  import Glibc
#elseif canImport(Musl)
  import Musl
#endif


public struct IntegerErrorLogArgument: LogArgument {

  public enum SubSystem: Sendable {
    case `default`
    case posix
    #if canImport(Darwin)
      case mach
    #endif
  }

  public var int: @Sendable () -> Int
  public var system: SubSystem
  public var privacy: LogPrivacy

  public init(int: @escaping @Sendable () -> Int, system: SubSystem, privacy: LogPrivacy? = nil) {
    self.int = int
    self.system = system
    self.privacy = privacy ?? .public
  }

  private let constantFormatStyle = ConstantFormatStyles.for(Int.self)

  public var constantValue: String {
    constantFormatStyle.format(int())
  }

  public var formattedValue: String {
    let value = int()
    switch system {
    case .default, .posix:
      return strerror(Int32(value)).map { String(cString: $0) } ?? "Unknown Error (\(value))"
    #if canImport(Darwin)
      case .mach:
        return mach_error_string(mach_error_t(value)).map { String(cString: $0) } ?? "Unknown Error (\(value))"
    #endif
    }
  }

}
