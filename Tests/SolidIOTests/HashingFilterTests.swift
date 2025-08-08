//
//  HashingFilterTests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 8/1/25.
//

import Crypto
@testable import SolidIO
import XCTest


final class HashingFilterTests: XCTestCase {

  func testRoundTrip() async throws {

    let data = Data(repeating: 0x5A, count: (512 * 1024) + 3333)
    let sink = DataSink()

    let (hashingSource, sourceResult) = data.source().hashing(algorithm: .sha256)
    do {

      let (hashingSink, sinkResult) = sink.hashing(algorithm: .sha256)
      do {

        try await hashingSource.pipe(to: hashingSink)

        try await hashingSink.close()
        try await hashingSource.close()

        XCTAssertEqual(sourceResult.digest, sinkResult.digest)
        XCTAssertEqual(sourceResult.digest, Data(SHA256.hash(data: data)))
      }
      catch {
        try await hashingSink.close()
        throw error
      }

    }
    catch {
      try await hashingSource.close()
      throw error
    }
  }

}
