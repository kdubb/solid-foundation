//
//  URI.swift
//  Codex
//
//  Created by Kevin Wooten on 2/8/25.
//

import Foundation

public enum URI {

  public enum Requirement {

    public enum Kind {
      case relative
      case absolute
      case name
    }

    public enum Fragment {
      case required
      case disallowed(emptyAllowed: Bool)
      case optional
    }

    case kind(Kind)
    case normalized
    case fragment(Fragment)
  }

  public enum Component {

    public enum Kind {
      case scheme
      case host
      case port
      case user
      case password
      case path
      case query
      case queryItem(name: String)
      case fragment

      public static let authority: Set<Self> = [.host, .port, .user, .password]
      public static let userInfo: Set<Self> = [.user, .password]
      public static let subresource: Set<Self> = [.query, .fragment]
      public static func queryItems(_ names: String...) -> Set<Self> { Set(names.map { .queryItem(name: $0) }) }

      public static let all = Set<Self>([
        .scheme,
        .host,
        .port,
        .user,
        .password,
        .path,
        .query,
        .fragment,
      ])
    }

    case scheme(String)
    case host(String)
    case port(Int)
    case user(String)
    case password(String)
    case path([PathItem])
    case query([QueryItem])
    case fragment(String)
  }

  public struct QueryItem {

    public var name: String
    public var value: String?

    public init(name: String, value: String?) {
      self.name = name
      self.value = value
    }
  }

  public struct PathItem {
    public var value: String

    public init(value: String) {
      self.value = value
    }

    public static let root = PathItem(value: "")
    public static let current = PathItem(value: ".")
    public static let parent = PathItem(value: "..")
  }

  public struct Absolute {

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

    public var scheme: String
    public var authority: Authority
    public var path: [PathItem]
    public var query: [QueryItem]
    public var fragment: String?

    public init(
      scheme: String,
      authority: Authority,
      path: [PathItem],
      query: [URI.QueryItem],
      fragment: String?
    ) {
      self.scheme = scheme
      self.authority = authority
      self.path = path.normalized
      self.query = query
      self.fragment = fragment
    }

    var isAbsolute: Bool { true }
  }

  public struct Relative {

    public var path: [PathItem]
    public var query: [QueryItem]
    public var fragment: String?

    public init(path: [PathItem], query: [QueryItem], fragment: String?) {
      self.path = path.normalized
      self.query = query
      self.fragment = fragment
    }

    var isAbsolute: Bool { false }
  }

  public struct Name {

    public var scheme: String
    public var path: String
    public var query: [QueryItem]
    public var fragment: String?

    public init(scheme: String, path: String, query: [QueryItem], fragment: String?) {
      self.scheme = scheme
      self.path = path
      self.query = query
      self.fragment = fragment
    }

    var isAbsolute: Bool { true }
  }

  case absolute(Absolute)
  case relative(Relative)
  case name(Name)

  public init?(encoded string: String, requirements: Set<Requirement> = []) {
    guard let components = URLComponents(string: string) else {
      return nil
    }
    self  = components.uri
  }

  public init(valid: String) {
    guard let uri = URI(encoded: valid) else {
      fatalError("Invalid URI: \(valid)")
    }
    self = uri
  }

  public static func valid(_ valid: String) -> URI {
    return URI(valid: valid)
  }

  public init?(url: URL) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
      return nil
    }
    self = components.uri
  }

  public var encoded: String {
    switch self {
    case .absolute(let absolute): absolute.encoded
    case .relative(let relative): relative.encoded
    case .name(let name): name.encoded
    }
  }

  public var isAbsolute: Bool {
    switch self {
    case .absolute: true
    case .relative: false
    case .name: true
    }
  }

  public var isRelative: Bool {
    guard case .relative = self else {
      return false
    }
    return true
  }

  public var scheme: String? {
    switch self {
    case .absolute(let absolute): absolute.scheme
    case .relative: nil
    case .name(let name): name.scheme
    }
  }

  public var query: [QueryItem] {
    switch self {
    case .absolute(let absolute): absolute.query
    case .relative(let relative): relative.query
    case .name(let name): name.query
    }
  }

  public var fragment: String? {
    switch self {
    case .absolute(let absolute): absolute.fragment
    case .relative(let relative): relative.fragment
    case .name(let name): name.fragment
    }
  }

  public var url: URL {
    switch self {
    case .absolute(let absolute): absolute.url
    case .relative(let relative): relative.url
    case .name(let name): name.url
    }
  }

  public func replacing(fragment: String) -> URI {
    switch self {
    case .absolute(let absolute): absolute.replacing(fragment: fragment)
    case .relative(let relative): relative.replacing(fragment: fragment)
    case .name(let name): name.replacing(fragment: fragment)
    }
  }

  public func replacing(fragmentPointer pointer: Pointer) -> URI {
    replacing(fragment: pointer.encoded)
  }

  public func replacing(fragmentPointer tokens: Pointer.ReferenceToken) -> URI {
    replacing(fragmentPointer: Pointer(tokens: tokens))
  }

  public func appending(fragmentPointer pointer: Pointer) -> URI? {
    switch self {
    case .absolute(let absolute): absolute.appending(fragmentPointer: pointer)
    case .relative(let relative): relative.appending(fragmentPointer: pointer)
    case .name(let name): name.appending(fragmentPointer: pointer)
    }
  }

  public func appending(fragmentPointer tokens: Pointer.ReferenceToken...) -> URI? {
    appending(fragmentPointer: Pointer(tokens: tokens))
  }

  public func updating(_ components: Component.Kind...) -> URI {
    removing(Set(components))
  }

  public func updating(_ components: Set<Component>) -> URI {
    switch self {
    case .absolute(let absolute): absolute.updating(Set(components))
    case .relative(let relative): relative.updating(Set(components))
    case .name(let name): name.updating(components)
    }
  }

  public func removing(_ components: Component.Kind...) -> URI {
    removing(Set(components))
  }

  public func removing(_ components: some Sequence<Component.Kind>) -> URI {
    switch self {
    case .absolute(let absolute): absolute.removing(parts: components)
    case .relative(let relative): relative.removing(parts: components)
    case .name(let name): name.removing(parts: components)
    }
  }

  public enum RelativePathStyle {
    case relative
    case absolute
    case directory
  }

  public func relative(pathStyle: RelativePathStyle = .directory) -> URI {
    switch self {
    case .relative:
      return self
    case .absolute(let absolute):
      let path = switch pathStyle {
      case .absolute: absolute.path.absolute
      case .relative: absolute.path.relative
      case .directory: absolute.path.directoryRelative
      }
      return .relative(
        path: path,
        query: absolute.query,
        fragment: absolute.fragment
      )
    case .name(let name):
      return .relative(path: [], query: name.query, fragment: name.fragment)
    }
  }

  public func resolved(against base: URI) -> URI {
    switch (self, base) {
    case (.absolute, .absolute): self
    case (.relative(let rel), .absolute(let abs)): rel.resolved(against: abs)
    case (.relative(let rel), .name(let name)): rel.resolved(against: name)
    default: self
    }
  }

  public func resolved(against base: String) -> URI? {
    guard let baseURI = URI(encoded: base) else {
      return nil
    }
    return resolved(against: baseURI)
  }

  public func relative(to absolute: URI) -> URI {
    switch (self, absolute) {
    case (.absolute(let specific), .absolute(let base)): specific.relative(to: base)
    case (.name(let a), .name(let b)): a.relative(to: b)
    default: self
    }
  }

  public func relative(to absolute: String) -> URI? {
    guard let absoluteURI = URI(encoded: absolute) else {
      return nil
    }
    return relative(to: absoluteURI)
  }

}

extension URI: Sendable {}
extension URI: Hashable {}
extension URI: Equatable {}

extension URI.Component: Sendable {}
extension URI.Component: Hashable {}
extension URI.Component: Equatable {}

extension URI.Component.Kind: Sendable {}
extension URI.Component.Kind: Hashable {}
extension URI.Component.Kind: Equatable {}

extension Set where Element == URI.Component.Kind {

  public static let all: Set<Element> = [
    .scheme,
    .host,
    .port,
    .user,
    .password,
    .path,
    .query,
    .fragment
  ]

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
    if let value = encodedValue {
      return "\(name)=\(value)"
    } else {
      return name
    }
  }

}

extension Array where Element == URI.QueryItem {

  public var encoded: String {
    map(\.encoded).joined(separator: "&")
  }

}

extension URI.PathItem: Sendable {}
extension URI.PathItem: Hashable {}
extension URI.PathItem: Equatable {}

extension URI.PathItem {

  public var encoded: String {
    value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
  }

}

extension Array where Element == URI.PathItem {

  public static func from(encoded path: String, absolute: Bool) -> Self {
    let segmentStrings = path.split(separator: "/", omittingEmptySubsequences: false)
    let prefix: [URI.PathItem] = absolute && segmentStrings.first != "" ? [.root] : []
    guard !segmentStrings.isEmpty && segmentStrings != [""] else {
      return prefix
    }
    return prefix + segmentStrings.map { URI.PathItem(value: String($0)) }
  }

  public func encoded(relative: Bool) -> String {
    if relative && first?.value.contains(":") == true {
      ([.current] + self).map(\.encoded).joined(separator: "/")
    } else {
      map(\.encoded).joined(separator: "/")
    }
  }

  public var normalized: Self {
    var segments: [URI.PathItem] = []
    for (idx, segment) in enumerated() {
      switch segment {
      case .root:
        if idx == 0 || idx == self.endIndex - 1 {
          segments.append(.root)
        }
      case .current:
        if idx == 0 {
          segments.append(segment)
        }
        break
      case .parent:
        if !segments.isEmpty {
          segments.removeLast()
        }
      default:
        segments.append(segment)
      }
    }
    return segments == [.root] ? [.root] : segments
  }

  public var absolute: Self {
    if first != .root {
      return [.root] + self
    }
    return self
  }

  public var relative: Self {
    if first == .root {
      return dropFirst().asArray()
    }
    return self
  }

  public var directoryRelative: Self {
    [.current] + relative
  }

}

extension URI.Absolute: Sendable {}
extension URI.Absolute: Hashable {}
extension URI.Absolute: Equatable {}

extension URI.Absolute {

  public func copy(
    scheme: String? = nil,
    authority: Authority? = nil,
    path: [URI.PathItem]? = nil,
    query: [URI.QueryItem]? = nil,
    fragment: String?? = nil
  ) -> Self {
    Self(
      scheme: scheme ?? self.scheme,
      authority: authority ?? self.authority,
      path: path ?? self.path,
      query: query ?? self.query,
      fragment: fragment ?? self.fragment
    )
  }

  public var encodedScheme: String {
    scheme.lowercased()
  }

  public var encodedAuthority: String {
    authority.encoded
  }

  public var encodedPath: String {
    path.encoded(relative: false)
  }

  public var encodedQuery: String? {
    query.nilIfEmpty()?.encoded
  }

  public var encodedFragment: String? {
    fragment?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
  }

  public var encoded: String {
    let query = encodedQuery.map { "?\($0)" } ?? ""
    let fragment = encodedFragment.map { "#\($0)" } ?? ""
    return "\(scheme)://\(encodedAuthority)\(encodedPath)\(query)\(fragment)"
  }

  public var url: URL {
    var components = URLComponents()
    components.scheme = scheme
    components.encodedHost = authority.encodedHost
    components.port = authority.port
    components.percentEncodedUser = authority.userInfo?.encodedUser
    components.percentEncodedPassword = authority.userInfo?.encodedPassword
    components.percentEncodedPath = encodedPath
    components.percentEncodedQuery = encodedQuery
    components.percentEncodedFragment = encodedFragment
    return components.url.neverNil()
  }

  public func updating(_ components: some Sequence<URI.Component>) -> URI {
    var copy = self
    for component in components {
      switch component {
      case .scheme(let scheme):
        copy = self.copy(scheme: scheme)
      case .host(let host):
        copy = self.copy(authority: copy.authority.copy(host: host))
      case .port(let port):
        copy = self.copy(authority: copy.authority.copy(port: port))
      case .user(let user):
        copy = self.copy(authority: copy.authority.copy(userInfo: copy.authority.userInfo?.copy(user: user)))
      case .password(let password):
        copy = self.copy(authority: copy.authority.copy(userInfo: copy.authority.userInfo?.copy(password: password)))
      case .path(let path):
        copy = self.copy(path: path)
      case .query(let query):
        copy = self.copy(query: query)
      case .fragment(let fragment):
        copy = self.copy(fragment: fragment)
      }
    }
    return .absolute(copy)
  }

  public func removing(parts: some Sequence<URI.Component.Kind>) -> URI {
    var result = self
    for part in parts {
      switch part {
      case .user:
        result = result.copy(authority: authority.copy(userInfo: .some(authority.userInfo?.copy(user: .some(nil)))))
      case .password:
        result = result.copy(authority: authority.copy(userInfo: .some(authority.userInfo?.copy(password: .some(nil)))))
      case .port:
        result = result.copy(authority: authority.copy(port: .some(nil)))
      case .path:
        result = result.copy(path: [])
      case .query:
        result = result.copy(query: [])
      case .fragment:
        result = result.copy(fragment: .some(nil))
      default:
        break
      }
    }
    return .absolute(result)
  }

  public var fragmentPointer: Pointer? {
    guard let fragment = fragment else {
      return nil
    }
    return Pointer(encoded: fragment)
  }

  public func replacing(fragment: String) -> URI {
    .absolute(copy(fragment: fragment))
  }

  public func replacing(fragmentPointer pointer: Pointer) -> URI {
    replacing(fragment: pointer.encoded)
  }

  public func appending(fragmentPointer pointer: Pointer) -> URI? {
    if let fragment {
      guard let fragmentPointer = Pointer(encoded: fragment) else {
        return nil
      }
      return .absolute(copy(fragment: (fragmentPointer / pointer).encoded))
    } else {
      return replacing(fragmentPointer: pointer)
    }
  }

  public func relative(to other: URI.Absolute) -> URI {

    let selfPath = path
    let otherPath = other.path

    guard
      scheme == other.scheme,
      authority == other.authority,
      selfPath.count >= otherPath.count
    else {
      return .absolute(self)
    }

    var commonPrefixCount = 0
    while commonPrefixCount < min(selfPath.count, otherPath.count),
          selfPath[commonPrefixCount] == otherPath[commonPrefixCount] {
      commonPrefixCount += 1
    }

    let relPath = Array([.current] + selfPath.dropFirst(commonPrefixCount))
    let query = self.query.nilIfEmpty() ?? other.query
    let fragment = self.fragment ?? other.fragment

    return .relative(path: relPath, query: query, fragment: fragment)
  }

}

extension URI.Absolute.Authority: Sendable {}
extension URI.Absolute.Authority: Hashable {}
extension URI.Absolute.Authority: Equatable {}

extension URI.Absolute.Authority {

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
    _ userInfo: URI.Absolute.Authority.UserInfo? = nil
  ) -> Self {
    Self(host: host, port: port, userInfo: userInfo)
  }

  public var encodedHost: String {
    host.lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
  }

  public var encoded: String {
    let hostPort = "\(encodedHost)\(port.map { ":\($0)" } ?? "")"
    if let userInfo = userInfo {
      return "\(userInfo.encoded)@\(hostPort)"
    } else {
      return hostPort
    }
  }

}

extension URI.Absolute.Authority.UserInfo: Sendable {}
extension URI.Absolute.Authority.UserInfo: Hashable {}
extension URI.Absolute.Authority.UserInfo: Equatable {}

extension URI.Absolute.Authority.UserInfo {

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
    ).emptyToNil
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

extension URI.Relative: Sendable {}
extension URI.Relative: Hashable {}
extension URI.Relative: Equatable {}

extension URI.Relative {

  public func copy(
    path: [URI.PathItem]? = nil,
    query: [URI.QueryItem]? = nil,
    fragment: String?? = nil
  ) -> Self {
    Self(
      path: path ?? self.path,
      query: query ?? self.query,
      fragment: fragment ?? self.fragment
    )
  }

  public var isAbsolutePath: Bool {
    path.first == .root
  }

  public var encodedPath: String? {
    path.encoded(relative: true)
  }

  public var encodedQuery: String? {
    query.nilIfEmpty()?.encoded
  }

  public var encodedFragment: String? {
    fragment?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
  }

  public var encoded: String {
    let path = encodedPath ?? ""
    let query = encodedQuery.map { "?\($0)" } ?? ""
    let fragment = encodedFragment.map { "#\($0)" } ?? ""
    return "\(path)\(query)\(fragment)"
  }

  public var url: URL {
    var components = URLComponents()
    components.percentEncodedPath = encodedPath ?? ""
    components.percentEncodedQuery = encodedQuery
    components.percentEncodedFragment = fragment
    return components.url.neverNil()
  }

  public func updating(_ components: some Sequence<URI.Component>) -> URI {
    var copy = self
    for component in components {
      switch component {
      case .path(let path):
        copy = self.copy(path: path)
      case .query(let query):
        copy = self.copy(query: query)
      case .fragment(let fragment):
        copy = self.copy(fragment: fragment)
      default:
        break
      }
    }
    return .relative(copy)
  }

  public func removing(parts: some Sequence<URI.Component.Kind>) -> URI {
    var copy = self
    for part in parts {
      switch part {
      case .path:
        copy = self.copy(path: [])
      case .query:
        copy = self.copy(query: [])
      case .fragment:
        copy = self.copy(fragment: .some(nil))
      default:
        break
      }
    }
    return .relative(copy)
  }

  public func replacing(fragment: String) -> URI {
    .relative(copy(fragment: fragment))
  }

  public func appending(fragmentPointer pointer: Pointer) -> URI? {
    guard let baseFragmentPointer = self.fragment.map(Pointer.init(encoded:)) ?? nil else {
      return nil
    }
    let fragmentPointer = baseFragmentPointer / pointer
    return .relative(copy(fragment: fragmentPointer.encoded))
  }

  public func resolved(against base: URI.Absolute) -> URI {
    let selfPath = path
    let basePath = base.path

    var absPath: [URI.PathItem]

    if selfPath.isEmpty {
      absPath = basePath
    } else if basePath.isEmpty || (selfPath.count > 1 && selfPath.first == .root) {
      absPath = selfPath.first != .root ? selfPath : [.root] + selfPath
    } else {
      var resPath: [URI.PathItem] = selfPath.first == .current ? basePath : basePath.dropLast()
      for component in selfPath {
        switch component {
        case .current:
          if resPath.last == .root {
            resPath.removeLast()
          }
          break
        case .parent:
          resPath = resPath.dropLast()
        default:
          resPath.append(component)
        }
      }
      absPath = resPath
    }

    let query = self.query.nilIfEmpty() ?? base.query
    let fragment = self.fragment ?? base.fragment

    return .absolute(
      base.copy(
        path: absPath,
        query: query,
        fragment: fragment
      )
    )
  }

  public func resolved(against base: URI.Name) -> URI {
    let query = self.query.nilIfEmpty() ?? base.query
    let fragment = self.fragment ?? base.fragment
    return .name(base.copy(query: query, fragment: fragment))
  }

}

extension URI.Name: Sendable {}
extension URI.Name: Hashable {}
extension URI.Name: Equatable {}

extension URI.Name {

  public func copy(
    scheme: String? = nil,
    path: String? = nil,
    query: [URI.QueryItem]? = nil,
    fragment: String?? = nil
  ) -> Self {
    Self(
      scheme: scheme ?? self.scheme,
      path: path ?? self.path,
      query: query ?? self.query,
      fragment: fragment ?? self.fragment
    )
  }

  public var encodedPath: String? {
    path.nilIfEmpty()
  }

  public var encodedQuery: String? {
    query.nilIfEmpty()?.encoded
  }

  public var encodedFragment: String? {
    fragment?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
  }

  public var encoded: String {
    let scheme = scheme
    let path = encodedPath ?? ""
    let query = encodedQuery.map { "?\($0)" } ?? ""
    let fragment = encodedFragment.map { "#\($0)" } ?? ""
    return "\(scheme):\(path)\(query)\(fragment)"
  }

  public var url: URL {
    var components = URLComponents()
    components.scheme = scheme
    components.percentEncodedPath = encodedPath ?? ""
    components.percentEncodedQuery = encodedQuery
    components.percentEncodedFragment = encodedFragment
    return components.url.neverNil()
  }

  public func updating(_ components: some Sequence<URI.Component>) -> URI {
    var copy = self
    for component in components {
      switch component {
      case .scheme(let scheme):
        copy = self.copy(scheme: scheme)
      case .path(let path):
        copy = self.copy(path: path.map(\.value).joined(separator: "/"))
      case .query(let query):
        copy = self.copy(query: query)
      case .fragment(let fragment):
        copy = self.copy(fragment: fragment)
      default:
        break
      }
    }
    return .name(copy)
  }

  public func removing(parts: some Sequence<URI.Component.Kind>) -> URI {
    var copy = self
    for part in parts {
      switch part {
      case .query:
        copy = self.copy(query: [])
      case .fragment:
        copy = self.copy(fragment: .some(nil))
      default:
        break
      }
    }
    return .name(copy)
  }

  public func replacing(fragment: String) -> URI {
    .name(copy(fragment: fragment))
  }

  public func appending(fragmentPointer pointer: Pointer) -> URI? {
    let pointerFragment: Pointer
    if let fragment {
      guard let baseFragmentPointer = Pointer.init(encoded: fragment) else {
        return nil
      }
      pointerFragment = baseFragmentPointer / pointer
    } else {
      pointerFragment = pointer
    }
    return .name(copy(fragment: pointerFragment.encoded))
  }

  public func relative(to other: URI.Name) -> URI {

    guard
      scheme == other.scheme,
      path.hasPrefix(other.path)
    else {
      return .name(self)
    }

    return .relative(path: [], query: query.nilIfEmpty() ?? other.query, fragment: fragment ?? other.fragment)
  }

}

extension URI {

  public static func absolute(
    scheme: String,
    authority: URI.Absolute.Authority,
    path: [URI.PathItem] = [],
    query: [URI.QueryItem] = [],
    fragment: String? = nil
  ) -> Self {
    .absolute(.init(scheme: scheme, authority: authority, path: path, query: query, fragment: fragment))
  }

  public static func relative(
    path: [URI.PathItem] = [],
    query: [URI.QueryItem] = [],
    fragment: String? = nil
  ) -> Self {
    .relative(.init(path: path, query: query, fragment: fragment))
  }

  public static func relative(
    encodedPath: String,
    query: [URI.QueryItem] = [],
    fragment: String? = nil
  ) -> Self {
    .relative(.init(path: .from(encoded: encodedPath, absolute: false), query: query, fragment: fragment))
  }

  public static func name(
    scheme: String,
    path: String,
    query: [URI.QueryItem] = [],
    fragment: String? = nil
  ) -> Self {
    .name(.init(scheme: scheme, path: path, query: query, fragment: fragment))
  }

}

extension URI.Requirement: Sendable {}
extension URI.Requirement: Hashable {}
extension URI.Requirement: Equatable {}

extension URI.Requirement.Kind: Sendable {}
extension URI.Requirement.Kind: Hashable {}
extension URI.Requirement.Kind: Equatable {}

extension URI.Requirement.Fragment: Sendable {}
extension URI.Requirement.Fragment: Hashable {}
extension URI.Requirement.Fragment: Equatable {}

extension URI: CustomStringConvertible, CustomDebugStringConvertible {

  public var description: String { encoded }
  public var debugDescription: String { encoded }

}

private extension URLComponents {

  var isURN: Bool {
    scheme != nil && host == nil && port == nil && user == nil && password == nil && path != ""
  }

  var isAbsolute: Bool {
    scheme != nil && (isURN || (host != nil && (path == "" || path.hasPrefix("/"))))
  }

  var uri: URI {
    return if isURN {
      .name(
        URI.Name(
          scheme: scheme!,
          path: path,
          query: queryItems?.compactMap { .from(name: $0.name, value: $0.value) } ?? [],
          fragment: fragment
        )
      )
    } else if isAbsolute {
      .absolute(
        URI.Absolute(
          scheme: scheme!,
          authority: .from(host: host ?? "", port: port, userInfo: .from(user: user, password: password)),
          path: .from(encoded: path, absolute: true),
          query: queryItems?.compactMap { .from(name: $0.name, value: $0.value) } ?? [],
          fragment: fragment
        )
      )
    } else {
      .relative(
        URI.Relative(
          path: .from(encoded: path, absolute: false),
          query: queryItems?.compactMap { URI.QueryItem(name: $0.name, value: $0.value) } ?? [],
          fragment: fragment
        )
      )
    }
  }

}

private extension Array where Element == String {

  func standardizedPath() -> [String] {
    var components: [String] = []
    for component in self {
      switch component {
      case ".":
        break
      case "..":
        components = components.dropLast()
      default:
        components.append(component)
      }
    }
    return components
  }

  func commonPrefix(with other: [String]) -> [String] {
    let pathStandardized = standardizedPath()
    let otherStandardized = other.standardizedPath()

    var commonPrefixCount = 0
    while commonPrefixCount < Swift.min(pathStandardized.count, otherStandardized.count),
          self[commonPrefixCount] == other[commonPrefixCount] {
      commonPrefixCount += 1
    }

    // Number of directories to go up from base to reach the common prefix
    let upLevels = pathStandardized.count - commonPrefixCount
    let upPaths = Array(repeating: "..", count: upLevels)

    // Remaining path from self beyond the common prefix
    let remainingPath = pathStandardized[commonPrefixCount...].map { String($0) }

    // Construct the relative path
    let relPathComponents = upPaths + remainingPath

    return relPathComponents.standardizedPath()
  }

}
