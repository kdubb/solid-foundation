//
//  DoubleEnvironmentVariable.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

extension Double: EnvironmentVariableInitializable {

  public init?(environmentVariableValue: String) {
    guard let doubleValue = Self(environmentVariableValue) else {
      return nil
    }
    self = doubleValue
  }

}
