//
//  Validated.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

import SolidCore

@propertyWrapper
public struct Validated<Value>: Sendable where Value: Sendable {

  public var component: any Component<Value>
  public var wrappedValue: Value

  public init(wrappedValue: Value, _ component: some Component<Value>) {
    self.component = component
    self.wrappedValue = wrappedValue
  }

  public var projectedValue: Result<Value, Swift.Error> {
    do {
      try component.validate(wrappedValue)
      return .success(wrappedValue)
    } catch {
      return .failure(error)
    }
  }

  public func assert(_ test: Bool, _ message: String) throws {
    if !test {
      throw Error.invalidComponentValue(component: component.id.name, reason: .unknown(reason: message))
    }
  }
}

@propertyWrapper
public struct ValidatedOptional<Value>: Sendable where Value: Sendable {

  public var component: any Component<Value>
  public var wrappedValue: Value?
  public var defaultValue: Value?

  public init(wrappedValue: Value?, _ component: some Component<Value>, default: Value? = nil) {
    self.component = component
    self.wrappedValue = wrappedValue
    self.defaultValue = `default`
  }

  public var projectedValue: Result<Value?, Swift.Error> {
    do {
      guard let wrappedValue else {
        return .success(nil)
      }
      try component.validate(wrappedValue)
      return .success(wrappedValue)
    } catch {
      return .failure(error)
    }
  }
}

extension Result where Success: OptionalConvertible {

  internal func getOrElse(_ defaultValue: Success.Wrapped) throws -> Success.Wrapped {
    switch self {
    case .success(let value):
      return value.toOptional ?? defaultValue
    case .failure(let error):
      throw error
    }
  }

}
