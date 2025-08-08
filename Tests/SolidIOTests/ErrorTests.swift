//
//  ErrorTests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 8/1/25.
//

@testable import SolidIO
import XCTest


final class ErrorTests: XCTestCase {

  func testIOErrorDescription() throws {

    XCTAssertEqual(IOError.endOfStream.errorDescription, "End of Stream")
    XCTAssertEqual(IOError.streamClosed.errorDescription, "Stream Closed")
    XCTAssertEqual(IOError.filterFailed(IOError.endOfStream).errorDescription, "Filter Failed: End of Stream")
  }

  @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
  func testHTTPErrorDescription() throws {

    XCTAssertEqual(URLSessionSource.HTTPError.invalidResponse.errorDescription, "Invalid Response")
    XCTAssertEqual(URLSessionSource.HTTPError.invalidStatus.errorDescription, "Invalid Status")
  }

}
