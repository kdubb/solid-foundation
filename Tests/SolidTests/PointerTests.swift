//
//  PointerTests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 1/31/25.
//

import Testing
@testable import Solid

@Suite("Pointer Tests")
struct PointerTests {

  @Test(
    "Tokens Initializer",
    arguments: [
      ("names", Pointer(tokens: [.name("foo"), .name("bar")]), [.name("foo"), .name("bar")]),
      ("names (variadic)", Pointer(tokens: .name("foo"), .name("bar")), [.name("foo"), .name("bar")]),
      ("names (literals)", Pointer(tokens: "foo", "bar"), [.name("foo"), .name("bar")]),
      ("name/index", Pointer(tokens: [.name("foo"), .index(0)]), [.name("foo"), .index(0)]),
      ("name/index (variadic)", Pointer(tokens: .name("foo"), .index(0)), [.name("foo"), .index(0)]),
      ("name/index (literals)", Pointer(tokens: "foo", 0), [.name("foo"), .index(0)]),
      ("name/append", Pointer(tokens: [.name("foo"), .append]), [.name("foo"), .append]),
      ("name/append (variadic)", Pointer(tokens: .name("foo"), .append), [.name("foo"), .append]),
      ("name/append (literals)", Pointer(tokens: "foo", .append), [.name("foo"), .append]),
      ("index", Pointer(tokens: [.index(0)]), [.index(0)]),
      ("index (variadic)", Pointer(tokens: .index(0)), [.index(0)]),
      ("index (literals)", Pointer(tokens: 0), [.index(0)]),
      ("index/name", Pointer(tokens: [.index(0), .name("foo")]), [.index(0), .name("foo")]),
      ("index/name (variadic)", Pointer(tokens: .index(0), .name("foo")), [.index(0), .name("foo")]),
      ("index/name (literals)", Pointer(tokens: 0, "foo"), [.index(0), .name("foo")]),
      ("index/append", Pointer(tokens: [.index(0), .append]), [.index(0), .append]),
      ("index/append (variadic)", Pointer(tokens: .index(0), .append), [.index(0), .append]),
      ("index/append (literals)", Pointer(tokens: 0, .append), [.index(0), .append]),
      ("append", Pointer(tokens: [.append]), [.append]),
      ("append (variadic)", Pointer(tokens: .append), [.append]),
      ("append (literals)", Pointer(tokens: .append), [.append]),
      ("index/index", Pointer(tokens: [.index(0), .index(1)]), [.index(0), .index(1)]),
      ("index/index (variadic)", Pointer(tokens: .index(0), .index(1)), [.index(0), .index(1)]),
      ("index/index (literals)", Pointer(tokens: 0, 1), [.index(0), .index(1)]),
    ] as [(String, Pointer, [Pointer.ReferenceToken])]
  )
  func tokensInitializer(id: String, pointer: Pointer, tokens: [Pointer.ReferenceToken]) throws {
    #expect(pointer.tokens == tokens)
  }

  @Test(
    "Decoding Initializer",
    arguments: [
      // RFC 6901
      ("", [], true),
      ("/foo", [.name("foo")], true),
      ("/foo/0", [.name("foo"), .index(0)], true),
      ("/", [.name("")], true),
      ("/a~1b", [.name("a/b")], true),
      ("/c%d", [.name("c%d")], true),
      ("/e^f", [.name("e^f")], true),
      ("/g|h", [.name("g|h")], true),
      ("/i\\j", [.name("i\\j")], true),
      ("/k\"l", [.name("k\"l")], true),
      ("/ ", [.name(" ")], true),
      ("/m~0n", [.name("m~n")], true),

      // Extra
      ("/01", [.name("01")], true),
      ("/001", [.name("001")], true),

      // ~ Escapes (lenient)
      ("/num~s", [.name("num~s")], false),
      ("/nums~", [.name("nums~")], false),
      ("/nums~/0", [.name("nums~"), .index(0)], false),

      // Invalid
      ("foo", nil, true),
      ("foo/", nil, true),

      // Invalid ~ Escapes (strict)
      ("/num~s", nil, true),
      ("/nums~", nil, true),
      ("/nums~/0", nil, true),
    ] as [(String, [Pointer.ReferenceToken]?, Bool)]
  )
  func decodingInitializer(pointer: String, expectedTokens: [Pointer.ReferenceToken]?, strict: Bool) throws {
    try #require(Pointer(encoded: pointer, strict: strict)?.tokens == expectedTokens)
  }

  @Test(
    "Validating Initializer",
    arguments: [
      // Invalid
      ("foo", 0, "Expected '/'", false),
      ("foo/", 0, "Expected '/'", false),
      // Invalid ~ Escapes (strict)
      ("/num~s", 5, "~ escaping anything but 0 or 1", true),
      ("/num~", 4, "~ at end of string", true),
    ] as [(String, Int, String, Bool)]
  )
  func validatingInitializer(
    pointer: String,
    expectedPosition: Int,
    expectedDetails: String,
    expectedTokenError: Bool
  ) throws {

    let error = try #require(throws: Pointer.Error.self) { try Pointer(validating: pointer) }
    if expectedTokenError {
      guard case .invalidReferenceToken(_, let position, let details) = error else {
        Issue.record("Expected invalid reference token error")
        return
      }
      try #require(position == expectedPosition)
      try #require(details.contains(expectedDetails))
    } else {
      guard case .invalidPointer(_, let position, let details) = error else {
        Issue.record("Expected invalid pointer error")
        return
      }
      try #require(position == expectedPosition)
      try #require(details.contains(expectedDetails))
    }
  }

  @Test(
    "Appending",
    arguments: [
      (Pointer(tokens: .name("foo")), ["bar", 0], [.name("foo"), .name("bar"), .index(0)]),
      (Pointer(tokens: .name("foo")), [0, "bar"], [.name("foo"), .index(0), .name("bar")]),
      (Pointer(tokens: .name("foo")), [.append, "bar"], [.name("foo"), .append, .name("bar")]),

      (Pointer(tokens: .index(1)), ["bar", 0], [.index(1), .name("bar"), .index(0)]),
      (Pointer(tokens: .index(1)), [0, "bar"], [.index(1), .index(0), .name("bar")]),
      (Pointer(tokens: .index(1)), [.append, "bar"], [.index(1), .append, .name("bar")]),

      (Pointer(tokens: .append), ["bar", 0], [.append, .name("bar"), .index(0)]),
      (Pointer(tokens: .append), [0, "bar"], [.append, .index(0), .name("bar")]),
      (Pointer(tokens: .append), [.append, "bar"], [.append, .append, .name("bar")]),
    ] as [(Pointer, [Pointer.ReferenceToken], [Pointer.ReferenceToken])]
  )
  func appending(pointer: Pointer, appendTokens: [Pointer.ReferenceToken], expectedTokens: [Pointer.ReferenceToken])
    throws
  {
    #expect(pointer.appending(tokens: appendTokens).tokens == expectedTokens)
    #expect((pointer / appendTokens[0] / appendTokens[1]).tokens == expectedTokens)
  }

  @Test("Appending Literals")
  func appendingLiterals() throws {
    #expect(
      Pointer(tokens: .name("foo")).appending(tokens: "bar", 0).tokens == [.name("foo"), .name("bar"), .index(0)]
    )
    #expect(Pointer(tokens: .name("foo")).appending(tokens: "bar~10").tokens == [.name("foo"), .name("bar/0")])
    #expect(Pointer(tokens: .name("foo")).appending(tokens: "bar/0").tokens == [.name("foo"), .name("bar/0")])
    #expect((Pointer(tokens: .name("foo")) / "bar" / 0).tokens == [.name("foo"), .name("bar"), .index(0)])
    #expect((Pointer(tokens: .name("foo")) / "bar/0").tokens == [.name("foo"), .name("bar/0")])
    #expect((Pointer(tokens: .name("foo")) / "/bar/0").tokens == [.name("foo"), .name("bar"), .index(0)])
  }

  @Test func dropping() async throws {

    let pointer: Pointer = "/foo/bar/baz/0"

    try #require(pointer.parent.tokens == [.name("foo"), .name("bar"), .name("baz")])
    try #require(pointer.dropping(count: 1).tokens == [.name("foo"), .name("bar"), .name("baz")])
    try #require(pointer.dropping(count: 3).tokens == [.name("foo")])
    try #require(pointer.dropping(count: 4).tokens == [])
    try #require(pointer.dropping(count: 10).tokens == [])
  }

  @Test func description() throws {

    try #require(Pointer(validating: "/foo").description == "/foo")
    try #require(Pointer(validating: "/foo/0").description == "/foo/0")
    try #require(Pointer(validating: "/foo/-").description == "/foo/-")
    try #require(Pointer(validating: "/foo~1bar/-").description == #"/"foo/bar"/-"#)
  }

  @Test func debugDescription() throws {

    let pointer = try Pointer(validating: "/foo~1bar/-")
    debugPrint(pointer)

    try #require(Pointer(validating: "/foo").debugDescription == "/foo")
    try #require(Pointer(validating: "/foo/0").debugDescription == "/foo/0")
    try #require(Pointer(validating: "/foo/-").debugDescription == "/foo/-")
    try #require(Pointer(validating: "/foo~1bar/-").debugDescription == #"/f̲o̲o̲/̲b̲a̲r̲/-"#)
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
    try #require(tokens == [.name("foo"), .name("bar"), .name("baz"), .index(0)])

    try #require(pointer.map { $0 } == [.name("foo"), .name("bar"), .name("baz"), .index(0)])
  }


  @Suite("Value Tests")
  struct ValueTests {

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

}
