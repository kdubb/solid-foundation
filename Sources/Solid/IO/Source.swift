//
//  Stream.swift
//  SolidIO
//
//  Created by Kevin Wooten on 7/4/25.
//

import Foundation


/// ``Stream`` that produces data.
public protocol Source: Stream {

  /// Number of bytes read from stream.
  ///
  /// - Throws: ``IOError`` if the # of bytes read could not be determined.
  var bytesRead: Int { get async throws }

  /// Read at most `max` count of available bytes from stream.
  ///
  /// - Parameter max: The maximum bytes requested
  /// - Returns: The data read, or nil if the stream will no longer produce data.
  /// - Throws: ``IOError``if an I/O related error occurrs or `CancellationError` if the source is closed.
  ///
  func read(max: Int) async throws -> Data?

  /// Read `next` count of available bytes from stream unless and
  /// end-of-stream is encountered.
  ///
  /// - Parameter next: The of bytes to request
  /// - Returns: The data read, or nil if the stream will no longer produce data.
  /// - Throws: ``IOError``if an I/O related error occurrs or `CancellationError` if the source is closed.
  ///
  func read(next: Int) async throws -> Data?

  /// Read `exactly` count bytes from stream unless and
  /// end-of-stream is encountered.
  ///
  /// - Parameter count: The # of bytes to request.
  /// - Returns: The data read, or nil if the stream will no longer produce data.
  /// - Throws: ``IOError`` if an I/O related error occurrs or `CancellationError` if the source is closed.
  ///
  func read(exactly count: Int) async throws -> Data

}

public extension Source {

  /// Reads the `next` count bytes from stream unless an
  /// end-of-stream is encountered.
  ///
  /// - Parameter requestSize: The total number of bytes to read, unless
  ///   an end-of-stream is encountered.
  /// - Returns: Data buffer with `requestSize` bytes, until an
  ///   end-of-stream is encountered, in which case a smaller buffer
  ///   will be returned. Subsequent calls will return `nil` per the
  ///   normal ``read(max:)`` function.
  /// - Throws: ``IOError``if an I/O related error occurrs or `CancellationError` if the source is closed.
  ///
  func read(next requestSize: Int) async throws -> Data? {

    // Attempt to read required amount of data
    guard var data = try await read(max: requestSize) else {
      return nil
    }

    if data.count == requestSize {
      // We've go it... done!
      return data
    }

    // Loop until we have all required bytes

    while data.count < requestSize {

      let needed = requestSize - data.count

      guard let more = try await read(max: needed) else {
        // Encountered end-of-stream, return data we have
        return data
      }

      // Wait to reserve until after we know that
      // we have not encountered end-of-stream
      data.reserveCapacity(requestSize)

      data.append(more)
    }

    return data
  }

  /// Reads the `next` count bytes from stream.
  ///
  /// - Parameter requiredSize: The total number of bytes to read.
  /// - Returns: Data buffer with `requiredSize` bytes.
  /// - Throws: ``IOError/endOfStream`` when end-of-stream has been
  ///   encountered.
  func read(exactly requiredSize: Int) async throws -> Data {

    // Attempt to read required amount of data
    guard let data = try await read(next: requiredSize) else {
      throw IOError.endOfStream
    }

    return data
  }

  /// Allows ``Source`` to be treated as an `AsynSequence` of `Data` buffers.
  ///
  /// As an `AsyncSequence` it allows the source to be iterated easily using
  /// Swift's `for await-in` loop:
  /// ```swift
  ///   for try await buffer in source.buffers() {
  ///     // do work on buffer
  ///   }
  /// ```
  ///
  /// - Parameter size: Size of buffers to produce on each iteration,
  ///   unless an end-of-stream is encountered.
  /// - Returns: An `AsyncSequence` of `Data` buffers
  func buffers(size: Int = BufferedSource.segmentSize) -> AsyncBuffers {
    AsyncBuffers(source: self, requiredReadSize: size)
  }

  /// Write all remaining data from this stream to `sink`.
  ///
  /// - Parameters:
  ///   - sink: Destination ``Sink`` to write data.
  ///   - bufferSize: Size of buffers to use during iteration.
  /// - Throws: ``IOError`` if a read or write fails.
  func pipe(to sink: Sink, bufferSize: Int = BufferedSource.segmentSize) async throws {

    for try await data in buffers(size: bufferSize) {

      try Task.checkCancellation()

      try await sink.write(data: data)
    }
  }

}
