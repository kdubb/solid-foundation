//
//  RuntimeEnvironment.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

import Foundation
import Synchronization


public struct RuntimeEnvironment: Equatable, Hashable, CaseIterable, Sendable {

  public static let selected = ProcessEnvironment.instance.value(for: Self.self)

  public enum Category: String, Equatable, Hashable, CaseIterable, Sendable {
    case development
    case testing
    case staging
    case production
  }

  public let name: String
  public let shortNames: [String]
  public let category: Category

  public var allNames: [String] { [name] + shortNames }

  public init(name: String, shortNames: [String], category: Category = .development) {
    self.name = name
    self.shortNames = shortNames
    self.category = category
  }

  public static let development = Self(name: "Development", shortNames: ["dev"], category: .development)
  public static let testing = Self(name: "Testing", shortNames: ["tst", "test"], category: .testing)
  public static let staging = Self(name: "Staging", shortNames: ["stg", "stage"], category: .staging)
  public static let production = Self(name: "Production", shortNames: ["prd", "prod"], category: .production)

  public static let defaultCases: [RuntimeEnvironment] = [
    .development, .testing, .staging, .production,
  ]

  public static var allCases: [RuntimeEnvironment] {
    get { casesStorage.withLock { $0.all } }
  }

  public static var customCases: [RuntimeEnvironment] {
    get { casesStorage.withLock { $0.custom } }
  }

  public static func find(named name: String) -> RuntimeEnvironment? {
    let envName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    return allCases.first { $0.allNames.contains(envName) }
  }

  public static func register(_ newCase: RuntimeEnvironment) {
    casesStorage.withLock {
      guard !customCases.contains(where: { $0.name == newCase.name }) else { return }
      $0.custom.append(newCase)
      $0.all.append(newCase)
    }
  }

  private static let casesStorage = Mutex<(custom: [RuntimeEnvironment], all: [RuntimeEnvironment])>(([], []))

}

extension RuntimeEnvironment: EnvironmentVariableDiscoverable {

  public static let environmentVariableNames: [String] = ["SOLID_ENV"]

  public init?(environmentVariableValue: String) {
    guard let env = Self.find(named: environmentVariableValue) else {
      return nil
    }
    self = env
  }

  public static func interrogateEnvironment(_ environment: ProcessEnvironment) -> RuntimeEnvironment? {
    if let envValue = environment.value(forName: "CI", as: Bool.self) {
      return envValue ? .testing : nil
    }
    return nil
  }

  public static var environmentDefaultValue: RuntimeEnvironment? {
    #if DEBUG
      return .development
    #else
      return .testing
    #endif
  }

}
