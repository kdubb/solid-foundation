//
//  TokenRecordingStream.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/6/25.
//

package class TokenRecordingStream<Token: Sendable, Error: Swift.Error>: TokenStream {

  package enum Mode {
    case recording
    case replaying
    case stopped
  }

  package var source: any TokenStream<Token, Error>
  package var mode: Mode
  package var recordedTokens: [Token]

  package init(_ source: any TokenStream<Token, Error>) {
    self.source = source
    self.mode = .stopped
    self.recordedTokens = []
  }

  package func nextToken() throws(Error) -> Token {
    switch mode {
    case .recording:
      let token = try source.nextToken()
      recordedTokens.append(token)
      return token
    case .replaying:
      guard let token = recordedTokens.popLast() else {
        mode = .stopped
        return try source.nextToken()
      }
      return token
    case .stopped:
      return try source.nextToken()
    }
  }

  package func record(initialTokens: [Token] = []) {
    mode = .recording
    recordedTokens = initialTokens
  }

  package func replay() {
    mode = .replaying
    recordedTokens.reverse()
  }

  package func stop() {
    mode = .stopped
    recordedTokens.removeAll()
  }
}
