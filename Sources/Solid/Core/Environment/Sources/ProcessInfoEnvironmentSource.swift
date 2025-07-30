//
//  ProcessInfoEnvironmentSource.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

import Foundation


public struct ProcessInfoEnvironmentSource: ProcessEnvironmentSource {

  public let processInfo: ProcessInfo
  public let priority: Int

  public init(processInfo: ProcessInfo, priority: Int) {
    self.processInfo = processInfo
    self.priority = priority
  }

  public func value(forNames names: [String]) -> String? {
    for name in names {
      if let value = processInfo.environment[name] {
        return value
      }
    }
    return nil
  }

}
