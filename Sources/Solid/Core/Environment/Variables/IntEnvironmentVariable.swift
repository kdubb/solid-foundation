//
//  IntEnvironmentVariable.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

extension Int: EnvironmentVariableInitializable {

  public init?(environmentVariableValue: String) {
    guard let intValue = Self(environmentVariableValue) else {
      return nil
    }
    self = intValue
  }

}
