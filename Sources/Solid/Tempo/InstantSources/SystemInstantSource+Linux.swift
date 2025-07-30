//
//  SystemInstantSource+Linux.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 7/29/25.
//

#if os(Linux)
  #if canImport(Glibc)
    import Glibc
  #elseif canImport(Musl)
    import Musl
  #endif

  import Synchronization

  extension SystemInstantSource {

    public var instant: Instant {
      var ts = timespec()
      let result = clock_gettime(CLOCK_REALTIME, &ts)
      precondition(result == 0, "clock_gettime failed")

      let nanoseconds = Int128(ts.tv_sec) * 1_000_000_000 + Int128(ts.tv_nsec)
      let durationSinceEpoch = Duration(nanoseconds: nanoseconds)
      return Instant(durationSinceEpoch: durationSinceEpoch)
    }
  }

#endif
