//
//  UIntEnvironmentVariable.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

extension UInt: EnvironmentVariableInitializable {

  public init?(environmentVariableValue: String) {
    guard let uintValue = Self(environmentVariableValue) else {
      return nil
    }
    self = uintValue
  }

}
