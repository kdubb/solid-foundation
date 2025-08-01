//
//  Schema-Validation-Result.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/2/25.
//

extension Schema.Validator {

  public protocol Result: Sendable, CustomStringConvertible {

    var isValid: Bool { get }

  }

}
