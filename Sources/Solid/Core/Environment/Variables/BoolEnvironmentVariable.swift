//
//  BoolEnvironmentVariable.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

extension Bool: EnvironmentVariableInitializable {

  public init?(environmentVariableValue: String) {
    let value = environmentVariableValue.lowercased()
    if let boolValue = Bool(value) {
      self = boolValue
    } else if let intValue = Int(value) {
      self = intValue != 0
    } else {
      switch value {
      case "t": self = true
      case "f": self = false
      default: return nil
      }
    }
  }

}
