//
//  RFC2673Tests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 1/31/25.
//

@testable import SolidFormat
import Testing


@Suite("RFC2673 IPv4 Address Tests")
final class RFC2673IPv4AddressTests {

  // MARK: - Initialization Tests

  @Test("Initialize with octets")
  func testInitWithOctets() {
    let address = RFC2673.IPv4Address(a: 192, b: 168, c: 1, d: 1)
    #expect(address.a == 192)
    #expect(address.b == 168)
    #expect(address.c == 1)
    #expect(address.d == 1)
  }

  @Test("Initialize with octet tuple")
  func testInitWithOctetTuple() {
    let octets: (UInt8, UInt8, UInt8, UInt8) = (192, 168, 1, 1)
    let address = RFC2673.IPv4Address(octets: octets)
    #expect(address.a == octets.0)
    #expect(address.b == octets.1)
    #expect(address.c == octets.2)
    #expect(address.d == octets.3)
  }

  // MARK: - Parsing Tests

  @Test(arguments: [
    "0.0.0.0",
    "127.0.0.1",
    "192.168.1.1",
    "255.255.255.255",
    "10.0.0.1",
    "172.16.0.1",
    "1.1.1.1",
  ])
  func testParseValidIPv4Address(_ string: String) {
    #expect(RFC2673.IPv4Address.parse(string: string) != nil)
  }

  @Test(arguments: [
    ("", "Empty string"),
    ("256.0.0.1", "Octet > 255"),
    ("192.168.1", "Missing octet"),
    ("192.168.1.1.1", "Extra octet"),
    ("192.168.1.", "Trailing dot"),
    (".192.168.1.1", "Leading dot"),
    ("192.168.1.1a", "Non-numeric characters"),
    ("192.168.1.-1", "Negative number"),
    ("192.168.1.01", "Leading zero"),
    ("192.168.1. 1", "Space in octet"),
    ("192.168.1.1 ", "Trailing space"),
    (" 192.168.1.1", "Leading space"),
  ])
  func testParseInvalidIPv4Address(_ string: String, _ description: String) {
    #expect(RFC2673.IPv4Address.parse(string: string) == nil)
  }

  @Test("Parse edge cases")
  func testParseEdgeCases() {
    // Test minimum and maximum values for each octet
    let minAddress = RFC2673.IPv4Address.parse(string: "0.0.0.0")
    #expect(minAddress != nil)
    #expect(minAddress?.a == 0)
    #expect(minAddress?.b == 0)
    #expect(minAddress?.c == 0)
    #expect(minAddress?.d == 0)

    let maxAddress = RFC2673.IPv4Address.parse(string: "255.255.255.255")
    #expect(maxAddress != nil)
    #expect(maxAddress?.a == 255)
    #expect(maxAddress?.b == 255)
    #expect(maxAddress?.c == 255)
    #expect(maxAddress?.d == 255)
  }

  // MARK: - Property Tests

  @Test("Octets property")
  func testOctetsProperty() {
    let address = RFC2673.IPv4Address(a: 192, b: 168, c: 1, d: 1)
    #expect(address.a == 192)
    #expect(address.b == 168)
    #expect(address.c == 1)
    #expect(address.d == 1)

    // Test setting octets
    var mutableAddress = address
    mutableAddress.octets = (10, 0, 0, 1)
    #expect(mutableAddress.a == 10)
    #expect(mutableAddress.b == 0)
    #expect(mutableAddress.c == 0)
    #expect(mutableAddress.d == 1)
  }
}
