//
//  URI-QueryItem.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

extension URI {

  public struct QueryItem {

    public var name: String
    public var value: String?

    public init(name: String, value: String?) {
      self.name = name
      self.value = value
    }
  }

}

extension URI.QueryItem: Sendable {}
extension URI.QueryItem: Hashable {}
extension URI.QueryItem: Equatable {}

extension URI.QueryItem {

  public static func from(name: String?, value: String?) -> Self? {
    guard let name = name else {
      return nil
    }
    return Self(name: name, value: value)
  }

  public static func flag(_ name: String) -> Self {
    Self(name: name, value: nil)
  }

  public static func flag(_ name: String, value: Bool) -> Self {
    Self(name: name, value: value ? "true" : "false")
  }

  public static func name(_ name: String, value: String) -> Self {
    Self(name: name, value: value)
  }

  public static func name(_ name: String, value: String?) -> Self {
    Self(name: name, value: value)
  }

  public var encodedName: String {
    name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
  }

  public var encodedValue: String? {
    value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
  }

  public var encoded: String {
    let name = encodedName
    guard let value = encodedValue else {
      return name
    }
    return "\(name)=\(value)"
  }

}

extension Array where Element == URI.QueryItem {

  public var encoded: String {
    map(\.encoded).joined(separator: "&")
  }

}
