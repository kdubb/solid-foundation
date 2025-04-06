//
//  PathTests.swift
//  Codex
//
//  Created by Kevin Wooten on 1/31/25.
//

import Testing
@testable import Codex

@Suite("Path Parsing Tests")
struct PathParsingTests {

  typealias Seg = Path.Segment
  typealias Sel = Path.Selector
  typealias Expr = Path.Selector.Expression

  @Test func rootSelector() throws {
    let path = try Path.parse("$")
    try #require(path.segments == [.root])
  }

  @Test func childMemberSelector() throws {
    let path = try Path.parse("$.foo")
    try #require(path.segments.count == 2)
    #expect(path.segments == [.root, .child([.name("foo")])])
  }

  @Test func childWildcardSelector() throws {
    let path = try Path.parse("$.*")
    try #require(path.segments.count == 2)
    #expect(path.segments == [.root, .child([.wildcard])])
  }

  @Test func childIndexSelector() throws {
    let path = try Path.parse("$[0]")
    try #require(path.segments.count == 2)
    #expect(path.segments == [.root, .child([.index(0)])])
  }

  @Test func filterCompEqSelector() throws {
    let path = try Path.parse("$[?@.foo == 42]")
    try #require(path.segments.count == 2)
    let left: Expr = .singularQuery(segments: [.current, .child([.name("foo")])])
    let right: Expr = .literal(42)
    #expect(path.segments == [.root, .child([.filter(.comparison(left: left, operator: .eq, right: right))])])
  }

  @Test func filterCompNeSelector() throws {
    let path = try Path.parse("$[?@.foo != 42]")
    try #require(path.segments.count == 2)
    let left: Expr = .singularQuery(segments: [.current, .child([.name("foo")])])
    let right: Expr = .literal(42)
    #expect(path.segments == [.root, .child([.filter(.comparison(left: left, operator: .ne, right: right))])])
  }

  @Test func filterCompLtSelector() throws {
    let path = try Path.parse("$[?@.foo < 42]")
    try #require(path.segments.count == 2)
    let left: Expr = .singularQuery(segments: [.current, .child([.name("foo")])])
    let right: Expr = .literal(42)
    #expect(path.segments == [.root, .child([.filter(.comparison(left: left, operator: .lt, right: right))])])
  }

  @Test func filterCompLeSelector() throws {
    let path = try Path.parse("$[?@.foo <= 42]")
    try #require(path.segments.count == 2)
    let left: Expr = .singularQuery(segments: [.current, .child([.name("foo")])])
    let right: Expr = .literal(42)
    #expect(path.segments == [.root, .child([.filter(.comparison(left: left, operator: .le, right: right))])])
  }

  @Test func filterCompGtSelector() throws {
    let path = try Path.parse("$[?@.foo > 42]")
    try #require(path.segments.count == 2)
    let left: Expr = .singularQuery(segments: [.current, .child([.name("foo")])])
    let right: Expr = .literal(42)
    #expect(path.segments == [.root, .child([.filter(.comparison(left: left, operator: .gt, right: right))])])
  }

  @Test func filterCompGeSelector() throws {
    let path = try Path.parse("$[?@.foo >= 42]")
    try #require(path.segments.count == 2)
    let left: Expr = .singularQuery(segments: [.current, .child([.name("foo")])])
    let right: Expr = .literal(42)
    #expect(path.segments == [.root, .child([.filter(.comparison(left: left, operator: .ge, right: right))])])
  }

  @Test func filterLogOrSelector() throws {
    let path = try Path.parse("$[?@.foo || @.bar]")
    try #require(path.segments.count == 2)
    let left: Expr = .test(expression: .query(segments: [.current, .child([.name("foo")])]))
    let right: Expr = .test(expression: .query(segments: [.current, .child([.name("bar")])]))
    #expect(path.segments == [.root, .child([.filter(.logical(operator: .or, expressions: [left, right]))])])
  }

  @Test func filterLogAndSelector() throws {
    let path = try Path.parse("$[?@.foo && @.bar]")
    try #require(path.segments.count == 2)
    let left: Expr = .test(expression: .query(segments: [.current, .child([.name("foo")])]))
    let right: Expr = .test(expression: .query(segments: [.current, .child([.name("bar")])]))
    #expect(path.segments == [.root, .child([.filter(.logical(operator: .and, expressions: [left, right]))])])
  }

  @Test func filterLogNotSelector() throws {
    let path = try Path.parse("$[?!(1 == 2)]")
    try #require(path.segments.count == 2)
    let expr: Expr = .comparison(left: .literal(1), operator: .eq, right: .literal(2))
    #expect(path.segments == [.root, .child([.filter(.logical(operator: .not, expressions: [expr]))])])
  }

}

@Suite("Path Query Tests")
struct PathQueryTests {

  func check(
    _ path: String,
    _ value: Value,
    _ expected: PathQuery.Result,
    functions: [PathQuery.Function] = [],
    delegate: PathQuery.Delegate? = nil,
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column
  ) throws {
    let loc = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
    let path = try Path.parse(path)
    let result = PathQuery.query(path: path, from: value, functions: functions, delegate: delegate)
    #expect(result == expected, sourceLocation: loc)
  }

  @Test func rootIdentifier() throws {
    let value: Value = ["k": "v"]
    try check("$", value, .value(value: value, path: .root))
  }

  @Test func nameSelector() async throws {

    let value: Value = ["o": ["j j": ["k.k": 3]], "'": ["@": 2]]

    // RFC
    try check(#"$.o['j j']"#, value, .value(value: ["k.k": 3], path: .normal("o", "j j")))
    try check(#"$.o['j j']['k.k']"#, value, .value(3, path: .normal("o", "j j", "k.k")))
    try check(#"$.o["j j"]["k.k"]"#, value, .value(3, path: .normal("o", "j j", "k.k")))
    try check(#"$["'"]["@"]"#, value, .value(2, path: .normal("'", "@")))

    // Extra
    try check(#"$.p"#, value, .nothing)
    try check(#"$.o"#, 42, .nothing)
    try check(#"$['1']"#, ["a", "b"], .nothing)
  }

  @Test func wildcardSelector() throws {

    let value: Value = ["o": ["j": 1, "k": 2], "a": [5, 3]]

    // RFC
    try check(
      "$[*]",
      value,
      .nodelist([
        (["j": 1, "k": 2], path: .normal("o")),
        ([5, 3], path: .normal("a")),
      ])
    )
    try check(
      "$.o[*]",
      value,
      .nodelist([
        (1, path: .normal("o", "j")),
        (2, path: .normal("o", "k")),
      ])
    )
    try check(
      "$.o[*, *]",
      value,
      .nodelist([
        (1, path: .normal("o", "j")),
        (2, path: .normal("o", "k")),
        (1, path: .normal("o", "j")),
        (2, path: .normal("o", "k")),
      ])
    )
    try check(
      "$.a[*]",
      value,
      .nodelist([
        (5, path: .normal("a", 0)),
        (3, path: .normal("a", 1)),
      ])
    )

    // Extra
    try check("$.b[*]", value, .nothing)
  }

  @Test func indexSelector() throws {

    let value: Value = ["a", "b"]

    // RFC
    try check("$[1]", value, .value("b", path: .normal(1)))
    try check("$[-2]", value, .value("a", path: .normal(0)))

    // Extra
    try check("$[-3]", value, .nothing)
    try check("$[2]", value, .nothing)
    try check("$[0]", 42, .nothing)
    try check("$[0]", ["a": 1, "b": 2], .nothing)
  }

  @Test func sliceSelector() throws {

    let value: Value = ["a", "b", "c", "d", "e", "f", "g"]

    // RFC
    try check(
      "$[1:3]",
      value,
      .nodelist([
        ("b", path: .normal(1)),
        ("c", path: .normal(2)),
      ])
    )
    try check(
      "$[5:]",
      value,
      .nodelist([
        ("f", path: .normal(5)),
        ("g", path: .normal(6)),
      ])
    )
    try check(
      "$[1:5:2]",
      value,
      .nodelist([
        ("b", path: .normal(1)),
        ("d", path: .normal(3)),
      ])
    )
    try check(
      "$[5:1:-2]",
      value,
      .nodelist([
        ("f", path: .normal(5)),
        ("d", path: .normal(3)),
      ])
    )
    try check(
      "$[::-1]",
      value,
      .nodelist([
        ("g", path: .normal(6)),
        ("f", path: .normal(5)),
        ("e", path: .normal(4)),
        ("d", path: .normal(3)),
        ("c", path: .normal(2)),
        ("b", path: .normal(1)),
        ("a", path: .normal(0)),
      ])
    )

    // Extra
    try check("$[10:]", value, .empty)
    try check("$[:-10]", value, .empty)
    try check("$[0:0]", value, .empty)
    try check("$[0:1]", "test", .empty)
    try check("$[:3]", ["a": 1, "b": 2], .empty)
  }

  @Test func filterComparisons() throws {

    let obj: Value = ["x": "y"]
    let arr: Value = [2, 3]
    let objArr: Value = ["obj": obj, "arr": arr]
    let test: Value = ["test": true]

    let trueRes: PathQuery.Result = .nodelist([(true, path: .normal("test"))])
    let objArrRes: PathQuery.Result = .nodelist([(obj, path: .normal("obj")), (arr, path: .normal("arr"))])

    // RFC
    try check(#"$[?$.absent1 == $.absent2]"#, test, trueRes)
    try check(#"$[?$.absent1 <= $.absent2]"#, test, trueRes)
    try check(#"$[?$.absent1 == 'g']"#, test, .empty)
    try check(#"$[?$.absent1 != $.absent2]"#, test, .empty)
    try check(#"$[?$.absent1 != 'g']"#, test, trueRes)
    try check(#"$[?1 <= 2]"#, test, trueRes)
    try check(#"$[?1 > 2]"#, test, .empty)
    try check(#"$[?2 == '2']"#, test, .empty)
    try check(#"$[?'a' <= 'b']"#, test, trueRes)
    try check(#"$[?'a' > 'b']"#, test, .empty)
    try check(#"$[?$.obj == $.arr]"#, objArr, .empty)
    try check(#"$[?$.obj != $.arr]"#, objArr, objArrRes)
    try check(#"$[?$.obj == $.obj]"#, objArr, objArrRes)
    try check(#"$[?$.obj != $.obj]"#, objArr, .empty)
    try check(#"$[?$.arr == $.arr]"#, objArr, objArrRes)
    try check(#"$[?$.arr != $.arr]"#, objArr, .empty)
    try check(#"$[?$.obj == 17]"#, objArr, .empty)
    try check(#"$[?$.obj != 17]"#, objArr, objArrRes)
    try check(#"$[?$.obj <= $.arr]"#, objArr, .empty)
    try check(#"$[?$.obj < $.arr]"#, objArr, .empty)
    try check(#"$[?$.obj <= $.obj]"#, objArr, objArrRes)
    try check(#"$[?$.arr <= $.arr]"#, objArr, objArrRes)
    try check(#"$[?1 <= $.arr]"#, objArr, .empty)
    try check(#"$[?1 >= $.arr]"#, objArr, .empty)
    try check(#"$[?1 < $.arr]"#, objArr, .empty)
    try check(#"$[?1 > $.arr]"#, objArr, .empty)
    try check(#"$[?true <= true]"#, test, trueRes)
    try check(#"$[?true > true]"#, test, .empty)
  }

  @Test func filterSelector() throws {

    let value: Value = [
      "a": [3, 5, 1, 2, 4, 6, ["b": "j"], ["b": "k"], ["b": [:]], ["b": "kilo"]],
      "o": ["p": 1, "q": 2, "r": 3, "s": 5, "t": ["u": 6]],
      "e": "f",
    ]

    // RFC
    try check(
      #"$.a[?@.b == 'kilo']"#,
      value,
      .nodelist([
        (["b": "kilo"], path: .normal("a", 9))
      ])
    )
    try check(
      #"$.a[?(@.b == 'kilo')]"#,
      value,
      .nodelist([
        (["b": "kilo"], path: .normal("a", 9))
      ])
    )
    try check(
      #"$.a[?@>3.5]"#,
      value,
      .nodelist([
        (5, path: .normal("a", 1)),
        (4, path: .normal("a", 4)),
        (6, path: .normal("a", 5)),
      ])
    )
    try check(
      #"$.a[?@.b]"#,
      value,
      .nodelist([
        (["b": "j"], path: .normal("a", 6)),
        (["b": "k"], path: .normal("a", 7)),
        (["b": [:]], path: .normal("a", 8)),
        (["b": "kilo"], path: .normal("a", 9)),
      ])
    )
    try check(
      #"$[?@.*]"#,
      value,
      .nodelist([
        ([3, 5, 1, 2, 4, 6, ["b": "j"], ["b": "k"], ["b": [:]], ["b": "kilo"]], path: .normal("a")),
        (["p": 1, "q": 2, "r": 3, "s": 5, "t": ["u": 6]], path: .normal("o")),
      ])
    )
    try check(
      #"$[?@[?@.b]]"#,
      value,
      .nodelist([
        ([3, 5, 1, 2, 4, 6, ["b": "j"], ["b": "k"], ["b": [:]], ["b": "kilo"]], path: .normal("a"))
      ])
    )
    try check(
      #"$.o[?@<3, ?@<3]"#,
      value,
      .nodelist([
        (1, path: .normal("o", "p")),
        (2, path: .normal("o", "q")),
        (1, path: .normal("o", "p")),
        (2, path: .normal("o", "q")),
      ])
    )
    try check(
      #"$.a[?@<2 || @.b == "k"]"#,
      value,
      .nodelist([
        (1, path: .normal("a", 2)),
        (["b": "k"], path: .normal("a", 7)),
      ])
    )
    try check(
      #"$.a[?match(@.b, "[jk]")]"#,
      value,
      .nodelist([
        (["b": "j"], path: .normal("a", 6)),
        (["b": "k"], path: .normal("a", 7)),
      ])
    )
    try check(
      #"$.a[?search(@.b, "[jk]")]"#,
      value,
      .nodelist([
        (["b": "j"], path: .normal("a", 6)),
        (["b": "k"], path: .normal("a", 7)),
        (["b": "kilo"], path: .normal("a", 9)),
      ])
    )
    try check(
      #"$.o[?@>1 && @<4]"#,
      value,
      .nodelist([
        (2, path: .normal("o", "q")),
        (3, path: .normal("o", "r")),
      ])
    )
    try check(
      #"$.o[?@.u || @.x]"#,
      value,
      .nodelist([
        (["u": 6], path: .normal("o", "t"))
      ])
    )
    try check(
      #"$.a[?@.b == $.x]"#,
      value,
      .nodelist([
        (3, path: .normal("a", 0)),
        (5, path: .normal("a", 1)),
        (1, path: .normal("a", 2)),
        (2, path: .normal("a", 3)),
        (4, path: .normal("a", 4)),
        (6, path: .normal("a", 5)),
      ])
    )
    try check(
      #"$.a[?@ == @]"#,
      value,
      .nodelist([
        (3, path: .normal("a", 0)),
        (5, path: .normal("a", 1)),
        (1, path: .normal("a", 2)),
        (2, path: .normal("a", 3)),
        (4, path: .normal("a", 4)),
        (6, path: .normal("a", 5)),
        (["b": "j"], path: .normal("a", 6)),
        (["b": "k"], path: .normal("a", 7)),
        (["b": [:]], path: .normal("a", 8)),
        (["b": "kilo"], path: .normal("a", 9)),
      ])
    )
  }

  @Test func functions() throws {

    class Delegate: PathQuery.Delegate {

      var argumentMismatchCount = 0

      func functionArgumentTypeMismatch(
        function: PathQuery.Function,
        argumentIndex: Int,
        expectedType: PathQuery.Function.ArgumentType,
        actual: PathQuery.Function.Argument
      ) {
        argumentMismatchCount += 1
      }
    }

    let delegate = Delegate()

    // RFC
    try check(#"$[?length(@) < 3]"#, [[1, 2]], .nodelist([([1, 2], path: .normal(0))]))
    try check(#"$[?length(@.*) < 3]"#, [[1, 2]], .empty, delegate: delegate)
    try check(#"$[?count(@.*) == 1]"#, [[1]], .nodelist([([1], path: .normal(0))]))
    try check(#"$[?count(1) == 1]"#, [[1, 2]], .empty, delegate: delegate)

    try #require(delegate.argumentMismatchCount == 2)
  }

  @Test func customFunctions() throws {

    try check(#"$[?key(@) == "a"]"#, ["a": 0, "b": 1], .nodelist([(value: 0, path: .normal("a"))]))
    try check(#"$[?match(key(@), "a")]"#, ["a": 0], .nodelist([(value: 0, path: .normal("a"))]))
    try check(
      #"$['b', ?key(@) == "a"]"#,
      ["a": 0, "b": 1],
      .nodelist([
        (value: 1, path: .normal("b")),
        (value: 0, path: .normal("a")),
      ])
    )
    try check(
      #"$[?test(@) == 1]"#,
      [1],
      .nodelist([(1, path: .normal(0))]),
      functions: [
        PathQuery.function(name: "test", arguments: .value) { _ in .value(1, path: .empty) }
      ]
    )
  }

  @Test func childSegment() throws {

    let value: Value = ["a", "b", "c", "d", "e", "f", "g"]

    // RFC
    try check(
      #"$[0, 3]"#,
      value,
      .nodelist([
        ("a", path: .normal(0)),
        ("d", path: .normal(3)),
      ])
    )
    try check(
      #"$[0:2, 5]"#,
      value,
      .nodelist([
        ("a", path: .normal(0)),
        ("b", path: .normal(1)),
        ("f", path: .normal(5)),
      ])
    )
    try check(
      #"$[0, 0]"#,
      value,
      .nodelist([
        ("a", path: .normal(0)),
        ("a", path: .normal(0)),
      ])
    )
  }

  @Test func descendantSegment() async throws {

    let value: Value = [
      "o": ["j": 1, "k": 2],
      "a": [5, 3, [["j": 4], ["k": 6]]],
    ]

    // RFC
    try check(
      #"$..j"#,
      value,
      .nodelist([
        (1, path: .normal("o", "j")),
        (4, path: .normal("a", 2, 0, "j")),
      ])
    )
    try check(
      #"$..[0]"#,
      value,
      .nodelist([
        (5, path: .normal("a", 0)),
        (["j": 4], path: .normal("a", 2, 0)),
      ])
    )
    try check(
      #"$..*"#,
      value,
      .nodelist([
        (["j": 1, "k": 2], path: .normal("o")),
        ([5, 3, [["j": 4], ["k": 6]]], path: .normal("a")),
        (1, path: .normal("o", "j")),
        (2, path: .normal("o", "k")),
        (5, path: .normal("a", 0)),
        (3, path: .normal("a", 1)),
        ([["j": 4], ["k": 6]], path: .normal("a", 2)),
        (["j": 4], path: .normal("a", 2, 0)),
        (["k": 6], path: .normal("a", 2, 1)),
        (4, path: .normal("a", 2, 0, "j")),
        (6, path: .normal("a", 2, 1, "k")),
      ])
    )
    try check(
      #"$..o"#,
      value,
      .nodelist([
        (["j": 1, "k": 2], path: .normal("o"))
      ])
    )
    try check(
      #"$.o..[*, *]"#,
      value,
      .nodelist([
        (1, path: .normal("o", "j")),
        (2, path: .normal("o", "k")),
        (1, path: .normal("o", "j")),
        (2, path: .normal("o", "k")),
      ])
    )
    try check(
      #"$.a..[0, 1]"#,
      value,
      .nodelist([
        (5, path: .normal("a", 0)),
        (3, path: .normal("a", 1)),
        (["j": 4], path: .normal("a", 2, 0)),
        (["k": 6], path: .normal("a", 2, 1)),
      ])
    )
  }

  @Test func null() throws {

    let value: Value = ["a": .null, "b": [.null], "c": [[:]], "null": 1]

    // RFC
    try check(#"$.a"#, value, .value(.null, path: .normal("a")))
    try check(#"$.a[0]"#, value, .nothing)
    try check(#"$.a.d"#, value, .nothing)
    try check(#"$.b[0]"#, value, .value(.null, path: .normal("b", 0)))
    try check(#"$.b[*]"#, value, .nodelist([(.null, path: .normal("b", 0))]))
    try check(#"$.b[?@]"#, value, .nodelist([(.null, path: .normal("b", 0))]))
    try check(#"$.b[?@==null]"#, value, .nodelist([(.null, path: .normal("b", 0))]))
    try check(#"$.c[?@.d==null]"#, value, .nodelist([]))
    try check(#"$.null"#, value, .value(1, path: .normal("null")))
  }

}
