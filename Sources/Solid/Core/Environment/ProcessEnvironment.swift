//
//  ProcessEnvironment.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

import Foundation
import Algorithms

public struct ProcessEnvironment: Sendable {

  public static let instance = ProcessEnvironment(sources: [
    DotEnvEnvironmentSource(priority: 100),
    ProcessInfoEnvironmentSource(processInfo: .processInfo, priority: 500),
  ])

  public let sources: [any ProcessEnvironmentSource]

  public init(sources: [any ProcessEnvironmentSource]) {
    self.sources = sources.sorted { $0.priority > $1.priority }
  }

  public func value<E: EnvironmentVariableDiscoverable>(for type: E.Type) -> E? {
    let names = E.environmentVariableNames
    for source in sources {
      if let envValue = source.value(forNames: names), let value = E(environmentVariableValue: envValue) {
        return value
      }
    }
    return E.interrogateEnvironment(self) ?? E.environmentDefaultValue
  }

  public func value<E: EnvironmentVariableInitializable>(forName name: String, as type: E.Type) -> E? {
    for source in sources {
      if let envValue = source.value(forName: name), let value = E(environmentVariableValue: envValue) {
        return value
      }
    }
    return nil
  }

  public func value<E: EnvironmentVariableInitializable>(forName name: String, default: E) -> E? {
    guard let value = value(forName: name, as: E.self) else {
      return nil
    }
    return value
  }

}
