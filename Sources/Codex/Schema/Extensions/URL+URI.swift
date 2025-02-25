//
//  URI+URL.swift
//  Codex
//
//  Created by Kevin Wooten on 2/15/25.
//

import Foundation

extension URL {

  public var uri: URI? { URI(encoded: absoluteString) }

}
