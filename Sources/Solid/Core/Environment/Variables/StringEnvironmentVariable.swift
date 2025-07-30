//
//  StringEnvironmentVariable.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

extension String: EnvironmentVariableInitializable {

  public init?(environmentVariableValue: String) {
    self = environmentVariableValue
  }

}
