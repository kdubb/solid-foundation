//
//  TzDb.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/9/25.
//

import SolidCore
import Foundation
import Synchronization


/// ``ZoneRules`` provider for `tzdb`/`zoneinfo`.
///
/// During initialization, all available `TZif` files are discovered and prepared
/// for lazy loading in a static static dictionary cache. During discovery,
/// no loading or parsing of the associated file TZif files is completed. The
/// files are parsed, validated, and converted to ``ZoneRules``
/// on-demand when a request for the specific zone identifier is made.
///
/// ## Concurrency
/// The static zone entries dictionary ensiures unlocked access to all
/// previously loaded files. Locking only occurs when data for a specific
/// zone is being loaded. After loading, double checked locking is used to
/// ensure that the loading lock does not need to be held for each subsequent
/// access to the zone entry.
///
public final class TzDb: ZoneRulesLoader {

  internal static let log = LogFactory.for(type: TzDb.self)

  /// Errors related to loading ``ZoneRules`` from `zoneinfo` data.
  public enum Error: Swift.Error {
    case zoneInfoNotFound
    case unableToLoadZone(Swift.Error)
  }

  /// The default locations to search for `zoneinfo` data.
  public static let defaultZoneInfoUrls: [URL] = [
    URL(filePath: "/usr/share/zoneinfo/")
  ]

  /// Possible names for  the `zoneinfo` version stamp file.
  public static let versionFileName = "+VERSION"

  final class ZoneEntry: Sendable {

    final class State: Sendable {

      enum Value {
        case loaded(ZoneRules, parsed: TzIf.Rules?)
        case failed(Swift.Error)

        public var rules: ZoneRules {
          get throws {
            switch self {
            case .loaded(let rules, parsed: _):
              return rules
            case .failed(let error):
              throw error
            }
          }
        }
      }

      private let value: Value

      init(_ value: Value) {
        self.value = value
      }

      public var rules: ZoneRules {
        get throws {
          try value.rules
        }
      }
    }

    let url: URL
    let retainParsed: Bool
    let state: AtomicLazyReference<State>

    init(url: URL, retainParsed: Bool = false) {
      self.url = url
      self.retainParsed = retainParsed
      self.state = AtomicLazyReference<State>()
    }

    func load() throws -> ZoneRules {
      if let state = state.load() {
        return try state.rules
      }

      // Load rules and initialize state
      let state: State
      do {
        let tzIfRules = try TzIf.load(url: url)
        let zoneRules = try TzIf.buildZoneRules(rules: tzIfRules)
        state = self.state.storeIfNil(.init(.loaded(zoneRules, parsed: retainParsed ? tzIfRules : nil)))
      } catch {
        state = self.state.storeIfNil(.init(.failed(error)))
      }
      return try state.rules
    }
  }

  /// Default instance of ``TzDb`` that attempts to use the system provided
  /// `zoneinfo` directory.
  ///
  public static let `default` = TzDb(zoneInfoUrls: defaultZoneInfoUrls)

  /// URL of the resolved `zoneinfo` directory.
  public let url: URL

  /// Version of the `zoneinfo` data.
  public let version: String

  /// On-demand loader for each zone info data file.
  let zones: [String: ZoneEntry]

  /// Initializes a new `TzDb` with a list of possible `zoneinfo` URLs
  /// to initialize from.
  ///
  /// Initialization checks each provided URL for a proper `zoneinfo` structure,
  /// choosing the first valid directory found. If no valid directory is found, then
  /// the loader will be initialized as an "empty" database.
  ///
  /// During the `zoneinfo` directory is traversed for files matching the `TZif`
  /// format, and a cache entry is created for each file. The files are not loaded or
  /// parsed until a request for the specific zone identifier is made.
  ///
  /// - Parameters:
  ///   - zoneInfoUrls: A list of URLs to search for `zoneinfo` data.
  ///   - retainParsedRules: If `true`, the parsed ``TzIf/Rules``
  ///   data will be retained along with the ``ZoneRules`` implementation.
  ///   This is useful for debugging and testing, but increases memory usage.
  ///
  public init(zoneInfoUrls: [URL], retainParsedRules: Bool = false) {
    do {
      let (zoneInfoUrl, zoneInfoVersion, zoneInfoDataUrls) = try Self.discoverZoneInfo(urls: zoneInfoUrls)

      Self.log.info("Discovered tzdb v\(zoneInfoVersion) at \(zoneInfoUrl) with \(zoneInfoDataUrls.count) zones")

      self.url = zoneInfoUrl
      self.version = zoneInfoVersion
      self.zones = Dictionary(uniqueKeysWithValues: zoneInfoDataUrls.map { ($0.relativePath, ZoneEntry(url: $0)) })
    } catch {
      Self.log.error("Failed to initialize \(Self.self): \(error)")
      self.url = URL(fileURLWithPath: "")
      self.version = ""
      self.zones = [:]
    }
  }

  /// Loads a ``ZoneRules`` implementation for the specified zone identifier.
  ///
  /// If the identifier is known, this method will load the zone rules from a pre-discovered
  /// zone info file, otherwise it will throw an error.
  ///
  /// - Note: This method is thread-safe and will only load the zone rules once, caching
  /// them for subsequent requests.
  ///
  public func load(identifier: String) throws -> any ZoneRules {
    guard let entry = zones[identifier] else {
      throw TempoError.invalidRegionalTimeZone(identifier: identifier)
    }
    return try entry.load()
  }

  /// Discover zone info files at any of the specified URLs.
  ///
  /// Each provided URL is checked for the presence of a valid `zoneinfo` directory.
  /// The first valid directory found is returned along with its version and list of data file
  /// URLs.
  ///
  private static func discoverZoneInfo(urls: [URL]) throws -> (url: URL, version: String, dataUrls: [URL]) {
    for url in urls {
      do {
        return try discoverZoneInfo(at: url)
      } catch {
        log.error("Failed to discover zone info files at \(url): \(error)")
        continue
      }
    }
    throw Error.zoneInfoNotFound
  }

  /// Discover zone info files at the specified URL.
  ///
  private static func discoverZoneInfo(
    at zoneInfoURL: URL
  ) throws -> (url: URL, version: String, dataUrls: [URL]) {
    let fileManager = FileManager.default

    var previousZoneInfoURL = zoneInfoURL
    var resolvedZoneInfoURL = zoneInfoURL
    repeat {
      previousZoneInfoURL = resolvedZoneInfoURL
      resolvedZoneInfoURL = zoneInfoURL.resolvingSymlinksInPath()
    } while resolvedZoneInfoURL != previousZoneInfoURL

    let version = try loadZoneInfoVersionFile(zoneInfoURL: zoneInfoURL)

    guard
      let contents = fileManager.enumerator(
        at: resolvedZoneInfoURL,
        includingPropertiesForKeys: [.isDirectoryKey],
        options: [.skipsHiddenFiles, .producesRelativePathURLs]
      )
    else {
      Self.log.error("Failed to enumerate zone info files at \(resolvedZoneInfoURL)")
      return (resolvedZoneInfoURL, version, [])
    }

    var urls: [URL] = []
    for case let url as URL in contents where isZoneInfoFileLike(url) {
      urls.append(url)
    }

    return (resolvedZoneInfoURL, version, urls)
  }

  private static func isZoneInfoFileLike(_ url: URL) -> Bool {
    let fileName = url.lastPathComponent
    return (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == false
      && !fileName.hasPrefix("+")
      && !fileName.allSatisfy(\.isLowercase)
      && url.pathExtension.isEmpty
  }

  private static func loadZoneInfoVersionFile(zoneInfoURL: URL) throws -> String {
    do {
      let versionFileURL = zoneInfoURL.appendingPathComponent(versionFileName)
      let versionString = try String(contentsOf: versionFileURL, encoding: .utf8)
      return versionString.trimmingCharacters(in: .whitespacesAndNewlines)
    } catch {
      throw Error.unableToLoadZone(error)
    }
  }
}

extension ZoneRulesLoader where Self == TzDb {

  public static var system: Self { TzDb.default }

}
