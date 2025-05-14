//
//  DateTimeComponent.swift
//  Codex
//
//  Created by Kevin Wooten on 5/11/25.
//

public protocol DateTimeComponent: Component {}

public protocol IntegerDateTimeComponent: DateTimeComponent where Value: SignedInteger {
  var range: ClosedRange<Value> { get }
}
