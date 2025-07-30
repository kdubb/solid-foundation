//
//  DateTimeComponentKind.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/11/25.
//

public protocol DateTimeComponentKind: ComponentKind {}

public protocol IntegerDateTimeComponentKind: DateTimeComponentKind where Value: SignedInteger {
  var range: ClosedRange<Value> { get }
}
