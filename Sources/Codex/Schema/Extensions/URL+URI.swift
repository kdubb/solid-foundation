//
//  URI+URL.swift
//  Codex
//
//  Created by Kevin Wooten on 2/15/25.
//

import Foundation

extension URL {

  /// Returns a `URI` object equivalent to this URL, or `nil` if the URL is not a valid URI.
  ///
  public var uri: URI? { URI(encoded: absoluteString) }

}
