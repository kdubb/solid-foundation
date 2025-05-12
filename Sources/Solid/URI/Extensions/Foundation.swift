//
//  URI.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/8/25.
//

import Foundation


extension URI {

  /// Converts the URI to a Foundation URL.
  ///
  /// - Returns: A URL representation of this URI
  public var url: URL {
    var components = URLComponents()
    components.scheme = scheme
    components.encodedHost = authority?.encodedHost
    components.port = authority?.port
    components.percentEncodedUser = authority?.userInfo?.encodedUser
    components.percentEncodedPassword = authority?.userInfo?.encodedPassword
    components.percentEncodedPath = path.encoded(relative: scheme == nil)
    components.percentEncodedQuery = query?.encoded
    components.percentEncodedFragment = fragment
    return components.url.neverNil()
  }

}


extension URL {

  /// Returns a `URI` object equivalent to this URL, or `nil` if the URL is not a valid URI.
  ///
  public var uri: URI? { URI(encoded: absoluteString) }

}
