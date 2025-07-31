//
//  BoxCipherFilter.swift
//  SolidIO
//
//  Created by Kevin Wooten on 7/5/25.
//

import CryptoKit
import Foundation


/// Cryptographic box sealing or opening cipher ``Sink``.
///
/// Treats incoming data buffers as an ordered series of
/// cryptographic boxes that will be sealed or opened,
/// depending on the operating mode.
///
public class BoxCipherFilter: Filter {

  /// Box cipher alogorithm type.
  ///
  public enum Algorithm {
    /// AES-GCM
    ///
    /// Uses AES-GCM (with 12 byte nonces) for box operations.
    ///
    case aesGcm
    /// ChaCha20-Poly1305.
    ///
    /// Uses ChaCha20-Poly1305 (as described in RFC 7539 with 96-bit nonces)
    /// for box operations.
    ///
    case chaCha20Poly
  }

  /// Box cipher operation type.
  ///
  public enum Operation {
    /// Seal each data buffer inside a crytographic box.
    case seal
    /// Open each data buffer from a crytographic box.
    case open
  }

  /// Additional authentication data added to each box.
  private struct AAD {
    let index: UInt64
    let isFinal: Bool

    func serialized() -> Data {
      var data = Data()
      withUnsafeBytes(of: index.bigEndian) { ptr in
        data.append(ptr.baseAddress.unsafelyUnwrapped.assumingMemoryBound(to: UInt8.self), count: ptr.count)
      }
      data.append(isFinal ? 1 : 0)
      return data
    }
  }

  /// Size of the random nonce prepended to each box data.
  public static let nonceSize = 12
  /// Size of the tag produced by the seal operation and appended to the box data.
  public static let tagSize = 16

  /// Reports the size of a sealed box for a given box data size.
  ///
  /// - Parameter dataSize: Size of data in box.
  /// - Returns: The size of the sealed box, which includes the original data, nonce, and authentication tag.
  public static func sealedBoxSize(dataSize: Int) -> Int { dataSize + nonceSize + tagSize }

  /// Key used to seal or open boxes.
  public let key: SymmetricKey

  private let operation: (Data, AAD, SymmetricKey) throws -> Data
  private let algorthm: Algorithm
  private var boxIndex: UInt64 = 0
  private var boxDataSize: Int
  private var input = Data()

  /// Initializes the cipher with the given ``Operation``, ``Algorithm``, and
  /// cryptographic key.
  ///
  /// - Parameters:
  ///   - operation: Operation to perform on the passed in data.
  ///   - algorithm: Box cipher algorithm to use.
  ///   - key: Cryptographic key to use for sealing/opening.
  ///   - boxDataSize: Size of each cryptographic box; final box may be smaller.
  ///
  public init(
    operation: Operation,
    algorithm: Algorithm,
    key: SymmetricKey,
    boxDataSize: Int = BufferedSource.segmentSize
  ) {
    algorthm = algorithm
    switch (algorithm, operation) {
    case (.aesGcm, .seal):
      self.operation = Self.AESGCMOps.seal(data:aad:key:)
      self.boxDataSize = boxDataSize
    case (.aesGcm, .open):
      self.operation = Self.AESGCMOps.open(data:aad:key:)
      self.boxDataSize = Self.sealedBoxSize(dataSize: boxDataSize)
    case (.chaCha20Poly, .seal):
      self.operation = Self.ChaChaPolyOps.seal(data:aad:key:)
      self.boxDataSize = boxDataSize
    case (.chaCha20Poly, .open):
      self.operation = Self.ChaChaPolyOps.open(data:aad:key:)
      self.boxDataSize = Self.sealedBoxSize(dataSize: boxDataSize)
    }
    self.key = key
  }

  /// Treats `data` as a cryptographic box of data and seals
  /// or opens the box according to the ``Operation`` initialized
  /// with.
  ///
  public func process(data: Data) throws -> Data {

    input.append(data)
    var output = Data()

    while input.count >= (boxDataSize * 2) {

      output.append(try processNextInputBox())
    }

    return output
  }

  /// Finishes processig the sequence of boxes and
  /// returns the last one (if available).
  ///
  public func finish() throws -> Data? {

    guard !input.isEmpty else {
      return nil
    }

    var output = Data()

    if input.count >= boxDataSize {
      output.append(try processNextInputBox())
    }

    // process any leftover data as a final (potentially smaller) box
    if !input.isEmpty {
      output.append(try operation(input, AAD(index: boxIndex, isFinal: true), key))
      input.removeAll()
    }

    return output
  }

  private func processNextInputBox() throws -> Data {
    precondition(input.count >= boxDataSize)

    let range = 0..<boxDataSize

    let processed = try operation(input.subdata(in: range), AAD(index: boxIndex, isFinal: false), key)

    boxIndex += 1

    input.removeSubrange(range)

    return processed
  }

  private enum AESGCMOps {

    fileprivate static func seal(data: Data, aad: AAD, key: SymmetricKey) throws -> Data {

      guard let sealedData = try AES.GCM.seal(data, using: key, authenticating: aad.serialized()).combined else {
        fatalError()
      }

      return sealedData
    }

    fileprivate static func open(data: Data, aad: AAD, key: SymmetricKey) throws -> Data {

      return try AES.GCM.open(AES.GCM.SealedBox(combined: data), using: key, authenticating: aad.serialized())
    }

  }

  private enum ChaChaPolyOps {

    fileprivate static func seal(data: Data, aad: AAD, key: SymmetricKey) throws -> Data {

      return try ChaChaPoly.seal(data, using: key, authenticating: aad.serialized()).combined
    }

    fileprivate static func open(data: Data, aad: AAD, key: SymmetricKey) throws -> Data {

      return try ChaChaPoly.open(ChaChaPoly.SealedBox(combined: data), using: key, authenticating: aad.serialized())
    }

  }

}

public extension Source {

  /// Applies a box ciphering filter to this stream.
  ///
  /// - Parameters:
  ///   - algorithm: Alogorithm for box ciphering.
  ///   - operation: Operation (seal or open) to apply.
  ///   - key: Key to use for cipher.
  ///   - boxDataSize: Size of data in each box; final box may be smaller.
  /// - Returns: Box ciphered source stream reading from this stream.
  /// - SeeAlso: ``BoxCipherFilter``
  ///
  func applying(
    boxCipher algorithm: BoxCipherFilter.Algorithm,
    operation: BoxCipherFilter.Operation,
    key: SymmetricKey,
    boxDataSize: Int = BufferedSource.segmentSize
  ) -> Source {
    filtering(using: BoxCipherFilter(operation: operation, algorithm: algorithm, key: key, boxDataSize: boxDataSize))
  }

  /// Applies a sealing filter for a box cipher to this stream.
  ///
  /// - Parameters:
  ///   - algorithm: Alogorithm for box ciphering.
  ///   - key: Key to use for cipher.
  ///   - boxDataSize: Size of data in each box; final box may be smaller.
  /// - Returns: Box ciphered source stream reading from this stream.
  /// - SeeAlso: ``BoxCipherFilter``
  ///
  func sealing(
    algorithm: BoxCipherFilter.Algorithm,
    key: SymmetricKey,
    boxDataSize: Int = BufferedSource.segmentSize
  ) -> Source {
    applying(boxCipher: algorithm, operation: .seal, key: key, boxDataSize: boxDataSize)
  }

  /// Applies an opening filter for a box cipher to this stream.
  ///
  /// - Parameters:
  ///   - algorithm: Alogorithm for box ciphering.
  ///   - key: Key to use for cipher.
  ///   - boxDataSize: Size of data in each box; final box may be smaller.
  /// - Returns: Box ciphered source stream reading from this stream.
  /// - SeeAlso: ``BoxCipherFilter``
  ///
  func opening(
    algorithm: BoxCipherFilter.Algorithm,
    key: SymmetricKey,
    boxDataSize: Int = BufferedSource.segmentSize
  ) -> Source {
    applying(boxCipher: algorithm, operation: .open, key: key, boxDataSize: boxDataSize)
  }

}

public extension Sink {

  /// Applies a box ciphering filter to this stream.
  ///
  /// - Parameters:
  ///   - algorithm: Alogorithm for box ciphering.
  ///   - operation: Operation (seal or open) to apply.
  ///   - key: Key to use for cipher.
  ///   - boxDataSize: Size of data in each box; final box may be smaller.
  /// - Returns: Box ciphered sink stream writing to this stream.
  /// - SeeAlso: ``BoxCipherFilter``
  ///
  func applying(
    boxCipher algorithm: BoxCipherFilter.Algorithm,
    operation: BoxCipherFilter.Operation,
    key: SymmetricKey,
    boxDataSize: Int = BufferedSource.segmentSize
  ) -> Sink {
    filtering(using: BoxCipherFilter(operation: operation, algorithm: algorithm, key: key, boxDataSize: boxDataSize))
  }

  /// Applies a sealing filter for a box cipher to this stream.
  ///
  /// - Parameters:
  ///   - algorithm: Alogorithm for box ciphering.
  ///   - key: Key to use for cipher.
  ///   - boxDataSize: Size of data in each box; final box may be smaller.
  /// - Returns: Box ciphered sink stream writing to this stream.
  /// - SeeAlso: ``BoxCipherFilter``
  ///
  func sealing(
    algorithm: BoxCipherFilter.Algorithm,
    key: SymmetricKey,
    boxDataSize: Int = BufferedSource.segmentSize
  ) -> Sink {
    applying(boxCipher: algorithm, operation: .seal, key: key, boxDataSize: boxDataSize)
  }

  /// Applies an opening filter for a box cipher to this stream.
  ///
  /// - Parameters:
  ///   - algorithm: Alogorithm for box ciphering.
  ///   - key: Key to use for cipher.
  ///   - boxDataSize: Size of data in each box; final box may be smaller.
  /// - Returns: Box ciphered sink stream writing to this stream.
  /// - SeeAlso: ``BoxCipherFilter``
  ///
  func opening(
    algorithm: BoxCipherFilter.Algorithm,
    key: SymmetricKey,
    boxDataSize: Int = BufferedSource.segmentSize
  ) -> Sink {
    applying(boxCipher: algorithm, operation: .open, key: key, boxDataSize: boxDataSize)
  }

}
