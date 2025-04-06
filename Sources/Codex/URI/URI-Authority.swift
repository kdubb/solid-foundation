//
//  URI-Authority.swift
//  Codex
//
//  Created by Kevin Wooten on 2/26/25.
//

extension URI {

  public struct Authority {

    public struct UserInfo {

      public var user: String?
      public var password: String?

      public init(user: String?, password: String?) {
        self.user = user
        self.password = password
      }
    }

    public var host: String
    public var port: Int?
    public var userInfo: UserInfo?

    public init(host: String, port: Int?, userInfo: UserInfo?) {
      self.host = host
      self.port = port
      self.userInfo = userInfo?.emptyToNil
    }
  }

}

extension URI.Authority: Sendable {}
extension URI.Authority: Hashable {}
extension URI.Authority: Equatable {}

extension URI.Authority {

  public static func from(host: String, port: Int? = nil, userInfo: UserInfo? = nil) -> Self {
    Self(host: host, port: port, userInfo: userInfo)
  }

  public func copy(
    host: String? = nil,
    port: Int?? = nil,
    userInfo: UserInfo?? = nil
  ) -> Self {
    Self(
      host: host ?? self.host,
      port: port ?? self.port,
      userInfo: userInfo ?? self.userInfo
    )
  }

  public static func host(
    _ host: String,
    port: Int? = nil,
    _ userInfo: URI.Authority.UserInfo? = nil
  ) -> Self {
    Self(host: host, port: port, userInfo: userInfo)
  }

  public var encodedHost: String {
    host.lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
  }

  public var encoded: String {
    let hostPort = "\(encodedHost)\(port.map { ":\($0)" } ?? "")"
    guard let userInfo = userInfo else {
      return hostPort
    }
    return "\(userInfo.encoded)@\(hostPort)"
  }

}

extension URI.Authority.UserInfo: Sendable {}
extension URI.Authority.UserInfo: Hashable {}
extension URI.Authority.UserInfo: Equatable {}

extension URI.Authority.UserInfo {

  public static func from(user: String?, password: String?) -> Self? {
    Self(user: user, password: password).emptyToNil
  }

  public func copy(
    user: String?? = nil,
    password: String?? = nil
  ) -> Self? {
    Self(
      user: user ?? self.user,
      password: password ?? self.password
    )
    .emptyToNil
  }

  public static func user(_ user: String) -> Self {
    Self(user: user, password: nil)
  }

  public static func user(_ user: String, password: String) -> Self {
    Self(user: user, password: password)
  }

  public var emptyToNil: Self? {
    guard user != nil || password != nil else {
      return nil
    }
    return self
  }

  public var encodedUser: String? {
    user?.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)
  }

  public var encodedPassword: String? {
    password?.addingPercentEncoding(withAllowedCharacters: .urlPasswordAllowed)
  }

  public var encoded: String {
    return switch (encodedUser, encodedPassword) {
    case (.some(let user), .some(let password)): "\(user):\(password)"
    case (.some(let user), .none): user
    case (.none, .some(let password)): ":\(password)"
    default: ""
    }
  }

}
