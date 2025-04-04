//
//  URLComponents.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

import Foundation

internal extension URLComponents {

  var isURN: Bool {
    scheme != nil && host == nil && port == nil && user == nil && password == nil && path != ""
  }

  var isAbsolute: Bool {
    scheme != nil && (isURN || (host != nil && (path == "" || path.hasPrefix("/"))))
  }

  var uri: URI {
    return if isAbsolute {
      .absolute(
        URI.Absolute(
          scheme: scheme!,
          authority: .from(host: host ?? "", port: port, userInfo: .from(user: user, password: password)),
          path: .from(encoded: path, absolute: true),
          query: queryItems?.compactMap { .from(name: $0.name, value: $0.value) } ?? [],
          fragment: fragment
        )
      )
    } else {
      .relativeReference(
        URI.RelativeReference(
          path: .from(encoded: path, absolute: false),
          query: queryItems?.compactMap { URI.QueryItem(name: $0.name, value: $0.value) } ?? [],
          fragment: fragment
        )
      )
    }
  }

  var lexicalUri: URI {
    return if isAbsolute {
      .absolute(
        URI.Absolute(
          scheme: scheme!,
          authority: .from(host: host ?? "", port: port, userInfo: .from(user: user, password: password)),
          path: .from(encoded: path, absolute: true),
          query: queryItems?.compactMap { .from(name: $0.name, value: $0.value) } ?? [],
          fragment: fragment,
          normalized: false
        )
      )
    } else {
      .relativeReference(
        URI.RelativeReference(
          path: .from(encoded: path, absolute: false),
          query: queryItems?.compactMap { URI.QueryItem(name: $0.name, value: $0.value) } ?? [],
          fragment: fragment,
          normalized: false
        )
      )
    }
  }

}
