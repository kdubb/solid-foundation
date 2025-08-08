//
//  CompressionFilterTests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 8/1/25.
//

@testable import SolidIO
import XCTest

final class CompressionFilterTests: XCTestCase {

  func testRoundTrip() async throws {
#if !os(macOS)
    throw XCTSkip("Only test on macOS")
#endif

    let data = Data(repeating: 0x5A, count: (512 * 1024) + 3333)
    let sink = DataSink()

    let decompressingSink = try sink.decompressing(algorithm: .lzfse)
    do {

      let compressingSource = try data.source().compressing(algorithm: .lzfse)
      do {

        try await compressingSource.pipe(to: decompressingSink)

        try await compressingSource.close()
      }
      catch {
        try await compressingSource.close()
        throw error
      }

      try await decompressingSink.close()
    }
    catch {
      try await decompressingSink.close()
      throw error
    }

    XCTAssertEqual(data, sink.data)
  }

}
