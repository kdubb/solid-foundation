//
//  Schema-ContentMediaType.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/9/25.
//

import SolidData


extension Schema {

  public protocol ContentMediaTypeType: Sendable {

    var identifier: String { get }

    func validate(_ value: Value) -> Bool

  }

}
