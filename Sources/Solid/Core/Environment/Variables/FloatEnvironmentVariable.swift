//
//  FloatEnvironmentVariable.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

extension Float: EnvironmentVariableInitializable {

  public init?(environmentVariableValue: String) {
    guard let floatValue = Self(environmentVariableValue) else {
      return nil
    }
    self = floatValue
  }

}
