//
//  ProcessEnvironmentSource.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

public protocol ProcessEnvironmentSource: Sendable {

  var priority: Int { get }

  func value(forName name: String) -> String?
  func value(forNames names: [String]) -> String?

}

extension ProcessEnvironmentSource {

  public func value(forName name: String) -> String? { value(forNames: [name]) }

}
