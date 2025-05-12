//
//  Schema-ContentEncodingType.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/11/25.
//

import SolidData
import Foundation


extension Schema {

  public protocol ContentEncodingType: Sendable {

    var identifier: String { get }

    func encode(_ value: Value) throws -> String
    func decode(_ string: String) throws -> Value

  }

}
