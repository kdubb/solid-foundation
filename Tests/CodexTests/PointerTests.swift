//
//  PointerTests.swift
//  Codex
//
//  Created by Kevin Wooten on 1/31/25.
//

import Testing
@testable import Codex

struct PointerTests {

  @Test func tokensInitializer() throws {

    try #require(Pointer(tokens: "foo", "bar").tokens == ["foo", "bar"])
    try #require(Pointer(tokens: "foo", 0).tokens == ["foo", 0])
    try #require(Pointer(tokens: "foo", .append).tokens == ["foo", .append])

    try #require(Pointer(tokens: []).tokens == [])
    try #require(Pointer(tokens: ["foo", "bar"]).tokens == ["foo", "bar"])
    try #require(Pointer(tokens: ["foo", 0]).tokens == ["foo", 0])
    try #require(Pointer(tokens: ["foo", .append]).tokens == ["foo", .append])
  }

  @Test func decodingInitialzer() throws {

    // RFC 6901
    try #require(Pointer(encoded: "")?.tokens == [])
    try #require(Pointer(encoded: "/foo")?.tokens == ["foo"])
    try #require(Pointer(encoded: "/foo/0")?.tokens == ["foo", 0])
    try #require(Pointer(encoded: "/")?.tokens == [""])
    try #require(Pointer(encoded: "/a~1b")?.tokens == ["a/b"])
    try #require(Pointer(encoded: "/c%d")?.tokens == ["c%d"])
    try #require(Pointer(encoded: "/e^f")?.tokens == ["e^f"])
    try #require(Pointer(encoded: "/g|h")?.tokens == ["g|h"])
    try #require(Pointer(encoded: "/i\\j")?.tokens == ["i\\j"])
    try #require(Pointer(encoded: "/k\"l")?.tokens == ["k\"l"])
    try #require(Pointer(encoded: "/ ")?.tokens == [" "])
    try #require(Pointer(encoded: "/m~0n")?.tokens == ["m~n"])

    // Extra
    try #require(Pointer(encoded: "/01")?.tokens == ["01"])
    try #require(Pointer(encoded: "/001")?.tokens == ["001"])
  }

  @Test func literalInitializer() throws {

    let pointer: Pointer = "/foo/0"
    try #require(pointer.tokens == ["foo", 0])

    let pointer2: Pointer = "foo"
    try #require(pointer2.tokens == ["foo"])

    let pointer3: Pointer = 0
    try #require(pointer3.tokens == [0])
  }

  @Test func appending() throws {

    let pointer: Pointer = "/foo"

    try #require(pointer.appending(tokens: ["bar", 0]).tokens == ["foo", "bar", 0])
    try #require(pointer.appending(tokens: "bar", 0).tokens == ["foo", "bar", 0])
    try #require(pointer.appending(pointer: "bar").tokens == ["foo", "bar"])
    try #require(pointer.appending(string: "bar/0").tokens == ["foo", "bar", 0])
    try #require((pointer / "bar" / 0).tokens == ["foo", "bar", 0])
    try #require((pointer / "bar/0").tokens == ["foo", "bar", 0])
  }

  @Test func dropping() async throws {

    let pointer: Pointer = "/foo/bar/baz/0"

    try #require(pointer.parent.tokens == ["foo", "bar", "baz"])
    try #require(pointer.dropping(count: 1).tokens == ["foo", "bar", "baz"])
    try #require(pointer.dropping(count: 3).tokens == ["foo"])
    try #require(pointer.dropping(count: 4).tokens == [])
    try #require(pointer.dropping(count: 10).tokens == [])
  }

  @Test func description() throws {

    try #require(Pointer(validating: "/foo").description == "/foo")
    try #require(Pointer(validating: "/foo/0").description == "/foo/0")
    try #require(Pointer(validating: "/foo/-").description == "/foo/-")
    try #require(Pointer(validating: "/foo~1bar/-").description == #"/foo~1bar/-"#)
  }

  @Test func debugDescription() throws {

    try #require(Pointer(validating: "/foo").debugDescription == "/foo")
    try #require(Pointer(validating: "/foo/0").debugDescription == "/foo/0")
    try #require(Pointer(validating: "/foo/-").debugDescription == "/foo/-")
    try #require(Pointer(validating: "/foo~1bar/-").debugDescription == #"/"foo/bar"/-"#)
  }

  @Test func encoded() throws {

    try #require(Pointer(validating: "/foo").encoded == "/foo")
    try #require(Pointer(validating: "/foo/0").encoded == "/foo/0")
    try #require(Pointer(validating: "/foo/-").encoded == "/foo/-")
    try #require(Pointer(validating: "/foo~1bar/-").encoded == #"/foo~1bar/-"#)
  }

  @Test func iteration() throws {

    let pointer: Pointer = "/foo/bar/baz/0"

    var tokens: Pointer.ReferenceTokens = []
    for token in pointer {
      tokens.append(token)
    }
    try #require(tokens == ["foo", "bar", "baz", 0])

    try #require(pointer.map { $0 } == ["foo", "bar", "baz", 0])
  }

}

struct PointerValueTests {

  @Test func get() throws {

    let value: Value = [
      "foo": ["bar", "baz"],
      "bar": [0, 2],
    ]

    try #require(value[Pointer(validating: "/foo")] == ["bar", "baz"])
    try #require(value[Pointer(validating: "/foo/0")] == "bar")
    try #require(value[Pointer(validating: "/bar/0")] == 0)
    try #require(value[Pointer(validating: "/bar/1")] == 2)

    try #require(value[Pointer(validating: "/bar/-")] == nil)
  }

  @Test func setName() throws {

    let value: Value = [
      "foo": ["bar", "baz"],
      "bar": [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/bar")] = "qux"
    try #require(copy == ["foo": ["bar", "baz"], "bar": "qux"])
  }

  @Test func setChildName() throws {

    let value: Value = [
      "foo": ["bar": "baz"],
      "bar": [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/foo/bar")] = "qux"
    try #require(copy == ["foo": ["bar": "qux"], "bar": [0, 2]])
  }

  @Test func setNewName() throws {

    let value: Value = [
      "foo": ["bar", "baz"],
      "bar": [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/baz")] = "qux"
    try #require(copy == ["foo": ["bar", "baz"], "bar": [0, 2], "baz": "qux"])
  }

  @Test func setNewChildName() throws {

    let value: Value = [
      "foo": ["bar": "baz"],
      "bar": [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/foo/baz")] = "qux"
    try #require(copy == ["foo": ["bar": "baz", "baz": "qux"], "bar": [0, 2]])
  }

  @Test func setIndex() throws {

    let value: Value = [
      0,
      ["bar", "baz"],
      [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/0")] = "qux"
    try #require(copy == ["qux", ["bar", "baz"], [0, 2]])
  }

  @Test func setNewIndex() throws {

    let value: Value = [
      0,
      ["bar", "baz"],
      [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/-")] = "qux"
    try #require(copy == [0, ["bar", "baz"], [0, 2], "qux"])
  }

  @Test func setChildIndex() throws {
    let value: Value = [
      0,
      ["bar", "baz"],
      [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/2/1")] = "qux"
    try #require(copy == [0, ["bar", "baz"], [0, "qux"]])
  }

  @Test func setNewChildIndex() throws {

    let value: Value = [
      0,
      ["bar", "baz"],
      [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/2/-")] = "qux"
    try #require(copy == [0, ["bar", "baz"], [0, 2, "qux"]])
  }

  @Test func setNameIndex() throws {

    let value: Value = [
      "foo": ["bar", "baz"],
      "bar": [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/bar/0")] = "qux"
    try #require(copy == ["foo": ["bar", "baz"], "bar": ["qux", 2]])
  }

  @Test func setNameNewIndex() throws {

    let value: Value = [
      "foo": ["bar", "baz"],
      "bar": [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/bar/-")] = "qux"
    try #require(copy == ["foo": ["bar", "baz"], "bar": [0, 2, "qux"]])
  }

  @Test func setIndexName() throws {

    let value: Value = [
      ["bar": "baz"],
      [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/0/bar")] = "qux"
    try #require(copy == [["bar": "qux"], [0, 2]])
  }

  @Test func setIndexNewName() throws {

    let value: Value = [
      ["bar": "baz"],
      [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/0/baz")] = "qux"
    try #require(copy == [["bar": "baz", "baz": "qux"], [0, 2]])
  }

  @Test func removeIndex() throws {

    let value: Value = [
      ["bar": "baz"],
      [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/0")] = nil
    try #require(copy == [[0, 2]])
  }

  @Test func removeChildIndex() throws {

    let value: Value = [
      ["bar": "baz"],
      [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/1/1")] = nil
    try #require(copy == [["bar": "baz"], [0]])
  }

  @Test func removeName() throws {

    let value: Value = [
      "foo": ["bar": "baz"],
      "bar": [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/bar")] = nil
    try #require(copy == ["foo": ["bar": "baz"]])
  }

  @Test func removeChildName() throws {

    let value: Value = [
      "foo": ["bar": "baz"],
      "bar": [0, 2],
    ]

    var copy = value
    copy[try Pointer(validating: "/foo/bar")] = nil
    try #require(copy == ["foo": [:], "bar": [0, 2]])
  }

  @Test func getRoot() throws {

    let value: Value = ["bar": "baz"]

    try #require(value[.root] == ["bar": "baz"])
  }

  @Test func setRoot() throws {

    let value: Value = [
      ["bar": "baz"]
    ]

    var copy = value
    copy[.root] = "qux"
    try #require(copy == "qux")
  }

}
