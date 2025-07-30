//
//  SwiftLogIntegration.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/28/25.
//

#if canImport(Logging)

  import Logging
  import Synchronization

  private let defaultPrivacyStorage = Atomic<LogPrivacy>(
    ProcessEnvironment.instance.value(for: LogPrivacy.self) ?? .private
  )

  public extension LogFactory {

    static var defaultPrivacy: LogPrivacy {
      get { defaultPrivacyStorage.load(ordering: .acquiring) }
      set { defaultPrivacyStorage.store(newValue, ordering: .releasing) }
    }

    static func `for`(category: String, name: String) -> SwiftLogLog { .init(label: "\(category).\(name)") }
  }


  public struct SwiftLogLog: Log {

    public let destination: Logger
    public let privacy: LogPrivacy
    public var level: LogLevel {
      switch destination.logLevel {
      case .trace: .trace
      case .debug: .debug
      case .info: .info
      case .notice: .notice
      case .warning: .warning
      case .error: .error
      case .critical: .critical
      }
    }

    public init(label: String, privacy: LogPrivacy = LogFactory.defaultPrivacy) {
      self.destination = Logger(label: label)
      self.privacy = privacy
    }

    public func log(_ event: LogEvent) {
      guard isEnabled(for: event.level) else {
        return
      }
      let message = Logger.Message(stringLiteral: event.message.formattedString(for: privacy))
      let level: Logger.Level =
        switch event.level {
        case .trace: .trace
        case .debug: .debug
        case .info: .info
        case .notice: .notice
        case .warning: .warning
        case .error: .error
        case .critical: .critical
        }
      destination.log(level: level, message)
    }

  }

#endif
