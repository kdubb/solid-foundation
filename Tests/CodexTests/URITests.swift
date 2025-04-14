//
//  URITests.swift
//  Codex
//
//  Created by Kevin Wooten on 2/14/25.
//

import Foundation
import Testing
@testable import Codex

@Suite("URI Tests")
public struct URITests {

  @Test("Check satisfied `kind` requirements")
  func satisfiedKindRequirements() async throws {
    #expect(URI(encoded: "https://example.com", requirements: .iri) != nil)
    #expect(URI(encoded: "test#foo", requirements: .iriRelativeReference) != nil)
    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo", requirements: .uri) != nil)
    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed/123#foo", requirements: .uri) != nil)
  }

  @Test("Check unsatisfied `kind` requirements fail initializer")
  func unsatisfiedKindRequirements() async throws {
    #expect(URI(encoded: "https://example.com", requirements: .iriRelativeReference) == nil)
    #expect(URI(encoded: "test#foo", requirements: .uri) == nil)
  }

  @Test("Check satisfied `fragment` requirements")
  func satisfiedFragmentRequirements() async throws {
    #expect(URI(encoded: "https://example.com#foo", requirements: .fragment(.required)) != nil)
    #expect(URI(encoded: "https://example.com#", requirements: .fragment(.required)) != nil)
    #expect(URI(encoded: "https://example.com", requirements: .fragment(.disallowed)) != nil)
    #expect(URI(encoded: "https://example.com#", requirements: .fragment(.disallowedOrEmpty)) != nil)
    #expect(URI(encoded: "https://example.com", requirements: .fragment(.optional)) != nil)
    #expect(URI(encoded: "https://example.com#", requirements: .fragment(.optional)) != nil)
    #expect(URI(encoded: "https://example.com#foo", requirements: .fragment(.optional)) != nil)

    #expect(URI(encoded: "example#foo", requirements: .fragment(.required)) != nil)
    #expect(URI(encoded: "example#", requirements: .fragment(.required)) != nil)
    #expect(URI(encoded: "example", requirements: .fragment(.disallowed)) != nil)
    #expect(URI(encoded: "example#", requirements: .fragment(.disallowedOrEmpty)) != nil)
    #expect(URI(encoded: "example", requirements: .fragment(.optional)) != nil)
    #expect(URI(encoded: "example#", requirements: .fragment(.optional)) != nil)
    #expect(URI(encoded: "example#foo", requirements: .fragment(.optional)) != nil)

    #expect(
      URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo", requirements: .fragment(.required)) != nil
    )
    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#", requirements: .fragment(.required)) != nil)
    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed", requirements: .fragment(.disallowed)) != nil)
    #expect(
      URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#", requirements: .fragment(.disallowedOrEmpty)) != nil
    )
    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed", requirements: .fragment(.optional)) != nil)
    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#", requirements: .fragment(.optional)) != nil)
    #expect(
      URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo", requirements: .fragment(.optional)) != nil
    )
  }

  @Test("Check unsatisfied `fragment` requirements fail initializer")
  func unsatisfiedFragmentRequirements() async throws {
    #expect(URI(encoded: "https://example.com#foo", requirements: .fragment(.disallowed)) == nil)
    #expect(URI(encoded: "https://example.com#", requirements: .fragment(.disallowed)) == nil)
    #expect(URI(encoded: "https://example.com", requirements: .fragment(.required)) == nil)
    #expect(URI(encoded: "https://example.com#foo", requirements: .fragment(.disallowedOrEmpty)) == nil)

    #expect(URI(encoded: "example#foo", requirements: .fragment(.disallowed)) == nil)
    #expect(URI(encoded: "example#", requirements: .fragment(.disallowed)) == nil)
    #expect(URI(encoded: "example", requirements: .fragment(.required)) == nil)
    #expect(URI(encoded: "example#foo", requirements: .fragment(.disallowedOrEmpty)) == nil)

    #expect(URI(encoded: "urn:ulid:0#foo", requirements: .fragment(.disallowed)) == nil)
    #expect(URI(encoded: "urn:uuid:0#", requirements: .fragment(.disallowed)) == nil)
    #expect(URI(encoded: "urn:uuid:0", requirements: .fragment(.required)) == nil)
    #expect(URI(encoded: "urn:uuid:0#foo", requirements: .fragment(.disallowedOrEmpty)) == nil)
  }

  @Test(
    "Check satisfied `normalized` requirements",
    arguments: [
      ("https://example.com", [] as [URI.PathItem]),
      ("https://example.com/", [.empty] as [URI.PathItem]),
      ("https://example.com/foo", [.empty, .decoded("foo")] as [URI.PathItem]),
      ("https://example.com/foo/", [.empty, .decoded("foo"), .empty] as [URI.PathItem]),
      ("https://example.com/foo/bar", [.empty, .decoded("foo"), .decoded("bar")] as [URI.PathItem]),
      ("https://example.com/foo/bar/", [.empty, .decoded("foo"), .decoded("bar"), .empty] as [URI.PathItem]),
    ]
  )
  func satisfiedNormalizedRequirements(string: String, pathItems: [URI.PathItem]) async throws {
    let uri = try #require(URI(encoded: string, requirements: .normalized))
    #expect(uri.absolute?.scheme == "https")
    #expect(uri.absolute?.authority?.host == "example.com")
    #expect(uri.absolute?.authority?.port == nil)
    #expect(uri.absolute?.authority?.userInfo == nil)
    #expect(uri.absolute?.path == pathItems)
    #expect(uri.absolute?.query == nil)
    #expect(uri.absolute?.fragment == nil)
    #expect(uri.encoded == string)
  }

  @Test(
    "Check unsatisfied `normalized` requirements fail initializer",
    arguments: [
      "https://example.com/./foo",
      "https://example.com/foo/../bar",
      "https://example.com/foo//bar",
      "https://example.com/./",
      "example/./foo",
      "example/foo/../bar",
      "example/foo//bar",
    ]
  )
  func unsatisfiedNormalizedRequirements(string: String) async throws {
    #expect(URI(encoded: string, requirements: .normalized) == nil)
  }

  @Test(
    "Check parsing normalizes input",
    arguments: [
      (
        "https://example.com/./foo", "https://example.com/foo",
        [.empty, .decoded("foo")] as [URI.PathItem]
      ),
      (
        "https://example.com/foo/../bar", "https://example.com/bar",
        [.empty, .decoded("bar")] as [URI.PathItem]
      ),
      (
        "https://example.com/foo//bar", "https://example.com/foo/bar",
        [.empty, .decoded("foo"), .decoded("bar")] as [URI.PathItem]
      ),
      (
        "https://example.com/", "https://example.com/",
        [.empty] as [URI.PathItem]
      ),
      (
        "https://example.com/./", "https://example.com/",
        [.empty] as [URI.PathItem]
      ),
      (
        "https://example.com/foo/", "https://example.com/foo/",
        [.empty, .decoded("foo"), .empty] as [URI.PathItem]
      ),
      (
        "example/./foo", "example/foo",
        [.decoded("example"), .decoded("foo")] as [URI.PathItem]
      ),
      (
        "example/foo/../bar", "example/bar",
        [.decoded("example"), .decoded("bar")] as [URI.PathItem]
      ),
      (
        "example/foo//bar", "example/foo/bar",
        [.decoded("example"), .decoded("foo"), .decoded("bar")] as [URI.PathItem]
      ),
    ]
  )
  func unsatisfiedNormalizedRequirements(string: String, normalized: String, pathItems: [URI.PathItem]) async throws {
    let uri = try #require(URI(encoded: string))
    if let absolute = uri.absolute {
      #expect(absolute.scheme == "https")
      #expect(absolute.authority?.host == "example.com")
      #expect(absolute.authority?.port == nil)
      #expect(absolute.authority?.userInfo == nil)
      #expect(absolute.path == pathItems)
      #expect(absolute.query == nil)
      #expect(absolute.fragment == nil)
    } else if let relative = uri.relativeReference {
      #expect(relative.authority == nil)
      #expect(relative.path == pathItems)
      #expect(relative.query == nil)
      #expect(relative.fragment == nil)
      #expect(uri.encoded == normalized)
    }
  }

  @Test func resolveURNFragmentAgainstBase() throws {

    let base = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed"))
    let rel = try #require(URI(encoded: "#foo"))
    let abs = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo"))

    #expect(rel.resolved(against: base) == abs)
  }

  @Test func resolveURIFragmentAgainstFileBase() throws {

    let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base.json"))
    let rel = try #require(URI(encoded: "#foo"))
    let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base.json#foo"))

    #expect(rel.resolved(against: base) == abs)
  }

  @Test func resolveRelativeURIAgainstFileBase() throws {

    let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base.json"))
    let rel = try #require(URI(encoded: "d.json#foo"))
    let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/d.json#foo"))

    #expect(rel.resolved(against: base) == abs)
  }

  @Test func resolveCurrentRelativeURIAgainstFileBase() throws {

    let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base"))
    let rel = try #require(URI(encoded: "./d.json#foo"))
    let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/d.json#foo"))

    #expect(rel.resolved(against: base) == abs)
  }

  @Test func resolveRelativeURIAgainstDirectoryBase() throws {

    let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/"))
    let rel = try #require(URI(encoded: "../d.json#foo"))
    let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/d.json#foo"))

    #expect(rel.resolved(against: base) == abs)
  }

  @Test func resolveCurrentRelativeURIAgainstDirectoryBase() throws {

    let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/"))
    let rel = try #require(URI(encoded: "./d.json#foo"))
    let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/d.json#foo"))

    #expect(rel.resolved(against: base) == abs)
  }

  @Test func resolveRelativeURIAgainstBase() throws {

    let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base"))
    let rel = try #require(URI(encoded: "./d.json#foo"))
    let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/d.json#foo"))

    #expect(rel.resolved(against: base) == abs)
  }

  @Test func relativeToURL() throws {

    let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base"))
    let abs = try #require(URI(encoded: "https://example.com/draft2020-12//ref-and-id2/base/d.json#foo"))

    #expect(abs.relative(to: base) == .relative(encodedPath: "./d.json", fragment: "foo"))
  }

  @Test func relativeToURN() throws {

    let abs = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed"))
    let rel = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#/foo"))

    #expect(rel.relative(to: abs).description == ".#/foo")
  }

  @Test func appendFragment() throws {

    let base = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed"))
    let res = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#/foo"))

    #expect(base.appending(fragmentPointer: "/foo") == res)
  }

  @Test("File URI parsing")
  func fileURIs() async throws {
    // Test file URI with empty authority (file:///)
    let file1 = try #require(URI(encoded: "file:///path/to/file", requirements: .iri))
    #expect(
      file1
        == .absolute(
          .init(
            scheme: "file",
            authority: .init(host: "", port: nil, userInfo: nil),
            path: [.empty, .decoded("path"), .decoded("to"), .decoded("file")],
            query: nil,
            fragment: nil
          )
        )
    )

    // Test file URI with local path (file:/)
    let file2 = try #require(URI(encoded: "file:/path/to/file", requirements: .iri))
    #expect(
      file2
        == .absolute(
          .init(
            scheme: "file",
            authority: nil,
            path: [.empty, .decoded("path"), .decoded("to"), .decoded("file")],
            query: nil,
            fragment: nil
          )
        )
    )

    // Test file URI with host authority
    let file3 = try #require(URI(encoded: "file://host/path/to/file", requirements: .iri))
    #expect(
      file3
        == .absolute(
          .init(
            scheme: "file",
            authority: .init(host: "host", port: nil, userInfo: nil),
            path: [.empty, .decoded("path"), .decoded("to"), .decoded("file")],
            query: nil,
            fragment: nil
          )
        )
    )

    // Test file URI with empty authority and empty path
    let file4 = try #require(URI(encoded: "file:///", requirements: .iri))
    #expect(
      file4
        == .absolute(
          .init(
            scheme: "file",
            authority: .init(host: "", port: nil, userInfo: nil),
            path: [.empty],
            query: nil,
            fragment: nil
          )
        )
    )

    // Test file URI with local path and empty path
    let file5 = try #require(URI(encoded: "file:/", requirements: .iri))
    #expect(
      file5
        == .absolute(
          .init(
            scheme: "file",
            authority: nil,
            path: [.empty],
            query: nil,
            fragment: nil
          )
        )
    )

    // Test file URI with query and fragment
    let file6 = try #require(URI(encoded: "file:///path/to/file?query=value#fragment", requirements: .iri))
    #expect(
      file6
        == .absolute(
          .init(
            scheme: "file",
            authority: .init(host: "", port: nil, userInfo: nil),
            path: [.empty, .decoded("path"), .decoded("to"), .decoded("file")],
            query: [.init(name: "query", value: "value")],
            fragment: "fragment"
          )
        )
    )

    // Test file URI with user info and port
    let file7 = try #require(URI(encoded: "file://user:pass@host:123/path", requirements: .iri))
    #expect(
      file7
        == .absolute(
          .init(
            scheme: "file",
            authority: .init(
              host: "host",
              port: 123,
              userInfo: .init(user: "user", password: "pass")
            ),
            path: [.empty, .decoded("path")],
            query: nil,
            fragment: nil
          )
        )
    )
  }

  @Test("Percent encoding validation")
  func percentEncodingValidation() async throws {
    // Test that URIs with unencoded characters are rejected when percent encoding is required
    #expect(URI(encoded: "https://example.com/foo bar", requirements: .percentEncoded) == nil)
    #expect(URI(encoded: "https://example.com/foo?bar=baz qux", requirements: .percentEncoded) == nil)
    #expect(URI(encoded: "https://example.com/foo#bar baz", requirements: .percentEncoded) == nil)
    #expect(URI(encoded: "https://user:pass word@example.com", requirements: .percentEncoded) == nil)

    // Test that URIs with properly encoded characters are accepted
    let encodedURI = try #require(URI(encoded: "https://example.com/foo%20bar", requirements: .percentEncoded))
    #expect(encodedURI.encoded == "https://example.com/foo%20bar")

    let encodedQuery = try #require(
      URI(encoded: "https://example.com/foo?bar=baz%20qux", requirements: .percentEncoded)
    )
    #expect(encodedQuery.encoded == "https://example.com/foo?bar=baz%20qux")

    let encodedFragment = try #require(URI(encoded: "https://example.com/foo#bar%20baz", requirements: .percentEncoded))
    #expect(encodedFragment.encoded == "https://example.com/foo#bar%20baz")

    let encodedUserInfo = try #require(
      URI(encoded: "https://user:pass%20word@example.com", requirements: .percentEncoded)
    )
    #expect(encodedUserInfo.encoded == "https://user:pass%20word@example.com")

    let encodedPath =
      try #require(URI(encoded: "https://example.com/foo/bar/%2E%2E/baz", requirements: .percentEncoded))
    #expect(encodedPath.encoded == "https://example.com/foo/bar/%2E%2E/baz")

    // Test that components are properly decoded during initialization
    #expect(encodedURI.absolute?.path.last?.decoded == "foo bar")
    #expect(encodedQuery.absolute?.query?.first?.value == "baz qux")
    #expect(encodedFragment.absolute?.fragment == "bar baz")
    #expect(encodedUserInfo.absolute?.authority?.userInfo?.password == "pass word")
    #expect(encodedPath.absolute?.path[3].decoded == "..")
  }

  @Test("Percent encoding roundtrip")
  func percentEncodingRoundtrip() async throws {
    // Test that encoding and decoding roundtrips work correctly
    let uri1 = try #require(URI(encoded: "https://example.com/foo%20bar"))
    #expect(uri1.encoded == "https://example.com/foo%20bar")
    #expect(uri1.absolute?.path.last?.decoded == "foo bar")

    let uri2 = try #require(URI(encoded: "https://example.com/foo?bar=baz%20qux"))
    #expect(uri2.encoded == "https://example.com/foo?bar=baz%20qux")
    #expect(uri2.absolute?.query?.first?.value == "baz qux")

    let uri3 = try #require(URI(encoded: "https://example.com/foo#bar%20baz"))
    #expect(uri3.encoded == "https://example.com/foo#bar%20baz")
    #expect(uri3.absolute?.fragment == "bar baz")

    let uri4 = try #require(URI(encoded: "https://user:pass%20word@example.com"))
    #expect(uri4.encoded == "https://user:pass%20word@example.com")
    #expect(uri4.absolute?.authority?.userInfo?.password == "pass word")

    let uri5 = try #require(URI(encoded: "https://example.com/foo/bar/%2E%2E/baz"))
    #expect(uri5.encoded == "https://example.com/foo/bar/%2E%2E/baz")
    #expect(uri5.absolute?.path[3].decoded == "..")
  }

  @Test("Invalid percent encoding")
  func invalidPercentEncoding() async throws {
    // Test that URIs with invalid percent encoding are rejected
    #expect(URI(encoded: "https://example.com/foo%2") == nil)    // Incomplete percent encoding
    #expect(URI(encoded: "https://example.com/foo%2G") == nil)    // Invalid hex digit
    #expect(URI(encoded: "https://example.com/foo%") == nil)    // Trailing percent
    #expect(URI(encoded: "https://example.com/foo%2%") == nil)    // Multiple trailing percent
  }

  @Test("Percent encoding validation for relative URIs")
  func percentEncodingValidationRelative() async throws {
    // Test that relative URIs with unencoded characters are rejected when percent encoding is required
    #expect(URI(encoded: "foo bar", requirements: .percentEncoded) == nil)
    #expect(URI(encoded: "foo?bar=baz qux", requirements: .percentEncoded) == nil)
    #expect(URI(encoded: "foo#bar baz", requirements: .percentEncoded) == nil)
    #expect(URI(encoded: "foo/bar/^/baz", requirements: .percentEncoded) == nil)

    // Test that relative URIs with properly encoded characters are accepted
    let encodedURI = try #require(URI(encoded: "foo%20bar", requirements: .percentEncoded))
    #expect(encodedURI.encoded == "foo%20bar")

    let encodedQuery = try #require(URI(encoded: "foo?bar=baz%20qux", requirements: .percentEncoded))
    #expect(encodedQuery.encoded == "foo?bar=baz%20qux")

    let encodedFragment = try #require(URI(encoded: "foo#bar%20baz", requirements: .percentEncoded))
    #expect(encodedFragment.encoded == "foo#bar%20baz")

    let encodedPath = try #require(URI(encoded: "foo/bar/%2E%2E/baz", requirements: .percentEncoded))
    #expect(encodedPath.encoded == "foo/bar/%2E%2E/baz")

    // Test that components are properly decoded during initialization
    #expect(encodedURI.relativeReference?.path.last?.decoded == "foo bar")
    #expect(encodedQuery.relativeReference?.query?.first?.value == "baz qux")
    #expect(encodedFragment.relativeReference?.fragment == "bar baz")
    #expect(encodedPath.relativeReference?.path[2].decoded == "..")
  }

  @Test("Percent encoding validation for URNs")
  func percentEncodingValidationURN() async throws {
    // Test that URNs with unencoded characters are rejected when percent encoding is required
    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo bar", requirements: .percentEncoded) == nil)
    #expect(
      URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed?foo=bar baz", requirements: .percentEncoded) == nil
    )

    // Test that URNs with properly encoded characters are accepted
    let encodedFragment = try #require(
      URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo%20bar", requirements: .percentEncoded)
    )
    #expect(encodedFragment.encoded == "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo%20bar")

    let encodedQuery = try #require(
      URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed?foo=bar%20baz", requirements: .percentEncoded)
    )
    #expect(encodedQuery.encoded == "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed?foo=bar%20baz")

    // Test that slash in fragment is decoded, not re-encoded because it is allowed in fragments
    let encodedPath = try #require(
      URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo%2Fbar", requirements: .percentEncoded)
    )
    #expect(encodedPath.encoded == "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo/bar")

    // Test that components are properly decoded during initialization
    #expect(encodedFragment.absolute?.fragment == "foo bar")
    #expect(encodedQuery.absolute?.query?.first?.value == "bar baz")
    #expect(encodedPath.absolute?.fragment == "foo/bar")
  }

  @Test("Percent encoding validation for file URIs")
  func percentEncodingValidationFile() async throws {
    // Test that file URIs with unencoded characters are rejected when percent encoding is required
    #expect(URI(encoded: "file:///path/to/file with spaces", requirements: .percentEncoded) == nil)
    #expect(URI(encoded: "file:///path/to/file?query=with spaces", requirements: .percentEncoded) == nil)
    #expect(URI(encoded: "file:///path/to/file#fragment with spaces", requirements: .percentEncoded) == nil)
    #expect(URI(encoded: "file://user:pass word@host/path", requirements: .percentEncoded) == nil)

    // Test that file URIs with properly encoded characters are accepted
    let encodedPath = try #require(URI(encoded: "file:///path/to/file%20with%20spaces", requirements: .percentEncoded))
    #expect(encodedPath.encoded == "file:///path/to/file%20with%20spaces")

    let encodedQuery = try #require(
      URI(encoded: "file:///path/to/file?query=with%20spaces", requirements: .percentEncoded)
    )
    #expect(encodedQuery.encoded == "file:///path/to/file?query=with%20spaces")

    let encodedFragment = try #require(
      URI(encoded: "file:///path/to/file#fragment%20with%20spaces", requirements: .percentEncoded)
    )
    #expect(encodedFragment.encoded == "file:///path/to/file#fragment%20with%20spaces")

    let encodedUserInfo = try #require(URI(encoded: "file://user:pass%20word@host/path", requirements: .percentEncoded))
    #expect(encodedUserInfo.encoded == "file://user:pass%20word@host/path")

    // Test that components are properly decoded during initialization
    #expect(encodedPath.absolute?.path.last?.decoded == "file with spaces")
    #expect(encodedQuery.absolute?.query?.first?.value == "with spaces")
    #expect(encodedFragment.absolute?.fragment == "fragment with spaces")
    #expect(encodedUserInfo.absolute?.authority?.userInfo?.password == "pass word")
  }
}
