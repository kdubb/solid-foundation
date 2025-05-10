//
//  ContentEncodingLocator.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/9/25.
//

public protocol ContentEncodingLocator: Sendable {

  func locate(contentEncoding id: String) throws -> Schema.ContentEncodingType

}
