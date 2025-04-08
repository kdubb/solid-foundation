import Testing
@testable import Codex

extension PathTests {

  @Suite("Parser")
  struct Parser {

    typealias Seg = Path.Segment
    typealias Sel = Path.Selector
    typealias Expr = Path.Selector.Expression

    @Test func rootSelector() throws {
      let path = try Path.parse(string: "$")
      print(path)
      #expect(path.initialNode == .root)
      #expect(path.segments == [])
    }

    @Test func childMemberSelector() throws {
      let path = try Path.parse(string: "$.foo")
      #expect(path.initialNode == .root)
      #expect(path.segments == [.child([.name("foo")])])
    }

    @Test func childWildcardSelector() throws {
      let path = try Path.parse(string: "$.*")
      #expect(path.initialNode == .root)
      #expect(path.segments == [.child([.wildcard])])
    }

    @Test func childIndexSelector() throws {
      let path = try Path.parse(string: "$[0]")
      #expect(path.initialNode == .root)
      #expect(path.segments == [.child([.index(0)])])
    }

    @Test func childSliceSelector() throws {
      let path = try Path.parse(string: "$[:]")
      #expect(path.initialNode == .root)
      #expect(path.segments == [.child([.slice(.init(start: nil, end: nil, step: nil))])])
    }

    @Test func childSliceSelectorWithStart() throws {
      let path = try Path.parse(string: "$[1:]")
      #expect(path.initialNode == .root)
      #expect(path.segments == [.child([.slice(.init(start: 1, end: nil, step: nil))])])
    }

    @Test func childSliceSelectorWithEnd() throws {
      let path = try Path.parse(string: "$[:2]")
      #expect(path.initialNode == .root)
      #expect(path.segments == [.child([.slice(.init(start: nil, end: 2, step: nil))])])
    }

    @Test func childSliceSelectorWithStartAndEnd() throws {
      let path = try Path.parse(string: "$[1:2]")
      #expect(path.initialNode == .root)
      #expect(path.segments == [.child([.slice(.init(start: 1, end: 2, step: nil))])])
    }

    @Test func childSliceSelectorWithStep() throws {
      let path = try Path.parse(string: "$[::2]")
      #expect(path.initialNode == .root)
      #expect(path.segments == [.child([.slice(.init(start: nil, end: nil, step: 2))])])
    }

    @Test func childSliceSelectorWithStartAndStep() throws {
      let path = try Path.parse(string: "$[1::2]")
      #expect(path.initialNode == .root)
      #expect(path.segments == [.child([.slice(.init(start: 1, end: nil, step: 2))])])
    }

    @Test func childSliceSelectorWithEndAndStep() throws {
      let path = try Path.parse(string: "$[:2:2]")
      #expect(path.initialNode == .root)
      #expect(path.segments == [.child([.slice(.init(start: nil, end: 2, step: 2))])])
    }

    @Test func childSliceSelectorWithStartEndAndStep() throws {
      let path = try Path.parse(string: "$[1:2:2]")
      #expect(path.initialNode == .root)
      #expect(path.segments == [.child([.slice(.init(start: 1, end: 2, step: 2))])])
    }

    @Test func filterCompEqSelector() throws {
      let path = try Path.parse(string: "$[?@.foo == 42]")
      #expect(path.initialNode == .root)
      let left: Expr = .singularQuery(node: .current, segments: [.child([.name("foo")])])
      let right: Expr = .literal(42)
      #expect(path.segments == [.child([.filter(.comparison(left: left, operator: .eq, right: right))])])
    }

    @Test func filterCompNeSelector() throws {
      let path = try Path.parse(string: "$[?@.foo != 42]")
      #expect(path.initialNode == .root)
      let left: Expr = .singularQuery(node: .current, segments: [.child([.name("foo")])])
      let right: Expr = .literal(42)
      #expect(path.segments == [.child([.filter(.comparison(left: left, operator: .ne, right: right))])])
    }

    @Test func filterCompLtSelector() throws {
      let path = try Path.parse(string: "$[?@.foo < 42]")
      #expect(path.initialNode == .root)
      let left: Expr = .singularQuery(node: .current, segments: [.child([.name("foo")])])
      let right: Expr = .literal(42)
      #expect(path.segments == [.child([.filter(.comparison(left: left, operator: .lt, right: right))])])
    }

    @Test func filterCompLeSelector() throws {
      let path = try Path.parse(string: "$[?@.foo <= 42]")
      #expect(path.initialNode == .root)
      let left: Expr = .singularQuery(node: .current, segments: [.child([.name("foo")])])
      let right: Expr = .literal(42)
      #expect(path.segments == [.child([.filter(.comparison(left: left, operator: .le, right: right))])])
    }

    @Test func filterCompGtSelector() throws {
      let path = try Path.parse(string: "$[?@.foo > 42]")
      #expect(path.initialNode == .root)
      let left: Expr = .singularQuery(node: .current, segments: [.child([.name("foo")])])
      let right: Expr = .literal(42)
      #expect(path.segments == [.child([.filter(.comparison(left: left, operator: .gt, right: right))])])
    }

    @Test func filterCompGeSelector() throws {
      let path = try Path.parse(string: "$[?@.foo >= 42]")
      #expect(path.initialNode == .root)
      let left: Expr = .singularQuery(node: .current, segments: [.child([.name("foo")])])
      let right: Expr = .literal(42)
      #expect(path.segments == [.child([.filter(.comparison(left: left, operator: .ge, right: right))])])
    }

    @Test func filterLogOrSelector() throws {
      let path = try Path.parse(string: "$[?@.foo || @.bar]")
      #expect(path.initialNode == .root)
      let left: Expr = .test(expression: .query(node: .current, segments: [.child([.name("foo")])]))
      let right: Expr = .test(expression: .query(node: .current, segments: [.child([.name("bar")])]))
      #expect(path.segments == [.child([.filter(.logical(operator: .or, expressions: [left, right]))])])
    }

    @Test func filterLogAndSelector() throws {
      let path = try Path.parse(string: "$[?@.foo && @.bar]")
      #expect(path.initialNode == .root)
      let left: Expr = .test(expression: .query(node: .current, segments: [.child([.name("foo")])]))
      let right: Expr = .test(expression: .query(node: .current, segments: [.child([.name("bar")])]))
      #expect(path.segments == [.child([.filter(.logical(operator: .and, expressions: [left, right]))])])
    }

    @Test func filterLogNotSelector() throws {
      let path = try Path.parse(string: "$[?!(1 == 2)]", options: [.captureParentheses])
      #expect(path.initialNode == .root)
      let expr: Expr = .comparison(left: .literal(1), operator: .eq, right: .literal(2))
      #expect(path.segments == [.child([.filter(.logical(operator: .not, expressions: [expr]))])])
    }

  }

}
