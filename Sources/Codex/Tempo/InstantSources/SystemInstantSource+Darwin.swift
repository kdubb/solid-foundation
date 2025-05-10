//
//  SystemInstantSource+Darwin.swift
//  Codex
//
//  Created by Kevin Wooten on 4/26/25.
//

#if canImport(Darwin)

  import Darwin
  import Synchronization

  extension Tempo.SystemInstantSource {

    public var instant: Tempo.Instant {

      // Use the commpage realtime clock to get the current time in nanoseconds,
      // with (currently) microsecond precision.
      let realtimeClockNow = clock_gettime_nsec_np(CLOCK_REALTIME)

      let durationSinceEpoch = Tempo.Duration(nanoseconds: Int128(realtimeClockNow))
      return Tempo.Instant(durationSinceEpoch: durationSinceEpoch)
    }

  }

#endif
