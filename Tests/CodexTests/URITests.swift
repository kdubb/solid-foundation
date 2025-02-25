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
