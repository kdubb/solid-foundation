//
//  LogStaticString.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/28/25.
//

#if canImport(Darwin)
  import Darwin
#elseif canImport(Glibc)
  import Glibc
#endif


public struct LogStaticString: Equatable, Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {

  public let value: StaticString

  public init(_ value: StaticString) {
    self.value = value
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.value.withUTF8Buffer { lhsBuffer in
      rhs.value.withUTF8Buffer { rhsBuffer in
        guard
          lhsBuffer.count == rhsBuffer.count,
          let lhsBase = lhsBuffer.baseAddress,
          let rhsBase = rhsBuffer.baseAddress
        else {
          return false
        }
        return memcmp(lhsBase, rhsBase, lhsBuffer.count) == 0
      }
    }
  }

  public func hash(into hasher: inout Hasher) {
    if value.hasPointerRepresentation {
      hasher.combine(value.utf8Start)
    } else {
      hasher.combine(value.unicodeScalar.value)
    }
  }

  public var description: String { value.description }
  public var debugDescription: String { value.debugDescription }

}
