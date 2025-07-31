//
//  NWConnectionStream.swift
//  SolidIO
//
//  Created by Kevin Wooten on 7/5/25.
//

import SolidCore
import Network

public class NWConnectionStream: Stream, Flushable, @unchecked Sendable {

  @AtomicOptionalReference public var connection: NWConnection?

  public init(connection: NWConnection) {
    self._connection = AtomicOptionalReference(value: connection)
  }

  public func flush() async throws {
    guard let connection else {
      return
    }
    try await connection.send(nil as DispatchData?, contentContext: .defaultMessage, isComplete: false)
  }

  public func close() async throws {

    try await connection?.send(nil as DispatchData?, contentContext: .finalMessage, isComplete: true)

    connection?.cancel()
    connection = nil
  }

}
