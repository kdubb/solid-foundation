//
//  SystemInstantSource.swift
//  Codex
//
//  Created by Kevin Wooten on 4/26/25.
//

import Synchronization

extension Tempo {

  public struct SystemInstantSource: InstantSource {

    private static let systemInstantSourceDefault = Mutex<InstantSource>(Self())

    /// The default instance of `InstantSource` to be used for
    /// the current task.
    ///
    /// This is a task-local value and will be used when ``instance`` or
    /// ``Tempo/InstantSource/system`` is accessed.
    ///
    @TaskLocal
    public static var systemInstantSource: InstantSource? = nil

    /// The default instance of `SystemInstantSource` to be used.
    ///
    /// The default instance is the fastest, hghest-resolution system clock provided
    /// by the current platform.
    ///
    public static var instance: InstantSource {
      systemInstantSource ?? systemInstantSourceDefault.withLock { $0 }
    }

    /// Sets the default instance of `SystemInstantSource` to be used
    /// when ``instance`` or  ``Tempo/InstantSource/system`` is
    /// accessed.
    ///
    /// This is available to allow driving the system clock by an alternate source
    /// globally and should be used with caution.
    ///
    ///  - Important: This is a global setting and will affect all code that uses
    /// ``Tempo/InstantSource/system``. It is much preferred to use
    /// ``systemInstantSource`` to set the source for a specific task,  this
    /// includes for testing purposes.
    public static func setDefaultInstance(_ instance: Self) {
      systemInstantSourceDefault.withLock { $0 = instance }
    }

    private init() {}

    // Implementation based on platform-specific APIs
    // Darwin: SystemInstantSource+Darwin.swift
  }

}

extension Tempo.InstantSource where Self == Tempo.SystemInstantSource {

  public static var system: Tempo.InstantSource {
    return Tempo.SystemInstantSource.instance
  }

}
