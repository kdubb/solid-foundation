//
//  URITests.swift
//  Codex
//
//  Created by Kevin Wooten on 2/14/25.
//

import Foundation
import Testing
@testable import Codex

public struct URITests {

  @Test("Check satisfied `kind` requirements")
  func satisfiedKindRequirements() async throws {
    #expect(URI(encoded: "https://example.com", requirements: .kind(.absolute)) != nil)
    #expect(URI(encoded: "test#foo", requirements: .kind(.relative)) != nil)
    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo", requirements: .kind(.name)) != nil)
  }

  @Test("Check unsatisfied `kind` requirements fail initializer")
  func unsatisfiedKindRequirements() async throws {
    #expect(URI(encoded: "https://example.com", requirements: .kind(.relative)) == nil)
    #expect(URI(encoded: "test#foo", requirements: .kind(.absolute)) == nil)
    #expect(URI(encoded: "test#foo", requirements: .kind(.name)) == nil)
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

    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo", requirements: .fragment(.required)) != nil)
    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#", requirements: .fragment(.required)) != nil)
    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed", requirements: .fragment(.disallowed)) != nil)
    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#", requirements: .fragment(.disallowedOrEmpty)) != nil)
    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed", requirements: .fragment(.optional)) != nil)
    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#", requirements: .fragment(.optional)) != nil)
    #expect(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo", requirements: .fragment(.optional)) != nil)
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

  @Test("Check satisfied `normalized` requirements")
  func satisfiedNormalizedRequirements() async throws {
    #expect(URI(encoded: "https://example.com", requirements: .normalized) != nil)
    #expect(URI(encoded: "https://example.com/", requirements: .normalized) != nil)
    #expect(URI(encoded: "https://example.com/foo", requirements: .normalized) != nil)
    #expect(URI(encoded: "https://example.com/foo/", requirements: .normalized) != nil)
    #expect(URI(encoded: "https://example.com/foo/bar", requirements: .normalized) != nil)
    #expect(URI(encoded: "https://example.com/foo/bar/", requirements: .normalized) != nil)
  }

  @Test("Check unsatisfied `normalized` requirements fail initializer")
  func unsatisfiedNormalizedRequirements() async throws {
    #expect(URI(encoded: "https://example.com/./foo", requirements: .normalized) == nil)
    #expect(URI(encoded: "https://example.com/foo/../bar", requirements: .normalized) == nil)
    #expect(URI(encoded: "https://example.com/foo//bar", requirements: .normalized) == nil)

    #expect(URI(encoded: "example/./foo", requirements: .normalized) == nil)
    #expect(URI(encoded: "example/foo/../bar", requirements: .normalized) == nil)
    #expect(URI(encoded: "example/foo//bar", requirements: .normalized) == nil)
  }

  @Test func resolveURNFragmentAgainstBase() throws {

    let base = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed"))
    let abs = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#foo"))

    #expect(URI(encoded: "#foo")?.resolved(against: base) == abs)
  }

  @Test func resolveURIFragmentAgainstFileBase() throws {

    let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base.json"))
    let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base.json#foo"))

    #expect(URI(encoded: "#foo")?.resolved(against: base) == abs)
  }

  @Test func resolveRelativeURIAgainstFileBase() throws {

    let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base.json"))
    let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/d.json#foo"))

    #expect(URI(encoded: "d.json#foo")?.resolved(against: base) == abs)
  }

  @Test func resolveCurrentRelativeURIAgainstFileBase() throws {

    let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base"))
    let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/d.json#foo"))

    #expect(URI(encoded: "./d.json#foo")?.resolved(against: base) == abs)
  }

  @Test func resolveRelativeURIAgainstDirectoryBase() throws {

    let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/"))
    let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/d.json#foo"))

    #expect(URI(encoded: "d.json#foo")?.resolved(against: base) == abs)
  }

  @Test func resolveCurrentRelativeURIAgainstDirectoryBase() throws {

    let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/"))
    let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/d.json#foo"))

    #expect(URI(encoded: "./d.json#foo")?.resolved(against: base) == abs)
  }

  @Test func resolveRelativeURIAgainstBase() throws {

    let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base"))
    let abs = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base/d.json#foo"))

    #expect(URI(encoded: "./d.json#foo")?.resolved(against: base) == abs)
  }

  @Test func relativeToURL() throws {

    let base = try #require(URI(encoded: "https://example.com/draft2020-12/ref-and-id2/base"))
    let abs = try #require(URI(encoded: "https://example.com/draft2020-12//ref-and-id2/base/d.json#foo"))

    #expect(abs.relative(to: base) == .relative(encodedPath: "./d.json", fragment: "foo"))
  }

  @Test func relativeToURN() throws {

    let abs = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed"))
    let rel = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#/foo"))

    #expect(rel.relative(to: abs).description == "#/foo")
  }

  @Test func appendFragment() throws {

    let base = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed"))
    let res = try #require(URI(encoded: "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed#/foo"))

    #expect(base.appending(fragmentPointer: "/foo") == res)
  }


}
