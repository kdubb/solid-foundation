//
//  TokenStream.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/6/25.
//

package protocol TokenStream<Token, Error> {
  associatedtype Token: Sendable
  associatedtype Error: Swift.Error

  func nextToken() throws(Error) -> Token
}
