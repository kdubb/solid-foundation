//
//  NWConnection.swift
//  SolidIO
//
//  Created by Kevin Wooten on 7/5/25.
//

import Foundation
import Network


public extension NWConnection {

  func send(
    _ content: (some DataProtocol)?,
    contentContext: ContentContext,
    isComplete: Bool,
  ) async throws {
    try await withCheckedThrowingContinuation { continuation in
      let completion: NWConnection.SendCompletion = .contentProcessed { error in
        continuation.resume(with: error.map(Result.failure) ?? .success(()))
      }
      send(content: content, contentContext: contentContext, isComplete: isComplete, completion: completion)
    }
  }

  func sendIdempotent(_ content: (some DataProtocol)?, contentContext: ContentContext, isComplete: Bool) {
    send(content: content, contentContext: contentContext, isComplete: isComplete, completion: .idempotent)
  }

}
