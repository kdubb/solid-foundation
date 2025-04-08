//
//  TokenRecordingStream.swift
//  Codex
//
//  Created by Kevin Wooten on 4/6/25.
//

class TokenRecordingStream<Token: Sendable, Error: Swift.Error>: TokenStream {

  enum Mode {
    case recording
    case replaying
    case stopped
  }

  var source: any TokenStream<Token, Error>
  var mode: Mode
  var recordedTokens: [Token]

  init(_ source: any TokenStream<Token, Error>) {
    self.source = source
    self.mode = .stopped
    self.recordedTokens = []
  }

  func nextToken() throws(Error) -> Token {
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

  func record(initialTokens: [Token] = []) {
    mode = .recording
    recordedTokens = initialTokens
  }

  func replay() {
    mode = .replaying
    recordedTokens.reverse()
  }

  func stop() {
    mode = .stopped
    recordedTokens.removeAll()
  }
}
