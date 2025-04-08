//
//  URI-Authority.swift
//  Codex
//
//  Created by Kevin Wooten on 2/26/25.
//

extension URI {

  /// The authority component of a URI.
  ///
  /// The authority component contains user information, host, and port.
  /// It appears after the scheme and before the path in a URI.
  ///
  public struct Authority {

    /// User information for the authority component.
    ///
    /// Contains the username and password for authentication.
    ///
    public struct UserInfo {

      /// The username, if present.
      public var user: String?
      /// The password, if present.
      public var password: String?

      /// Creates a new UserInfo instance.
      ///
      /// - Parameters:
      ///   - user: The username
      ///   - password: The password
      ///
      public init(user: String?, password: String?) {
        self.user = user
        self.password = password
      }
    }

    /// The host name or IP address.
    public var host: String
    /// The port number, if specified.
    public var port: Int?
    /// The user information, if present.
    public var userInfo: UserInfo?

    /// Creates a new Authority instance.
    ///
    /// - Parameters:
    ///   - host: The host name or IP address
    ///   - port: The port number
    ///   - userInfo: The user information
    ///
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

  /// Creates a new ``URI/Authority`` instance.
  ///
  /// - Parameters:
  ///   - host: The host name or IP address
  ///   - port: The port number, or `nil` if the default port for the scheme should be used
  ///   - userInfo: The user information, or `nil` if the authority is not protected by user information
  /// - Returns: A new Authority instance
  ///
  public static func from(host: String, port: Int? = nil, userInfo: UserInfo? = nil) -> Self {
    Self(host: host, port: port, userInfo: userInfo)
  }

  /// Creates a new ``URI/Authority`` instance, if one or more of the parameters are provided.
  ///
  /// - Parameters:
  ///   - host: The host name or IP address
  ///   - port: The port number, or `nil` if the default port for the scheme should be used
  ///   - userInfo: The user information, or `nil` if the authority is not protected by user information
  /// - Returns: A new Authority instance if at least one of the parameters is provided, otherwise `nil`
  ///
  public static func from(host: String?, port: Int? = nil, userInfo: UserInfo? = nil) -> Self? {
    guard host != nil || port != nil || userInfo != nil else {
      return nil
    }
    return Self(host: host ?? "", port: port, userInfo: userInfo)
  }

  /// Creates a copy of this ``URI/Authority`` with one or more properties updated.
  ///
  /// - Parameters:
  ///   - host: The new host name or IP address, or `nil` to leave the host name unchanged
  ///   - port: The new port number, or `nil` to leave the port number unchanged
  ///   - userInfo: The new user information, or `nil` to leave the user information unchanged
  /// - Returns: A new Authority instance with the specified properties updated.
  ///
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

  /// Creates a new ``URI/Authority`` instance with the given hostname or IP address and
  /// optionally, a port number and user information.
  ///
  /// - Parameters:
  ///   - host: The host name or IP address
  ///   - port: The port number, or `nil` to use the default port for the scheme
  ///   - userInfo: The user information, or `nil` to use no user information
  /// - Returns: A new Authority instance
  public static func host(
    _ host: String,
    port: Int? = nil,
    _ userInfo: URI.Authority.UserInfo? = nil
  ) -> Self {
    Self(host: host, port: port, userInfo: userInfo)
  }

  /// The encoded host name or IP address.
  ///
  /// - Returns: The encoded host name or IP address
  public var encodedHost: String {
    host.lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
  }

  /// Encoded version of the authority.
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

  /// Creates a new ``URI/Authority/UserInfo-swift.struct`` instance, if one or more of the parameters are provided.
  ///
  /// - Parameters:
  ///   - user: The username
  ///   - password: The password
  /// - Returns: A new UserInfo instance if at least one of the parameters is provided, otherwise `nil`
  ///
  public static func from(user: String?, password: String?) -> Self? {
    Self(user: user, password: password).emptyToNil
  }

  /// Creates a copy of this ``URI/Authority/UserInfo`` instance with one or more properties updated.
  ///
  /// - Parameters:
  ///   - user: The new username, or `nil` to leave the username unchanged
  ///   - password: The new password, or `nil` to leave the password unchanged
  /// - Returns: A new Authority instance with the specified properties updated.
  ///
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

  /// Creates a new ``URI/Authority/UserInfo-swift.struct`` instance with the given username.
  ///
  /// - Parameter user: The username
  /// - Returns: A new UserInfo instance
  ///
  public static func user(_ user: String) -> Self {
    Self(user: user, password: nil)
  }

  /// Creates a new ``URI/Authority/UserInfo-swift.struct`` instance with the given username and password.
  ///
  /// - Parameters:
  ///   - user: The username
  ///   - password: The password
  /// - Returns: A new UserInfo instance
  ///
  public static func user(_ user: String, password: String) -> Self {
    Self(user: user, password: password)
  }

  /// Returns `nil` if the all the propertiees are empty, otherwise returns this user unchanged.
  ///
  /// - Returns: `nil` if the user info is empty, otherwise the user info itself
  ///
  public var emptyToNil: Self? {
    guard user != nil || password != nil else {
      return nil
    }
    return self
  }

  /// The encoded username.
  ///
  /// - Returns: The encoded username, or `nil` if the username is empty
  ///
  public var encodedUser: String? {
    user?.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)
  }

  /// The encoded password.
  ///
  /// - Returns: The encoded password, or `nil` if the password is empty
  ///
  public var encodedPassword: String? {
    password?.addingPercentEncoding(withAllowedCharacters: .urlPasswordAllowed)
  }

  /// The encoded user info.
  ///
  /// - Returns: The encoded user info, or `nil` if the user info is empty
  ///
  public var encoded: String {
    return switch (encodedUser, encodedPassword) {
    case (.some(let user), .some(let password)): "\(user):\(password)"
    case (.some(let user), .none): user
    case (.none, .some(let password)): ":\(password)"
    default: ""
    }
  }

}
