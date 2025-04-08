import Testing
@testable import Codex

extension PathTests {

  @Suite("Query")
  struct PathQueryTests {

    func check(
      _ string: String,
      _ value: Value,
      _ expectedTmp: [(value: Value, path: Path)],
      functions: [Path.Function] = [],
      delegate: Path.Query.Delegate? = nil,
      sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
      let path: Path
      do {
        path = try Path.parse(string: string, options: [.captureParentheses])
      } catch {
        Issue.record(error, "Failed to parse path: \(string)", sourceLocation: sourceLocation)
        return
      }
      if path.description != string {
        Issue.record("Path description mismatch: \(path.description) != \(string)", sourceLocation: sourceLocation)
      }
      let result = Path.Query.evaluate(path: path, against: value, functions: functions, delegate: delegate)
      let expected = Path.Query.NodeList(expectedTmp.map { .node($0.0, $0.1) })
      #expect(result == expected, sourceLocation: sourceLocation)
    }

    @Test func rootIdentifier() throws {
      let value: Value = ["k": "v"]
      try check("$", value, [(value: value, path: .root)])
    }

    @Test func nameSelector() async throws {

      let value: Value = ["o": ["j j": ["k.k": 3]], "'": ["@": 2]]

      // RFC
      try check(#"$.o['j j']"#, value, [(value: ["k.k": 3], path: .normal("o", "j j"))])
      try check(#"$.o['j j']['k.k']"#, value, [(3, path: .normal("o", "j j", "k.k"))])
      try check(#"$.o["j j"]["k.k"]"#, value, [(3, path: .normal("o", "j j", "k.k"))])
      try check(#"$["'"]["@"]"#, value, [(2, path: .normal("'", "@"))])

      // Extra
      try check(#"$.p"#, value, [])
      try check(#"$.o"#, 42, [])
      try check(#"$['1']"#, ["a", "b"], [])
    }

    @Test func wildcardSelector() throws {

      let value: Value = ["o": ["j": 1, "k": 2], "a": [5, 3]]

      // RFC
      try check(
        "$[*]",
        value,
        [
          (["j": 1, "k": 2], path: .normal("o")),
          ([5, 3], path: .normal("a")),
        ]
      )
      try check(
        "$.o[*]",
        value,
        [
          (1, path: .normal("o", "j")),
          (2, path: .normal("o", "k")),
        ]
      )
      try check(
        "$.o[*, *]",
        value,
        [
          (1, path: .normal("o", "j")),
          (2, path: .normal("o", "k")),
          (1, path: .normal("o", "j")),
          (2, path: .normal("o", "k")),
        ]
      )
      try check(
        "$.a[*]",
        value,
        [
          (5, path: .normal("a", 0)),
          (3, path: .normal("a", 1)),
        ]
      )

      // Extra
      try check("$.b[*]", value, [])
    }

    @Test func indexSelector() throws {

      let value: Value = ["a", "b"]

      // RFC
      try check("$[1]", value, [("b", path: .normal(1))])
      try check("$[-2]", value, [("a", path: .normal(0))])

      // Extra
      try check("$[-3]", value, [])
      try check("$[2]", value, [])
      try check("$[0]", 42, [])
      try check("$[0]", ["a": 1, "b": 2], [])
    }

    @Test func sliceSelector() throws {

      let value: Value = ["a", "b", "c", "d", "e", "f", "g"]

      // RFC
      try check(
        "$[1:3]",
        value,
        [
          ("b", path: .normal(1)),
          ("c", path: .normal(2)),
        ]
      )
      try check(
        "$[5:]",
        value,
        [
          ("f", path: .normal(5)),
          ("g", path: .normal(6)),
        ]
      )
      try check(
        "$[1:5:2]",
        value,
        [
          ("b", path: .normal(1)),
          ("d", path: .normal(3)),
        ]
      )
      try check(
        "$[5:1:-2]",
        value,
        [
          ("f", path: .normal(5)),
          ("d", path: .normal(3)),
        ]
      )
      try check(
        "$[::-1]",
        value,
        [
          ("g", path: .normal(6)),
          ("f", path: .normal(5)),
          ("e", path: .normal(4)),
          ("d", path: .normal(3)),
          ("c", path: .normal(2)),
          ("b", path: .normal(1)),
          ("a", path: .normal(0)),
        ]
      )

      // Extra
      try check("$[10:]", value, [])
      try check("$[:-10]", value, [])
      try check("$[0:0]", value, [])
      try check("$[0:1]", "test", [])
      try check("$[:3]", ["a": 1, "b": 2], [])
    }

    @Test func filterComparisons() throws {

      let obj: Value = ["x": "y"]
      let arr: Value = [2, 3]
      let objArr: Value = ["obj": obj, "arr": arr]
      let test: Value = ["test": true]

      let trueRes: [(Value, Path)] = [(true, .normal("test"))]
      let objArrRes: [(Value, Path)] = [(obj, .normal("obj")), (arr, .normal("arr"))]

      // RFC
      try check(#"$[?$.absent1 == $.absent2]"#, test, trueRes)
      try check(#"$[?$.absent1 <= $.absent2]"#, test, trueRes)
      try check(#"$[?$.absent1 == 'g']"#, test, [])
      try check(#"$[?$.absent1 != $.absent2]"#, test, [])
      try check(#"$[?$.absent1 != 'g']"#, test, trueRes)
      try check(#"$[?1 <= 2]"#, test, trueRes)
      try check(#"$[?1 > 2]"#, test, [])
      try check(#"$[?2 == '2']"#, test, [])
      try check(#"$[?'a' <= 'b']"#, test, trueRes)
      try check(#"$[?'a' > 'b']"#, test, [])
      try check(#"$[?$.obj == $.arr]"#, objArr, [])
      try check(#"$[?$.obj != $.arr]"#, objArr, objArrRes)
      try check(#"$[?$.obj == $.obj]"#, objArr, objArrRes)
      try check(#"$[?$.obj != $.obj]"#, objArr, [])
      try check(#"$[?$.arr == $.arr]"#, objArr, objArrRes)
      try check(#"$[?$.arr != $.arr]"#, objArr, [])
      try check(#"$[?$.obj == 17]"#, objArr, [])
      try check(#"$[?$.obj != 17]"#, objArr, objArrRes)
      try check(#"$[?$.obj <= $.arr]"#, objArr, [])
      try check(#"$[?$.obj < $.arr]"#, objArr, [])
      try check(#"$[?$.obj <= $.obj]"#, objArr, objArrRes)
      try check(#"$[?$.arr <= $.arr]"#, objArr, objArrRes)
      try check(#"$[?1 <= $.arr]"#, objArr, [])
      try check(#"$[?1 >= $.arr]"#, objArr, [])
      try check(#"$[?1 < $.arr]"#, objArr, [])
      try check(#"$[?1 > $.arr]"#, objArr, [])
      try check(#"$[?true <= true]"#, test, trueRes)
      try check(#"$[?true > true]"#, test, [])
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
        [
          (["b": "kilo"], path: .normal("a", 9))
        ]
      )
      try check(
        #"$.a[?(@.b == 'kilo')]"#,
        value,
        [
          (["b": "kilo"], path: .normal("a", 9))
        ]
      )
      try check(
        #"$.a[?@ > 3.5]"#,
        value,
        [
          (5, path: .normal("a", 1)),
          (4, path: .normal("a", 4)),
          (6, path: .normal("a", 5)),
        ]
      )
      try check(
        #"$.a[?@.b]"#,
        value,
        [
          (["b": "j"], path: .normal("a", 6)),
          (["b": "k"], path: .normal("a", 7)),
          (["b": [:]], path: .normal("a", 8)),
          (["b": "kilo"], path: .normal("a", 9)),
        ]
      )
      try check(
        #"$[?@.*]"#,
        value,
        [
          ([3, 5, 1, 2, 4, 6, ["b": "j"], ["b": "k"], ["b": [:]], ["b": "kilo"]], path: .normal("a")),
          (["p": 1, "q": 2, "r": 3, "s": 5, "t": ["u": 6]], path: .normal("o")),
        ]
      )
      try check(
        #"$[?@[?@.b]]"#,
        value,
        [
          ([3, 5, 1, 2, 4, 6, ["b": "j"], ["b": "k"], ["b": [:]], ["b": "kilo"]], path: .normal("a"))
        ]
      )
      try check(
        #"$.o[?@ < 3, ?@ < 3]"#,
        value,
        [
          (1, path: .normal("o", "p")),
          (2, path: .normal("o", "q")),
          (1, path: .normal("o", "p")),
          (2, path: .normal("o", "q")),
        ]
      )
      try check(
        #"$.a[?@ < 2 || @.b == "k"]"#,
        value,
        [
          (1, path: .normal("a", 2)),
          (["b": "k"], path: .normal("a", 7)),
        ]
      )
      try check(
        #"$.a[?match(@.b, "[jk]")]"#,
        value,
        [
          (["b": "j"], path: .normal("a", 6)),
          (["b": "k"], path: .normal("a", 7)),
        ]
      )
      try check(
        #"$.a[?search(@.b, "[jk]")]"#,
        value,
        [
          (["b": "j"], path: .normal("a", 6)),
          (["b": "k"], path: .normal("a", 7)),
          (["b": "kilo"], path: .normal("a", 9)),
        ]
      )
      try check(
        #"$.o[?@ > 1 && @ < 4]"#,
        value,
        [
          (2, path: .normal("o", "q")),
          (3, path: .normal("o", "r")),
        ]
      )
      try check(
        #"$.o[?@.u || @.x]"#,
        value,
        [
          (["u": 6], path: .normal("o", "t"))
        ]
      )
      try check(
        #"$.a[?@.b == $.x]"#,
        value,
        [
          (3, path: .normal("a", 0)),
          (5, path: .normal("a", 1)),
          (1, path: .normal("a", 2)),
          (2, path: .normal("a", 3)),
          (4, path: .normal("a", 4)),
          (6, path: .normal("a", 5)),
        ]
      )
      try check(
        #"$.a[?@ == @]"#,
        value,
        [
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
        ]
      )
    }

    @Test func functions() throws {

      class Delegate: Path.Query.Delegate {

        var argumentMismatchCount = 0

        func functionArgumentTypeMismatch(
          function: Path.Function,
          argumentIndex: Int,
          expectedType: Path.Function.ArgumentType,
          actual: Path.Function.Argument
        ) {
          argumentMismatchCount += 1
        }
      }

      let delegate = Delegate()

      // RFC
      try check(#"$[?length(@) < 3]"#, [[1, 2]], [([1, 2], .normal(0))])
      try check(#"$[?length(@.*) < 3]"#, [[1, 2]], [], delegate: delegate)
      try check(#"$[?count(@.*) == 1]"#, [[1]], [([1], .normal(0))])
      try check(#"$[?count(1) == 1]"#, [[1, 2]], [], delegate: delegate)

      try #require(delegate.argumentMismatchCount == 2)
    }

    @Test func customFunctions() throws {

      try check(#"$[?key(@) == "a"]"#, ["a": 0, "b": 1], [(value: 0, path: .normal("a"))])
      try check(#"$[?match(key(@), "a")]"#, ["a": 0], [(value: 0, path: .normal("a"))])
      try check(
        #"$['b', ?key(@) == "a"]"#,
        ["a": 0, "b": 1],
        [
          (value: 1, path: .normal("b")),
          (value: 0, path: .normal("a")),
        ]
      )
      try check(
        #"$[?test(@) == 1]"#,
        [1],
        [(1, path: .normal(0))],
        functions: [
          Path.function(name: "test", arguments: .value, result: .value) { _ in .value(1, path: nil) }
        ]
      )
    }

    @Test func childSegment() throws {

      let value: Value = ["a", "b", "c", "d", "e", "f", "g"]

      // RFC
      try check(
        #"$[0, 3]"#,
        value,
        [
          ("a", path: .normal(0)),
          ("d", path: .normal(3)),
        ]
      )
      try check(
        #"$[0:2, 5]"#,
        value,
        [
          ("a", path: .normal(0)),
          ("b", path: .normal(1)),
          ("f", path: .normal(5)),
        ]
      )
      try check(
        #"$[0, 0]"#,
        value,
        [
          ("a", path: .normal(0)),
          ("a", path: .normal(0)),
        ]
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
        [
          (1, path: .normal("o", "j")),
          (4, path: .normal("a", 2, 0, "j")),
        ]
      )
      try check(
        #"$..[0]"#,
        value,
        [
          (5, path: .normal("a", 0)),
          (["j": 4], path: .normal("a", 2, 0)),
        ]
      )
      try check(
        #"$..*"#,
        value,
        [
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
        ]
      )
      try check(
        #"$..o"#,
        value,
        [
          (["j": 1, "k": 2], path: .normal("o"))
        ]
      )
      try check(
        #"$.o..[*, *]"#,
        value,
        [
          (1, path: .normal("o", "j")),
          (2, path: .normal("o", "k")),
          (1, path: .normal("o", "j")),
          (2, path: .normal("o", "k")),
        ]
      )
      try check(
        #"$.a..[0, 1]"#,
        value,
        [
          (5, path: .normal("a", 0)),
          (3, path: .normal("a", 1)),
          (["j": 4], path: .normal("a", 2, 0)),
          (["k": 6], path: .normal("a", 2, 1)),
        ]
      )
    }

    @Test func null() throws {

      let value: Value = ["a": .null, "b": [.null], "c": [[:]], "null": 1]

      // RFC
      try check(#"$.a"#, value, [(.null, path: .normal("a"))])
      try check(#"$.a[0]"#, value, [])
      try check(#"$.a.d"#, value, [])
      try check(#"$.b[0]"#, value, [(.null, path: .normal("b", 0))])
      try check(#"$.b[*]"#, value, [(.null, path: .normal("b", 0))])
      try check(#"$.b[?@]"#, value, [(.null, path: .normal("b", 0))])
      try check(#"$.b[?@ == null]"#, value, [(.null, path: .normal("b", 0))])
      try check(#"$.c[?@.d == null]"#, value, [])
      try check(#"$.null"#, value, [(1, path: .normal("null"))])
    }

  }

}
