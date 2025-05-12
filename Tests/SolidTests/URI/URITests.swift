//
//  URITests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/14/25.
//

@testable import SolidURI
import Foundation
import Testing


@Suite("URI Tests")
final class URITests {

  @Suite("URI Parsing and Validation")
  struct URIParsingTests {

    @Suite("Valid Absolute URIs")
    struct ValidAbsoluteURITests {

      @Test("Simple HTTP URI")
      func simpleHTTP() throws {
        let uriStr = "http://example.com"
        let uri = try #require(URI(encoded: uriStr))
        #expect(uri.scheme == "http")
        #expect(uri.authority?.host == "example.com")
        #expect(uri.encoded == uriStr)
      }

      @Test("Complex HTTPS URI")
      func complexHTTPS() throws {
        let uriStr = "https://user:pass@example.com:8080/path?query#fragment"
        let uri = try #require(URI(encoded: uriStr))
        #expect(uri.scheme == "https")
        #expect(uri.authority?.userInfo?.user == "user")
        #expect(uri.authority?.userInfo?.password == "pass")
        #expect(uri.authority?.host == "example.com")
        #expect(uri.authority?.port == 8080)
        try #require(uri.path.count == 2)
        #expect(uri.path[0] == .empty)
        #expect(uri.path[1].decoded == "path")
        try #require(uri.query?.count == 1)
        #expect(uri.query?[0].name == "query")
        #expect(uri.fragment == "fragment")
        #expect(uri.encoded == uriStr)
      }

      @Test("FTP URI")
      func ftp() throws {
        let uriStr = "ftp://example.com"
        let uri = try #require(URI(encoded: uriStr))
        #expect(uri.scheme == "ftp")
        #expect(uri.authority?.host == "example.com")
        #expect(uri.encoded == uriStr)
      }

      @Test("Mailto URI")
      func mailto() throws {
        let uriStr = "mailto:user@example.com"
        let uri = try #require(URI(encoded: uriStr))
        #expect(uri.scheme == "mailto")
        try #require(uri.path.count == 1)
        #expect(uri.path[0].decoded == "user@example.com")
        #expect(uri.encoded == uriStr)
      }

      @Test("URN")
      func urn() throws {
        let uriStr = "urn:example:test"
        let uri = try #require(URI(encoded: uriStr))
        #expect(uri.scheme == "urn")
        try #require(uri.path.count == 1)
        #expect(uri.path[0].decoded == "example:test")
        #expect(uri.encoded == uriStr)
      }
    }

    @Suite("Valid Relative References")
    struct ValidRelativeReferenceTests {

      @Test("Absolute path")
      func absolutePath() throws {
        let uriStr = "/path/to/resource"
        let uri = try #require(URI(encoded: uriStr))
        try #require(uri.path.count == 4)
        #expect(uri.path[0] == .empty)
        #expect(uri.path[1].decoded == "path")
        #expect(uri.path[2].decoded == "to")
        #expect(uri.path[3].decoded == "resource")
        #expect(uri.encoded == uriStr)
      }

      @Test("Protocol relative")
      func protocolRelative() throws {
        let uriStr = "//example.com/path"
        let uri = try #require(URI(encoded: uriStr))
        #expect(uri.authority?.host == "example.com")
        try #require(uri.path.count == 2)
        #expect(uri.path[0] == .empty)
        #expect(uri.path[1].decoded == "path")
        #expect(uri.encoded == uriStr)
      }

      @Test("Query only")
      func queryOnly() throws {
        let uriStr = "?query=value"
        let uri = try #require(URI(encoded: uriStr))
        try #require(uri.query?.count == 1)
        #expect(uri.query?[0].name == "query")
        #expect(uri.query?[0].value == "value")
        #expect(uri.encoded == uriStr)
      }

      @Test("Fragment only")
      func fragmentOnly() throws {
        let uriStr = "#fragment"
        let uri = try #require(URI(encoded: uriStr))
        #expect(uri.fragment == "fragment")
        #expect(uri.encoded == uriStr)
      }

      @Test("Relative path")
      func relativePath() throws {
        let uriStr = "path/to/resource"
        let uri = try #require(URI(encoded: uriStr))
        try #require(uri.path.count == 3)
        #expect(uri.path[0].decoded == "path")
        #expect(uri.path[1].decoded == "to")
        #expect(uri.path[2].decoded == "resource")
        #expect(uri.encoded == uriStr)
      }
    }

    @Suite("Invalid URIs")
    struct InvalidURITests {

      @Test("Missing host")
      func missingHost() {
        #expect(URI(encoded: "http://") == nil)
      }

      @Test("Missing scheme")
      func missingScheme() {
        #expect(URI(encoded: "://example.com") == nil)
      }

      @Test("Invalid port")
      func invalidPort() {
        #expect(URI(encoded: "http://example.com:port") == nil)
      }

      @Test("Multiple fragments")
      func multipleFragments() {
        #expect(URI(encoded: "http://example.com/path?query=value#fragment#extra") == nil)
      }
    }
  }

  @Suite("URI Components")
  struct URIComponentsTests {

    @Test("Basic components")
    func basicComponents() throws {
      let uri = try #require(URI(encoded: "https://user:pass@example.com:8080/path/to/resource?query=value#fragment"))

      // Test scheme
      #expect(uri.scheme == "https")
      #expect(uri.isAbsolute == true)

      // Test authority
      let authority = try #require(uri.authority)
      #expect(authority.userInfo?.user == "user")
      #expect(authority.userInfo?.password == "pass")
      #expect(authority.host == "example.com")
      #expect(authority.port == 8080)

      // Test path
      try #require(uri.path.count == 4)
      #expect(uri.path[0] == .empty)
      #expect(uri.path[1].decoded == "path")
      #expect(uri.path[2].decoded == "to")
      #expect(uri.path[3].decoded == "resource")

      // Test query
      let query = try #require(uri.query)
      try #require(query.count == 1)
      #expect(query[0].name == "query")
      #expect(query[0].value == "value")

      // Test fragment
      #expect(uri.fragment == "fragment")
    }

    @Test("Multiple query items")
    func multipleQueryItems() throws {
      let uri = try #require(URI(encoded: "https://example.com?first=1&second=2&third=3"))
      let query = try #require(uri.query)
      try #require(query.count == 3)
      #expect(query[0].name == "first")
      #expect(query[0].value == "1")
      #expect(query[1].name == "second")
      #expect(query[1].value == "2")
      #expect(query[2].name == "third")
      #expect(query[2].value == "3")
    }

    @Test("Query items with blank key")
    func queryItemsWithBlankKey() throws {
      let uri = try #require(URI(encoded: "https://example.com?=value"))
      let query = try #require(uri.query)
      try #require(query.count == 1)
      #expect(query[0].name == "")
      #expect(query[0].value == "value")
    }

    @Test("Query items with no value")
    func queryItemsWithNoValue() throws {
      let uri = try #require(URI(encoded: "https://example.com?key&key2"))
      let query = try #require(uri.query)
      try #require(query.count == 2)
      #expect(query[0].name == "key")
      #expect(query[0].value == nil)
      #expect(query[1].name == "key2")
      #expect(query[1].value == nil)
    }

    @Test("Query items with blank value")
    func queryItemsWithBlankValue() throws {
      let uri = try #require(URI(encoded: "https://example.com?key=&key2="))
      let query = try #require(uri.query)
      try #require(query.count == 2)
      #expect(query[0].name == "key")
      #expect(query[0].value == "")
      #expect(query[1].name == "key2")
      #expect(query[1].value == "")
    }
  }

  @Suite("URI Requirements")
  struct URIRequirementsTests {

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
    }

    @Test("Check unsatisfied `fragment` requirements fail initializer")
    func unsatisfiedFragmentRequirements() async throws {
      #expect(URI(encoded: "https://example.com#foo", requirements: .fragment(.disallowed)) == nil)
      #expect(URI(encoded: "https://example.com#", requirements: .fragment(.disallowed)) == nil)
      #expect(URI(encoded: "https://example.com", requirements: .fragment(.required)) == nil)
      #expect(URI(encoded: "https://example.com#foo", requirements: .fragment(.disallowedOrEmpty)) == nil)
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
  }

  @Suite("URI Resolution")
  struct URIResolutionTests {

    @Test("resolves relative path")
    func resolvesRelativePath() throws {
      let base = try #require(URI(encoded: "http://example.com/dir1/dir2/"))
      let relative = try #require(URI(encoded: "file.txt"))
      let resolved = relative.resolved(against: base)
      #expect(resolved.encoded == "http://example.com/dir1/dir2/file.txt")
    }

    @Test("resolves absolute path")
    func resolvesAbsolutePath() throws {
      let base = try #require(URI(encoded: "http://example.com/dir1/dir2/"))
      let relative = try #require(URI(encoded: "/file.txt"))
      let resolved = relative.resolved(against: base)
      #expect(resolved.encoded == "http://example.com/file.txt")
    }

    @Test("resolves with parent directory")
    func resolvesWithParentDirectory() throws {
      let base = try #require(URI(encoded: "http://example.com/dir1/dir2/"))
      let relative = try #require(URI(encoded: "../file.txt"))
      let resolved = relative.resolved(against: base)
      #expect(resolved.encoded == "http://example.com/dir1/file.txt")
    }

    @Test("resolves with current directory")
    func resolvesWithCurrentDirectory() throws {
      let base = try #require(URI(encoded: "http://example.com/dir1/dir2/"))
      let relative = try #require(URI(encoded: "./file.txt"))
      let resolved = relative.resolved(against: base)
      #expect(resolved.encoded == "http://example.com/dir1/dir2/file.txt")
    }

    @Test("resolve URN fragment against base")
    func resolveURNFragmentAgainstBase() throws {
      let base = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed"))
      let rel = try #require(URI(encoded: "#foo"))
      let abs = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo"))

      #expect(rel.resolved(against: base) == abs)
    }

    @Test("resolve URI fragment against file base")
    func resolveURIFragmentAgainstFileBase() throws {
      let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base.json"))
      let rel = try #require(URI(encoded: "#foo"))
      let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base.json#foo"))

      #expect(rel.resolved(against: base) == abs)
    }

    @Test("resolve relative URI against file base")
    func resolveRelativeURIAgainstFileBase() throws {
      let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base.json"))
      let rel = try #require(URI(encoded: "d.json#foo"))
      let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/d.json#foo"))

      #expect(rel.resolved(against: base) == abs)
    }

    @Test("resolve current relative URI against file base")
    func resolveCurrentRelativeURIAgainstFileBase() throws {
      let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base"))
      let rel = try #require(URI(encoded: "./d.json#foo"))
      let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/d.json#foo"))

      #expect(rel.resolved(against: base) == abs)
    }

    @Test("resolve relative URI against directory base")
    func resolveRelativeURIAgainstDirectoryBase() throws {
      let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/"))
      let rel = try #require(URI(encoded: "d.json#foo"))
      let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/d.json#foo"))

      #expect(rel.resolved(against: base) == abs)
    }

    @Test("resolve current relative URI against directory base")
    func resolveCurrentRelativeURIAgainstDirectoryBase() throws {
      let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/"))
      let rel = try #require(URI(encoded: "./d.json#foo"))
      let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/d.json#foo"))

      #expect(rel.resolved(against: base) == abs)
    }
  }

  @Suite("URI Relative Reference Handling")
  struct URIRelativeReferenceTests {

    @Test("creates relative reference")
    func createsRelativeReference() throws {
      let absolute = try #require(URI(encoded: "http://example.com/dir1/dir2/file.txt"))
      let base = try #require(URI(encoded: "http://example.com/dir1/"))
      let relative = absolute.relative(to: base)
      #expect(relative.encoded == "./dir2/file.txt")
      let absCheck = relative.resolved(against: base)
      #expect(absCheck == absolute)
    }

    @Test("handles different authority")
    func handlesDifferentAuthority() throws {
      let absolute = try #require(URI(encoded: "http://example.com/dir1/dir2/file.txt"))
      let base = try #require(URI(encoded: "http://other.com/dir1/"))
      let relative = absolute.relative(to: base)
      #expect(relative.encoded == "http://example.com/dir1/dir2/file.txt")
      let absCheck = relative.resolved(against: base)
      #expect(absCheck == absolute)
    }

    @Test("handles different scheme")
    func handlesDifferentScheme() throws {
      let absolute = try #require(URI(encoded: "http://example.com/dir1/dir2/file.txt"))
      let base = try #require(URI(encoded: "https://example.com/dir1/"))
      let relative = absolute.relative(to: base)
      #expect(relative.encoded == "http://example.com/dir1/dir2/file.txt")
      let absCheck = relative.resolved(against: base)
      #expect(absCheck == absolute)
    }

    @Test("relative to URL")
    func relativeToURL() throws {
      let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base"))
      let abs = try #require(URI(encoded: "https://example.com/draft2020-12//ref-and-id2/base/d.json#foo"))

      #expect(abs.relative(to: base) == .relative(encodedPath: "./d.json", fragment: "foo"))
    }

    @Test("relative to URN")
    func relativeToURN() throws {
      let abs = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed"))
      let rel = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#/foo"))

      #expect(rel.relative(to: abs).description == ".#/foo")
    }

    @Test("append fragment")
    func appendFragment() throws {
      let base = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed"))
      let res = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#/foo"))

      #expect(base.appending(fragmentPointer: "/foo") == res)
    }
  }

  @Suite("URI Percent Encoding")
  struct URIPercentEncodingTests {

    @Test("reserved characters in path")
    func reservedCharactersInPath() throws {
      let uri = try #require(URI(encoded: "http://example.com/path%20with%20spaces"))
      try #require(uri.path.count == 2)
      #expect(uri.path[0] == .empty)
      #expect(uri.path[1].decoded == "path with spaces")
      #expect(uri.path[1].encoded == "path%20with%20spaces")
    }

    @Test("non-ASCII characters in path")
    func nonASCIICharactersInPath() throws {
      let uri = try #require(URI(encoded: "http://example.com/path%E2%82%AC"))
      try #require(uri.path.count == 2)
      #expect(uri.path[0] == .empty)
      #expect(uri.path[1].decoded == "path€")
      #expect(uri.path[1].encoded == "path%E2%82%AC")
    }

    @Test("encoded . and .. segments in path")
    func encodedDotAndDotDotSegmentsInPath() throws {
      let uri = try #require(URI(encoded: "http://example.com/%2E/%2E%2E/file.txt"))
      try #require(uri.path.count == 4)
      #expect(uri.path[0] == .empty)
      #expect(uri.path[1].decoded == ".")
      #expect(uri.path[1].encoded == "%2E")
      #expect(uri.path[2].decoded == "..")
      #expect(uri.path[2].encoded == "%2E%2E")
      #expect(uri.path[3].decoded == "file.txt")
      #expect(uri.path[3].encoded == "file.txt")
    }

    @Test("reserved characters in query")
    func reservedCharactersInQuery() throws {
      let uri = try #require(URI(encoded: "http://example.com?query=value%20with%20spaces"))
      try #require(uri.query?.count == 1)
      #expect(uri.query?[0].value == "value with spaces")
      #expect(uri.query?[0].encoded == "query=value%20with%20spaces")
    }

    @Test("non-ASCII characters in query")
    func nonASCIICharactersInQuery() throws {
      let uri = try #require(URI(encoded: "http://example.com?query=value%E2%82%AC"))
      try #require(uri.query?.count == 1)
      #expect(uri.query?[0].value == "value€")
      #expect(uri.query?[0].encoded == "query=value%E2%82%AC")
    }

    @Test("reserved characters in fragment")
    func reservedCharactersInFragment() throws {
      let uri = try #require(URI(encoded: "http://example.com#fragment%20with%20spaces"))
      #expect(uri.fragment == "fragment with spaces")
      #expect(uri.encodedFragment == "fragment%20with%20spaces")
    }

    @Test("non-ASCII characters in fragment")
    func nonASCIICharactersInFragment() throws {
      let uri = try #require(URI(encoded: "http://example.com#fragment%E2%82%AC"))
      #expect(uri.fragment == "fragment€")
      #expect(uri.encodedFragment == "fragment%E2%82%AC")
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

      let encodedFragment = try #require(
        URI(encoded: "https://example.com/foo#bar%20baz", requirements: .percentEncoded)
      )
      #expect(encodedFragment.encoded == "https://example.com/foo#bar%20baz")

      let encodedUserInfo = try #require(
        URI(encoded: "https://user:pass%20word@example.com", requirements: .percentEncoded)
      )
      #expect(encodedUserInfo.encoded == "https://user:pass%20word@example.com")

      let encodedPath =
        try #require(URI(encoded: "https://example.com/foo/bar/%2E%2E/baz", requirements: .percentEncoded))
      #expect(encodedPath.encoded == "https://example.com/foo/bar/%2E%2E/baz")

      // Test that components are properly decoded during initialization
      try #require(encodedURI.absolute?.path.count == 2)
      #expect(encodedURI.absolute?.path.last?.decoded == "foo bar")
      try #require(encodedQuery.absolute?.query?.count == 1)
      #expect(encodedQuery.absolute?.query?.first?.value == "baz qux")
      #expect(encodedFragment.absolute?.fragment == "bar baz")
      #expect(encodedUserInfo.absolute?.authority?.userInfo?.password == "pass word")
      try #require(encodedPath.absolute?.path.count == 5)
      #expect(encodedPath.absolute?.path[3].decoded == "..")
    }

    @Test("Percent encoding roundtrip")
    func percentEncodingRoundtrip() async throws {
      // Test that encoding and decoding roundtrips work correctly
      let uri1 = try #require(URI(encoded: "https://example.com/foo%20bar"))
      #expect(uri1.encoded == "https://example.com/foo%20bar")
      try #require(uri1.absolute?.path.count == 2)
      #expect(uri1.absolute?.path.last?.decoded == "foo bar")

      let uri2 = try #require(URI(encoded: "https://example.com/foo?bar=baz%20qux"))
      #expect(uri2.encoded == "https://example.com/foo?bar=baz%20qux")
      try #require(uri2.absolute?.query?.count == 1)
      #expect(uri2.absolute?.query?.first?.value == "baz qux")

      let uri3 = try #require(URI(encoded: "https://example.com/foo#bar%20baz"))
      #expect(uri3.encoded == "https://example.com/foo#bar%20baz")
      #expect(uri3.absolute?.fragment == "bar baz")

      let uri4 = try #require(URI(encoded: "https://user:pass%20word@example.com"))
      #expect(uri4.encoded == "https://user:pass%20word@example.com")
      #expect(uri4.absolute?.authority?.userInfo?.password == "pass word")

      let uri5 = try #require(URI(encoded: "https://example.com/foo/bar/%2E%2E/baz"))
      #expect(uri5.encoded == "https://example.com/foo/bar/%2E%2E/baz")
      try #require(uri5.absolute?.path.count == 5)
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
      try #require(encodedURI.relativeReference?.path.count == 1)
      #expect(encodedURI.relativeReference?.path.last?.decoded == "foo bar")
      try #require(encodedQuery.relativeReference?.query?.count == 1)
      #expect(encodedQuery.relativeReference?.query?.first?.value == "baz qux")
      #expect(encodedFragment.relativeReference?.fragment == "bar baz")
      try #require(encodedPath.relativeReference?.path.count == 4)
      #expect(encodedPath.relativeReference?.path[2].decoded == "..")
    }

    @Test("Percent encoding validation for URNs")
    func percentEncodingValidationURN() async throws {
      // Test that URNs with unencoded characters are rejected when percent encoding is required
      #expect(
        URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo bar", requirements: .percentEncoded) == nil
      )
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
      try #require(encodedQuery.absolute?.query?.count == 1)
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
      let encodedPath = try #require(
        URI(encoded: "file:///path/to/file%20with%20spaces", requirements: .percentEncoded)
      )
      #expect(encodedPath.encoded == "file:///path/to/file%20with%20spaces")

      let encodedQuery = try #require(
        URI(encoded: "file:///path/to/file?query=with%20spaces", requirements: .percentEncoded)
      )
      #expect(encodedQuery.encoded == "file:///path/to/file?query=with%20spaces")

      let encodedFragment = try #require(
        URI(encoded: "file:///path/to/file#fragment%20with%20spaces", requirements: .percentEncoded)
      )
      #expect(encodedFragment.encoded == "file:///path/to/file#fragment%20with%20spaces")

      let encodedUserInfo = try #require(
        URI(encoded: "file://user:pass%20word@host/path", requirements: .percentEncoded)
      )
      #expect(encodedUserInfo.encoded == "file://user:pass%20word@host/path")

      // Test that components are properly decoded during initialization
      try #require(encodedPath.absolute?.path.count == 4)
      #expect(encodedPath.absolute?.path.last?.decoded == "file with spaces")
      try #require(encodedQuery.absolute?.query?.count == 1)
      #expect(encodedQuery.absolute?.query?.first?.value == "with spaces")
      #expect(encodedFragment.absolute?.fragment == "fragment with spaces")
      #expect(encodedUserInfo.absolute?.authority?.userInfo?.password == "pass word")
    }
  }

  @Suite("URI normalization")
  struct URINormalizationTests {

    @Test("scheme and host")
    func schemeAndHost() throws {
      let uri = URI(
        scheme: "HTTP",
        authority: URI.Authority(host: "EXAMPLE.COM", port: nil, userInfo: nil),
        path: [.decoded("path")],
        query: nil,
        fragment: nil
      )
      let normalized = uri.normalized()
      #expect(normalized.scheme == "http")
      #expect(normalized.authority?.host == "example.com")
    }

    @Test("empty segments with trailing slash")
    func emptySegmentsWithTrailingSlash() throws {
      let uri = URI(
        scheme: "http",
        authority: URI.Authority(host: "example.com", port: nil, userInfo: nil),
        path: [.empty, .decoded("a"), .empty, .decoded("b"), .empty],
        query: nil,
        fragment: nil
      )
      let normalized = uri.normalized()
      try #require(normalized.path.count == 4)
      #expect(normalized.path[0] == .empty)
      #expect(normalized.path[1].decoded == "a")
      #expect(normalized.path[2].decoded == "b")
      #expect(normalized.path[3] == .empty)
    }

    @Test("empty segments without trailing slash")
    func emptySegmentsWithoutTrailingSlash() throws {
      let uri = URI(
        scheme: "http",
        authority: URI.Authority(host: "example.com", port: nil, userInfo: nil),
        path: [.empty, .decoded("a"), .empty, .decoded("b"), .empty],
        query: nil,
        fragment: nil
      )
      let normalized = uri.normalized(retainTrailingEmptySegment: false)
      try #require(normalized.path.count == 3)
      #expect(normalized.path[0] == .empty)
      #expect(normalized.path[1].decoded == "a")
      #expect(normalized.path[2].decoded == "b")
    }

    @Test("current directory segments are normalized for absolute URIs")
    func currentDirectorySegments() throws {
      let uri = URI(
        scheme: "http",
        authority: URI.Authority(host: "example.com", port: nil, userInfo: nil),
        path: [.current, .decoded("a"), .current, .decoded("b"), .current],
        query: nil,
        fragment: nil
      )
      let normalized = uri.normalized()
      try #require(normalized.path.count == 2)
      #expect(normalized.path[0].decoded == "a")
      #expect(normalized.path[1].decoded == "b")
    }

    @Test("only leading current directory segments are retained for relative references")
    func leadingCurrentDirectorySegmentsForRelativeReferences() throws {
      let uri = URI(
        scheme: nil,
        authority: nil,
        path: [.current, .decoded("a"), .current, .decoded("b"), .current],
        query: nil,
        fragment: nil
      )
      let normalized = uri.normalized()
      try #require(normalized.path.count == 3)
      #expect(normalized.path[0] == .current)
      #expect(normalized.path[1].decoded == "a")
      #expect(normalized.path[2].decoded == "b")
    }

    @Test("parent directory segments are normalized for absolute URIs")
    func parentDirectorySegments() throws {
      let uri = URI(
        scheme: "http",
        authority: URI.Authority(host: "example.com", port: nil, userInfo: nil),
        path: [.decoded("a"), .parent, .decoded("b"), .parent],
        query: nil,
        fragment: nil
      )
      let normalized = uri.normalized()
      try #require(normalized.path.count == 0)
    }

    @Test("only leading parent directory segments are retained for relative references")
    func leadingParentDirectorySegmentsForRelativeReferences() throws {
      let uri = URI(
        scheme: nil,
        authority: nil,
        path: [.parent, .decoded("a"), .parent, .decoded("b"), .parent],
        query: nil,
        fragment: nil
      )
      let normalized = uri.normalized()
      try #require(normalized.path.count == 1)
      #expect(normalized.path[0] == .parent)
    }

    @Test("mixed segments normalize for absolute URIs")
    func mixedSegments() throws {
      let uri = URI(
        scheme: "http",
        authority: URI.Authority(host: "example.com", port: nil, userInfo: nil),
        path: [.empty, .decoded("a"), .decoded("b"), .current, .parent, .decoded("c"), .empty],
        query: nil,
        fragment: nil
      )
      let normalized = uri.normalized()
      try #require(normalized.path.count == 4)
      #expect(normalized.path[0] == .empty)
      #expect(normalized.path[1].decoded == "a")
      #expect(normalized.path[2].decoded == "c")
      #expect(normalized.path[3] == .empty)
    }

    @Test("mixed segments normalize for relative references")
    func mixedSegmentsForRelativeReferences() throws {
      let uri = URI.relative(
        path: [.current, .decoded("a"), .decoded("b"), .current, .parent, .decoded("c"), .empty]
      )
      let normalized = uri.normalized()
      try #require(normalized.path.count == 4)
      #expect(normalized.path[0] == .current)
      #expect(normalized.path[1].decoded == "a")
      #expect(normalized.path[2].decoded == "c")
      #expect(normalized.path[3] == .empty)
    }
  }

  @Suite("File URIs")
  struct FileURIs {

    @Test("absolute file URI without host")
    func absoluteFileURIWithoutHost() throws {
      let fileURI = try #require(URI(encoded: "file:///path/to/file.txt"))
      #expect(fileURI.scheme == "file")
      #expect(fileURI.authority == .init(host: "", port: nil, userInfo: nil))
      #expect(fileURI.path.count == 4)
      #expect(fileURI.path[0] == .empty)
      #expect(fileURI.path[1].decoded == "path")
      #expect(fileURI.path[2].decoded == "to")
      #expect(fileURI.path[3].decoded == "file.txt")
    }

    @Test("absolute file URI without authority")
    func absoluteFileURIWithoutAuthority() throws {
      let fileURI = try #require(URI(encoded: "file:/path/to/file.txt"))
      #expect(fileURI.scheme == "file")
      #expect(fileURI.authority == nil)
      #expect(fileURI.path.count == 4)
      #expect(fileURI.path[0] == .empty)
      #expect(fileURI.path[1].decoded == "path")
      #expect(fileURI.path[2].decoded == "to")
      #expect(fileURI.path[3].decoded == "file.txt")
    }

    @Test("file URI with host")
    func fileURIWithHost() throws {
      let fileURI = try #require(URI(encoded: "file://localhost/path/to/file.txt"))
      #expect(fileURI.scheme == "file")
      #expect(fileURI.authority?.host == "localhost")
      #expect(fileURI.path.count == 4)
      #expect(fileURI.path[0] == .empty)
      #expect(fileURI.path[1].decoded == "path")
      #expect(fileURI.path[2].decoded == "to")
      #expect(fileURI.path[3].decoded == "file.txt")
    }

    @Test("relative file URI")
    func relativeFileURI() throws {
      let fileURI = try #require(URI(encoded: "file.txt"))
      #expect(fileURI.scheme == nil)
      #expect(fileURI.path.count == 1)
      #expect(fileURI.path[0].decoded == "file.txt")
    }
  }

  @Suite("URN URIs")
  struct URNURIs {

    @Test("URN with NID")
    func urnWithNID() throws {
      let urn = try #require(URI(encoded: "urn:isbn:0451450523"))
      #expect(urn.scheme == "urn")
      #expect(urn.authority == nil)
      try #require(urn.path.count == 1)
      #expect(urn.path[0] == .name("isbn:0451450523"))
      #expect(urn.path[0].decoded == "isbn:0451450523")
      #expect(urn.path[0].encoded == "isbn:0451450523")
    }

    @Test("URN with NSS")
    func urnWithNSS() throws {
      let urn = try #require(URI(encoded: "urn:uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66"))
      #expect(urn.scheme == "urn")
      #expect(urn.authority == nil)
      try #require(urn.path.count == 1)
      #expect(urn.path[0] == .name("uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66"))
      #expect(urn.path[0].decoded == "uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66")
      #expect(urn.path[0].encoded == "uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66")
    }

    @Test("URN with query and fragment")
    func urnWithQueryAndFragment() throws {
      let urn = try #require(URI(encoded: "urn:example:test?query=value#fragment"))
      #expect(urn.scheme == "urn")
      #expect(urn.authority == nil)
      try #require(urn.path.count == 1)
      #expect(urn.path[0] == .name("example:test"))
      #expect(urn.path[0].decoded == "example:test")
      #expect(urn.path[0].encoded == "example:test")
      try #require(urn.query?.count == 1)
      #expect(urn.query?[0].name == "query")
      #expect(urn.query?[0].value == "value")
      #expect(urn.fragment == "fragment")
    }
  }

  @Suite("URI Conversion")
  struct URIConversion {

    @Test("Converting absolute URI to relative")
    func absoluteToRelative() throws {
      let absolute = try #require(URI(encoded: "http://example.com/dir1/dir2/file.txt"))
      let relative = absolute.relative(pathTransform: .directory)
      #expect(relative.scheme == nil)
      try #require(relative.path.count == 4)
      #expect(relative.path[0] == .current)
      #expect(relative.path[1].decoded == "dir1")
      #expect(relative.path[2].decoded == "dir2")
      #expect(relative.path[3].decoded == "file.txt")
    }

    @Test("Converting relative URI to absolute")
    func relativeToAbsolute() throws {
      let base = try #require(URI(encoded: "http://example.com/"))
      let relative = try #require(URI(encoded: "dir1/dir2/file.txt"))
      let resolved = relative.resolved(against: base)
      #expect(resolved.scheme == "http")
      #expect(resolved.authority?.host == "example.com")
      try #require(resolved.path.count == 4)
      #expect(resolved.path[0] == .empty)
      #expect(resolved.path[1].decoded == "dir1")
      #expect(resolved.path[2].decoded == "dir2")
      #expect(resolved.path[3].decoded == "file.txt")
    }
  }

  @Test("URI manipulation methods")
  func uriManipulationMethods() throws {
    let uri = try #require(URI(encoded: "http://example.com/path?query=value#fragment"))

    // Test updating components
    let updated1 = uri.updating(.scheme("https"))
    #expect(updated1.scheme == "https")

    let updated2 = uri.updating(.host("newexample.com"))
    #expect(updated2.authority?.host == "newexample.com")

    let updated3 = uri.updating(.path([.decoded("newpath")]))
    #expect(updated3.path[0].decoded == "newpath")

    let updated4 = uri.updating(.query([.init(name: "newquery", value: "newvalue")]))
    #expect(updated4.query?[0].name == "newquery")
    #expect(updated4.query?[0].value == "newvalue")

    let updated5 = uri.updating(.fragment("newfragment"))
    #expect(updated5.fragment == "newfragment")

    // Test removing components
    let removed1 = uri.removing(.query)
    #expect(removed1.query == nil)

    let removed2 = uri.removing(.fragment)
    #expect(removed2.fragment == nil)
  }
}
