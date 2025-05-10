//
//  DateTime.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/27/25.
//

extension Tempo {

  /// Any composite date and time representation.
  public protocol DateTime: Sendable, ComponentContainer, ComponentBuildable {
    /// The date component.
    var date: LocalDate { get }
    /// The time component.
    var time: LocalTime { get }
  }

}
