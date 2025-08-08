//
//  URLSessionStreamTests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 8/1/25.
//

@testable import SolidIO
import XCTest


final class URLSessionStreamsTests: XCTestCase {

  func testSourceReadsCompletely() async throws {

    let source = URL(string: "https://github.com")!.source()

    for try await _ /* data */ in source.buffers() {
      // print("### Received \(buffer.count) bytes")
    }

    XCTAssertGreaterThan(source.bytesRead, 50 * 1024)
  }

  func testSourceCancels() async throws {

    let source = URL(string: "https://github.com")!.source()

    let reader = Task {
      for try await _ /* data */ in source.buffers(size: 3079) {
        // print("### Received \(buffer.count) bytes")
      }
    }

    do {
      reader.cancel()
      try await reader.value
      XCTFail("Expected cancellation error")
    }
    catch is CancellationError {
      // expected
    }
    catch {
      XCTFail("Unexpected error thrown: \(error.localizedDescription)")
    }

    XCTAssertEqual(source.bytesRead, 0)
  }

  func testSourceCancelsAfterStart() async throws {

    let source = URL(string: "https://github.com")!.source()

    let reader = Task {
      for try await _ in source.buffers(size: 133) {
        withUnsafeCurrentTask { $0!.cancel() }
      }
    }

    do {
      try await reader.value
      XCTFail("Expected cancellation error")
    }
    catch is CancellationError {
      // expected
    }
    catch {
      XCTFail("Unexpected error thrown: \(error.localizedDescription)")
    }

    XCTAssert(source.bytesRead > 0, "Data should have been read from source")
    XCTAssert(source.bytesRead < 50 * 1024, "Source should have cancelled iteration")
  }

  func testSourceThrowsInvalidStatus() async throws {

    do {

      _ = try await URLSessionSource(url: URL(string: "http://example.com/non-existent-url")!).read(max: .max)

    }
    catch let error as URLSessionSource.HTTPError {

      XCTAssertEqual(error, .invalidStatus)

    }
    catch {

      XCTFail("Unexpected error thrown")
    }

  }
}
