//
//  Pointer.swift
//  Codex
//
//  Created by Kevin Wooten on 1/31/25.
//

import Testing
@testable import Codex

@Suite("RFC1123 Hostname Tests")
final class RFC1123Tests {

  // MARK: - Valid Hostname Tests

  @Test("Valid hostnames should parse successfully")
  func validHostname() {
    // Test standard hostnames
    #expect(RFC1123.Hostname.parse(string: "example.com") != nil)
    #expect(RFC1123.Hostname.parse(string: "sub.example.com") != nil)
    #expect(RFC1123.Hostname.parse(string: "a.b.c.d.e.f.g") != nil)
    #expect(RFC1123.Hostname.parse(string: "example.com.") != nil)    // With trailing dot
    #expect(RFC1123.Hostname.parse(string: "xn--example-9ua.com") != nil)    // Punycode
    #expect(RFC1123.Hostname.parse(string: "xn--bcher-kva.ch") != nil)    // Punycode
  }

  @Test("Hostnames with hyphens should parse successfully")
  func validHostnameWithHyphens() {
    #expect(RFC1123.Hostname.parse(string: "my-example.com") != nil)
    #expect(RFC1123.Hostname.parse(string: "my-example-1.com") != nil)
    #expect(RFC1123.Hostname.parse(string: "my-example-1-2.com") != nil)
  }

  @Test("Hostnames with numbers should parse successfully")
  func validHostnameWithNumbers() {
    #expect(RFC1123.Hostname.parse(string: "example1.com") != nil)
    #expect(RFC1123.Hostname.parse(string: "1example.com") != nil)
    #expect(RFC1123.Hostname.parse(string: "example1.example2.com") != nil)
  }

  // MARK: - Invalid Hostname Tests

  @Test("Hostnames exceeding maximum length should fail to parse")
  func invalidHostnameLength() {
    let longString = String(repeating: "a", count: RFC1123.Hostname.maxLength + 1)
    #expect(RFC1123.Hostname.parse(string: longString) == nil)
  }

  @Test("Hostnames with invalid labels should fail to parse")
  func invalidHostnameLabels() {
    #expect(RFC1123.Hostname.parse(string: "") == nil)    // Empty string
    #expect(RFC1123.Hostname.parse(string: ".") == nil)    // Just a dot
    #expect(RFC1123.Hostname.parse(string: "example..com") == nil)    // Double dot
    #expect(RFC1123.Hostname.parse(string: "-example.com") == nil)    // Leading hyphen
    #expect(RFC1123.Hostname.parse(string: "example-.com") == nil)    // Trailing hyphen
    #expect(RFC1123.Hostname.parse(string: "example.com-") == nil)    // Trailing hyphen
    #expect(RFC1123.Hostname.parse(string: "example@.com") == nil)    // Invalid character
    #expect(RFC1123.Hostname.parse(string: "example.com/") == nil)    // Invalid character
  }

  @Test("Hostnames with xn-- labels should parse if they follow LDH rules")
  func xnLabels() {
    // Valid xn-- labels that follow LDH rules
    #expect(RFC1123.Hostname.parse(string: "xn--example.com") != nil)    // Valid LDH label
    #expect(RFC1123.Hostname.parse(string: "xn--example-1.com") != nil)    // Valid LDH label with hyphen and number
    #expect(RFC1123.Hostname.parse(string: "xn--example1.com") != nil)    // Valid LDH label with number

    // Invalid xn-- labels that don't follow LDH rules
    #expect(RFC1123.Hostname.parse(string: "xn--.com") == nil)    // Empty label
    #expect(RFC1123.Hostname.parse(string: "xn--example-.com") == nil)    // Trailing hyphen
    #expect(RFC1123.Hostname.parse(string: "xn--example@.com") == nil)    // Invalid character
  }

  // MARK: - Hostname Properties Tests

  @Test("Hostname properties should be correctly set")
  func hostnameProperties() throws {
    let hostname = try #require(RFC1123.Hostname.parse(string: "sub.example.com"))

    #expect(hostname.labels == ["sub", "example", "com"])
    #expect(hostname.value == "sub.example.com")
  }

  @Test("Hostname with trailing dot should be handled correctly")
  func hostnameWithTrailingDot() throws {
    let hostname = try #require(RFC1123.Hostname.parse(string: "sub.example.com."))

    #expect(hostname.labels == ["sub", "example", "com"])
    #expect(hostname.value == "sub.example.com")
  }

  // MARK: - Edge Cases

  @Test("Single label hostnames should parse successfully")
  func singleLabelHostname() {
    #expect(RFC1123.Hostname.parse(string: "localhost") != nil)
    #expect(RFC1123.Hostname.parse(string: "localhost.") != nil)
  }

  @Test("Maximum label length should be enforced")
  func maximumLabelLength() {
    // Test label with maximum length (63 characters)
    let maxLabel = String(repeating: "a", count: 63)
    #expect(RFC1123.Hostname.parse(string: "\(maxLabel).com") != nil)

    // Test label exceeding maximum length (64 characters)
    let tooLongLabel = String(repeating: "a", count: 64)
    #expect(RFC1123.Hostname.parse(string: "\(tooLongLabel).com") == nil)
  }

  @Test("Hostnames should be case-insensitive")
  func mixedCaseHostname() {
    #expect(RFC1123.Hostname.parse(string: "EXAMPLE.COM") != nil)
    #expect(RFC1123.Hostname.parse(string: "Example.Com") != nil)
    #expect(RFC1123.Hostname.parse(string: "exAmPlE.cOm") != nil)
  }
}
