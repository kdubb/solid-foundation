//
//  PathTests.swift
//  Codex
//
//  Created by Kevin Wooten on 1/31/25.
//

import Testing
@testable import Codex

struct PathParseTests {

  typealias Seg = Path.Segment
  typealias Sel = Path.Selector
  typealias Expr = Path.Selector.Expression

  @Test func rootSelector() throws {
    let path = try Path.parse("$")
    try #require(path.segments.isEmpty)
  }

  @Test func childMemberSelector() throws {
    let path = try Path.parse("$.foo")
    try #require(path.segments.count == 1)
    #expect(path.segments[0] == .child([.name("foo")]))
  }

  @Test func childWildcardSelector() throws {
    let path = try Path.parse("$.*")
    try #require(path.segments.count == 1)
    #expect(path.segments[0] == .child([.wildcard]))
  }

  @Test func childIndexSelector() throws {
    let path = try Path.parse("$[0]")
    try #require(path.segments.count == 1)
    #expect(path.segments[0] == .child([.index(0)]))
  }

  @Test func filterCompEqSelector() throws {
    let path = try Path.parse("$[?@.foo == 42]")
    try #require(path.segments.count == 1)
    let left: Expr = .singularQuery(segments: [.child([.name("foo")])], type: .relative)
    let right: Expr = .literal(42)
    #expect(path.segments[0] == .child([.filter(.comparison(left: left, operator: .eq, right: right))]))
  }

  @Test func filterCompNeSelector() throws {
    let path = try Path.parse("$[?@.foo != 42]")
    try #require(path.segments.count == 1)
    let left: Expr = .singularQuery(segments: [.child([.name("foo")])], type: .relative)
    let right: Expr = .literal(42)
    #expect(path.segments[0] == .child([.filter(.comparison(left: left, operator: .ne, right: right))]))
  }

  @Test func filterCompLtSelector() throws {
    let path = try Path.parse("$[?@.foo < 42]")
    try #require(path.segments.count == 1)
    let left: Expr = .singularQuery(segments: [.child([.name("foo")])], type: .relative)
    let right: Expr = .literal(42)
    #expect(path.segments[0] == .child([.filter(.comparison(left: left, operator: .lt, right: right))]))
  }

  @Test func filterCompLeSelector() throws {
    let path = try Path.parse("$[?@.foo <= 42]")
    try #require(path.segments.count == 1)
    let left: Expr = .singularQuery(segments: [.child([.name("foo")])], type: .relative)
    let right: Expr = .literal(42)
    #expect(path.segments[0] == .child([.filter(.comparison(left: left, operator: .le, right: right))]))
  }

  @Test func filterCompGtSelector() throws {
    let path = try Path.parse("$[?@.foo > 42]")
    try #require(path.segments.count == 1)
    let left: Expr = .singularQuery(segments: [.child([.name("foo")])], type: .relative)
    let right: Expr = .literal(42)
    #expect(path.segments[0] == .child([.filter(.comparison(left: left, operator: .gt, right: right))]))
  }

  @Test func filterCompGeSelector() throws {
    let path = try Path.parse("$[?@.foo >= 42]")
    try #require(path.segments.count == 1)
    let left: Expr = .singularQuery(segments: [.child([.name("foo")])], type: .relative)
    let right: Expr = .literal(42)
    #expect(path.segments[0] == .child([.filter(.comparison(left: left, operator: .ge, right: right))]))
  }

  @Test func filterLogOrSelector() throws {
    let path = try Path.parse("$[?@.foo || @.bar]")
    try #require(path.segments.count == 1)
    let left: Expr = .test(expression: .query(segments: [.child([.name("foo")])], type: .relative))
    let right: Expr = .test(expression: .query(segments: [.child([.name("bar")])], type: .relative))
    #expect(path.segments[0] == .child([.filter(.logical(operator: .or, expressions: [left, right]))]))
  }

  @Test func filterLogAndSelector() throws {
    let path = try Path.parse("$[?@.foo && @.bar]")
    try #require(path.segments.count == 1)
    let left: Expr = .test(expression: .query(segments: [.child([.name("foo")])], type: .relative))
    let right: Expr = .test(expression: .query(segments: [.child([.name("bar")])], type: .relative))
    #expect(path.segments[0] == .child([.filter(.logical(operator: .and, expressions: [left, right]))]))
  }

  @Test func filterLogNotSelector() throws {
    let path = try Path.parse("$[?!(1 == 2)]")
    try #require(path.segments.count == 1)
    let expr: Expr = .comparison(left: .literal(1), operator: .eq, right: .literal(2))
    #expect(path.segments[0] == .child([.filter(.logical(operator: .not, expressions: [expr]))]))
  }

}


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
    let path = try #require(try Path.parse(path), sourceLocation: loc)
    let result = try #require(
      PathQuery.query(path: path, from: value, functions: functions, delegate: delegate),
      sourceLocation: loc
    )
    #expect(result == expected, sourceLocation: loc)
  }

  @Test func rootIdentifier() throws {
    let value: Value = ["k": "v"]
    try check("$", value, .value(value))
  }

  @Test func nameSelector() async throws {

    let value: Value = ["o": ["j j": ["k.k": 3]], "'": ["@": 2]]

    // RFC
    try check(#"$.o['j j']"#, value, .value(["k.k": 3]))
    try check(#"$.o['j j']['k.k']"#, value, .value(3))
    try check(#"$.o["j j"]["k.k"]"#, value, .value(3))
    try check(#"$["'"]["@"]"#, value, .value(2))

    // Extra
    try check(#"$.p"#, value, .nothing)
    try check(#"$.o"#, 42, .nothing)
    try check(#"$['1']"#, ["a", "b"], .nothing)
  }

  @Test func wildcardSelector() throws {

    let value: Value = ["o": ["j" : 1, "k": 2], "a": [5, 3]]

    // RFC
    try check("$[*]", value, .nodelist([["j" : 1, "k": 2], [5, 3]]))
    try check("$.o[*]", value, .nodelist([1, 2]))
    try check("$.o[*, *]", value, .nodelist([1, 2, 1, 2]))
    try check("$.a[*]", value, .nodelist([5, 3]))

    // Extra
    try check("$.b[*]", value, .nothing)
  }

  @Test func indexSelector() throws {

    let value: Value = ["a", "b"]

    // RFC
    try check("$[1]", value, .value("b"))
    try check("$[-2]", value, .value("a"))

    // Extra
    try check("$[-3]", value, .nothing)
    try check("$[2]", value, .nothing)
    try check("$[0]", 42, .nothing)
    try check("$[0]", ["a": 1, "b": 2], .nothing)
  }

  @Test func sliceSelector() throws {

    let value: Value = ["a", "b", "c", "d", "e", "f", "g"]

    // RFC
    try check("$[1:3]", value, .nodelist(["b", "c"]))
    try check("$[5:]", value, .nodelist(["f", "g"]))
    try check("$[1:5:2]", value, .nodelist(["b", "d"]))
    try check("$[5:1:-2]", value, .nodelist(["f", "d"]))
    try check("$[::-1]", value, .nodelist(["g", "f", "e", "d", "c", "b", "a"]))

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

    // RFC
    try check(#"$[?$.absent1 == $.absent2]"#, test, .nodelist([true]))
    try check(#"$[?$.absent1 <= $.absent2]"#, test, .nodelist([true]))
    try check(#"$[?$.absent1 == 'g']"#, test, .empty)
    try check(#"$[?$.absent1 != $.absent2]"#, test, .empty)
    try check(#"$[?$.absent1 != 'g']"#, test, .nodelist([true]))
    try check(#"$[?1 <= 2]"#, test, .nodelist([true]))
    try check(#"$[?1 > 2]"#, test, .empty)
    try check(#"$[?2 == '2']"#, test, .empty)
    try check(#"$[?'a' <= 'b']"#, test, .nodelist([true]))
    try check(#"$[?'a' > 'b']"#, test, .empty)
    try check(#"$[?$.obj == $.arr]"#, objArr, .empty)
    try check(#"$[?$.obj != $.arr]"#, objArr, .nodelist([obj, arr]))
    try check(#"$[?$.obj == $.obj]"#, objArr, .nodelist([obj, arr]))
    try check(#"$[?$.obj != $.obj]"#, objArr, .empty)
    try check(#"$[?$.arr == $.arr]"#, objArr, .nodelist([obj, arr]))
    try check(#"$[?$.arr != $.arr]"#, objArr, .empty)
    try check(#"$[?$.obj == 17]"#, objArr, .empty)
    try check(#"$[?$.obj != 17]"#, objArr, .nodelist([obj, arr]))
    try check(#"$[?$.obj <= $.arr]"#, objArr, .empty)
    try check(#"$[?$.obj < $.arr]"#, objArr, .empty)
    try check(#"$[?$.obj <= $.obj]"#, objArr, .nodelist([obj, arr]))
    try check(#"$[?$.arr <= $.arr]"#, objArr, .nodelist([obj, arr]))
    try check(#"$[?1 <= $.arr]"#, objArr, .empty)
    try check(#"$[?1 >= $.arr]"#, objArr, .empty)
    try check(#"$[?1 < $.arr]"#, objArr, .empty)
    try check(#"$[?1 > $.arr]"#, objArr, .empty)
    try check(#"$[?true <= true]"#, test, .nodelist([true]))
    try check(#"$[?true > true]"#, test, .empty)
  }

  @Test func filterSelector() throws {

    let value: Value = [
      "a": [3, 5, 1, 2, 4 , 6, ["b": "j"], ["b": "k"], ["b": [:]], ["b": "kilo"]],
      "o": ["p": 1, "q": 2, "r": 3, "s": 5, "t": ["u": 6]],
      "e": "f",
    ]

    // RFC
    try check(#"$.a[?@.b == 'kilo']"#, value, .nodelist([["b": "kilo"]]))
    try check(#"$.a[?(@.b == 'kilo')]"#, value, .nodelist([["b": "kilo"]]))
    try check(#"$.a[?@>3.5]"#, value, .nodelist([5, 4, 6]))
    try check(#"$.a[?@.b]"#, value, .nodelist([["b": "j"], ["b": "k"], ["b": [:]], ["b": "kilo"]]))
    try check(#"$[?@.*]"#, value, .nodelist([[3, 5, 1, 2, 4, 6, ["b": "j"], ["b": "k"], ["b": [:]], ["b": "kilo"]],
                                             ["p": 1, "q": 2, "r": 3, "s": 5, "t": ["u": 6]]]))
    try check(#"$[?@[?@.b]]"#, value, .nodelist([[3, 5, 1, 2, 4, 6, ["b": "j"], ["b": "k"], ["b": [:]], ["b": "kilo"]]]))
    try check(#"$.o[?@<3, ?@<3]"#, value, .nodelist([1, 2, 1, 2]))
    try check(#"$.a[?@<2 || @.b == "k"]"#, value, .nodelist([1, ["b": "k"]]))
    try check(#"$.a[?match(@.b, "[jk]")]"#, value, .nodelist([["b": "j"], ["b": "k"]]))
    try check(#"$.a[?search(@.b, "[jk]")]"#, value, .nodelist([["b": "j"], ["b": "k"], ["b": "kilo"]]))
    try check(#"$.o[?@>1 && @<4]"#, value, .nodelist([2, 3]))
    try check(#"$.o[?@.u || @.x]"#, value, .nodelist([["u": 6]]))
    try check(#"$.a[?@.b == $.x]"#, value, .nodelist([3, 5, 1, 2, 4, 6]))
    try check(#"$.a[?@ == @]"#, value, .nodelist([3, 5, 1, 2, 4, 6, ["b": "j"], ["b": "k"], ["b": [:]], ["b": "kilo"]]))
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
    try check(#"$[?length(@) < 3]"#, [[1, 2]], .nodelist([[1, 2]]))
    try check(#"$[?length(@.*) < 3]"#, [[1, 2]], .empty, delegate: delegate)
    try check(#"$[?count(@.*) == 1]"#, [[1]], .nodelist([[1]]))
    try check(#"$[?count(1) == 1]"#, [[1, 2]], .empty, delegate: delegate)

    try #require(delegate.argumentMismatchCount == 2)
  }

  @Test func customFunction() throws {

    try check(#"$[?test(@) == 1]"#, [1], .nodelist([1]), functions: [
      PathQuery.function(name: "test", arguments: .value) { _ in .value(1) }
    ])
  }

  @Test func childSegment() throws {

    let value: Value = ["a", "b", "c", "d", "e", "f", "g"]

    // RFC
    try check(#"$[0, 3]"#, value, .nodelist(["a", "d"]))
    try check(#"$[0:2, 5]"#, value, .nodelist(["a", "b", "f"]))
    try check(#"$[0, 0]"#, value, .nodelist(["a", "a"]))
  }

  @Test func descendantSegment() async throws {

    let value: Value = [
      "o": ["j" : 1, "k": 2],
      "a": [5, 3, [["j" : 4], ["k": 6]]],
    ]

    // RFC
    try check(#"$..j"#, value, .nodelist([1, 4]))
    try check(#"$..[0]"#, value, .nodelist([5, ["j": 4]]))
    try check(#"$..*"#, value, .nodelist([
      ["j" : 1, "k": 2],
      [5, 3, [["j" : 4], ["k": 6]]],
      1,
      2,
      5,
      3,
      [["j": 4], ["k": 6]],
      ["j": 4],
      ["k": 6],
      4,
      6
    ]))
    try check(#"$..o"#, value, .nodelist([["j" : 1, "k": 2]]))
    try check(#"$.o..[*, *]"#, value, .nodelist([1, 2, 1, 2]))
    try check(#"$.a..[0, 1]"#, value, .nodelist([5, 3, ["j": 4], ["k": 6]]))
  }

  @Test func null() throws {

    let value: Value = ["a": .null, "b": [.null], "c": [[:]], "null": 1]

    // RFC
    try check(#"$.a"#, value, .value(.null))
    try check(#"$.a[0]"#, value, .nothing)
    try check(#"$.a.d"#, value, .nothing)
    try check(#"$.b[0]"#, value, .value(.null))
    try check(#"$.b[*]"#, value, .nodelist([.null]))
    try check(#"$.b[?@]"#, value, .nodelist([.null]))
    try check(#"$.b[?@==null]"#, value, .nodelist([.null]))
    try check(#"$.c[?@.d==null]"#, value, .nodelist([]))
    try check(#"$.null"#, value, .value(1))
  }

}

