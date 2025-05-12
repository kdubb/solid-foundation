//
//  SystemInstantSource+Darwin.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/26/25.
//

#if canImport(Darwin)

  import Darwin
  import Synchronization

  extension SystemInstantSource {

    public var instant: Instant {

      // Use the commpage realtime clock to get the current time in nanoseconds,
      // with (currently) microsecond precision.
      let realtimeClockNow = clock_gettime_nsec_np(CLOCK_REALTIME)

      let durationSinceEpoch = Duration(nanoseconds: Int128(realtimeClockNow))
      return Instant(durationSinceEpoch: durationSinceEpoch)
    }

  }

#endif
