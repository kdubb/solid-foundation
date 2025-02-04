// Generated from Sources/Codex/Path/Parsing/Path.g4 by ANTLR 4.13.2
@preconcurrency import Antlr4

open class PathParser: Parser {

	internal static let _decisionToDFA: [DFA] = {
          var decisionToDFA = [DFA]()
          let length = PathParser._ATN.getNumberOfDecisions()
          for i in 0..<length {
            decisionToDFA.append(DFA(PathParser._ATN.getDecisionState(i)!, i))
           }
           return decisionToDFA
     }()

	internal static let _sharedContextCache = PredictionContextCache()

	public
	enum Tokens: Int {
		case EOF = -1, ROOT = 1, CURRENT = 2, MEMBER_ACC = 3, DESC_ACC = 4, WILDCARD = 5, 
                 FILTER = 6, COLON = 7, SEMI = 8, OPEN_BRACKET = 9, CLOSE_BRACKET = 10, 
                 OPEN_PAREN = 11, CLOSE_PAREN = 12, COMMA = 13, EXCLAMATION_MARK = 14, 
                 LOGICAL_AND = 15, LOGICAL_OR = 16, CMP_EQ = 17, CMP_NE = 18, 
                 CMP_GT = 19, CMP_GE = 20, CMP_LT = 21, CMP_LE = 22, TRUE = 23, 
                 FALSE = 24, NULL = 25, BLANK = 26, INT = 27, DIGIT1 = 28, 
                 NUMBER = 29, SQOT = 30, DQOT = 31, FUNC_NAME = 32, NAME = 33, 
                 SQ_STRING = 34, DQ_STRING = 35
	}

	public
	static let RULE_pathQuery = 0, RULE_segments = 1, RULE_segment = 2, RULE_childSegment = 3, 
            RULE_descendantSegment = 4, RULE_selector = 5, RULE_nameSelector = 6, 
            RULE_wildcardSelector = 7, RULE_indexSelector = 8, RULE_sliceSelector = 9, 
            RULE_filterSelector = 10, RULE_memberNameShorthand = 11, RULE_name = 12, 
            RULE_slice = 13, RULE_start = 14, RULE_end = 15, RULE_step = 16, 
            RULE_bracketedSelection = 17, RULE_logicalExpr = 18, RULE_logicalOrExpr = 19, 
            RULE_logicalAndExpr = 20, RULE_basicExpr = 21, RULE_parenExpr = 22, 
            RULE_logicalNotOp = 23, RULE_testExpr = 24, RULE_filterQuery = 25, 
            RULE_relQuery = 26, RULE_comparisonExpr = 27, RULE_literal = 28, 
            RULE_nullLiteral = 29, RULE_boolLiteral = 30, RULE_intLiteral = 31, 
            RULE_numLiteral = 32, RULE_comparable = 33, RULE_comparisonOp = 34, 
            RULE_singularQuery = 35, RULE_relSingularQuery = 36, RULE_absSingularQuery = 37, 
            RULE_singularQuerySegments = 38, RULE_nameSegment = 39, RULE_indexSegment = 40, 
            RULE_stringLiteral = 41, RULE_functionName = 42, RULE_functionExpr = 43, 
            RULE_functionArgument = 44, RULE_s = 45

	public
	static let ruleNames: [String] = [
		"pathQuery", "segments", "segment", "childSegment", "descendantSegment", 
		"selector", "nameSelector", "wildcardSelector", "indexSelector", "sliceSelector", 
		"filterSelector", "memberNameShorthand", "name", "slice", "start", "end", 
		"step", "bracketedSelection", "logicalExpr", "logicalOrExpr", "logicalAndExpr", 
		"basicExpr", "parenExpr", "logicalNotOp", "testExpr", "filterQuery", "relQuery", 
		"comparisonExpr", "literal", "nullLiteral", "boolLiteral", "intLiteral", 
		"numLiteral", "comparable", "comparisonOp", "singularQuery", "relSingularQuery", 
		"absSingularQuery", "singularQuerySegments", "nameSegment", "indexSegment", 
		"stringLiteral", "functionName", "functionExpr", "functionArgument", "s"
	]

	private static let _LITERAL_NAMES: [String?] = [
		nil, "'$'", "'@'", "'.'", "'..'", "'*'", "'?'", "':'", "';'", "'['", "']'", 
		"'('", "')'", "','", "'!'", "'&&'", "'||'", "'=='", "'!='", "'>'", "'>='", 
		"'<'", "'<='", "'true'", "'false'", "'null'", nil, nil, nil, nil, "'''", 
		"'\"'"
	]
	private static let _SYMBOLIC_NAMES: [String?] = [
		nil, "ROOT", "CURRENT", "MEMBER_ACC", "DESC_ACC", "WILDCARD", "FILTER", 
		"COLON", "SEMI", "OPEN_BRACKET", "CLOSE_BRACKET", "OPEN_PAREN", "CLOSE_PAREN", 
		"COMMA", "EXCLAMATION_MARK", "LOGICAL_AND", "LOGICAL_OR", "CMP_EQ", "CMP_NE", 
		"CMP_GT", "CMP_GE", "CMP_LT", "CMP_LE", "TRUE", "FALSE", "NULL", "BLANK", 
		"INT", "DIGIT1", "NUMBER", "SQOT", "DQOT", "FUNC_NAME", "NAME", "SQ_STRING", 
		"DQ_STRING"
	]
	public
	static let VOCABULARY = Vocabulary(_LITERAL_NAMES, _SYMBOLIC_NAMES)

	override open
	func getGrammarFileName() -> String { return "Path.g4" }

	override open
	func getRuleNames() -> [String] { return PathParser.ruleNames }

	override open
	func getSerializedATN() -> [Int] { return PathParser._serializedATN }

	override open
	func getATN() -> ATN { return PathParser._ATN }


	override open
	func getVocabulary() -> Vocabulary {
	    return PathParser.VOCABULARY
	}

	override public
	init(_ input:TokenStream) throws {
	    RuntimeMetaData.checkVersion("4.13.2", RuntimeMetaData.VERSION)
		try super.init(input)
		_interp = ParserATNSimulator(self,PathParser._ATN,PathParser._decisionToDFA, PathParser._sharedContextCache)
	}


	public class PathQueryContext: ParserRuleContext {
			open
			func ROOT() -> TerminalNode? {
				return getToken(PathParser.Tokens.ROOT.rawValue, 0)
			}
			open
			func segments() -> SegmentsContext? {
				return getRuleContext(SegmentsContext.self, 0)
			}
			open
			func EOF() -> TerminalNode? {
				return getToken(PathParser.Tokens.EOF.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_pathQuery
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterPathQuery(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitPathQuery(self)
			}
		}
	}
	@discardableResult
	 open func pathQuery() throws -> PathQueryContext {
		var _localctx: PathQueryContext
		_localctx = PathQueryContext(_ctx, getState())
		try enterRule(_localctx, 0, PathParser.RULE_pathQuery)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(92)
		 	try match(PathParser.Tokens.ROOT.rawValue)
		 	setState(93)
		 	try segments()
		 	setState(94)
		 	try match(PathParser.Tokens.EOF.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SegmentsContext: ParserRuleContext {
			open
			func segment() -> [SegmentContext] {
				return getRuleContexts(SegmentContext.self)
			}
			open
			func segment(_ i: Int) -> SegmentContext? {
				return getRuleContext(SegmentContext.self, i)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_segments
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterSegments(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitSegments(self)
			}
		}
	}
	@discardableResult
	 open func segments() throws -> SegmentsContext {
		var _localctx: SegmentsContext
		_localctx = SegmentsContext(_ctx, getState())
		try enterRule(_localctx, 2, PathParser.RULE_segments)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(99)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & 536) != 0)) {
		 		setState(96)
		 		try segment()


		 		setState(101)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SegmentContext: ParserRuleContext {
			open
			func childSegment() -> ChildSegmentContext? {
				return getRuleContext(ChildSegmentContext.self, 0)
			}
			open
			func descendantSegment() -> DescendantSegmentContext? {
				return getRuleContext(DescendantSegmentContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_segment
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterSegment(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitSegment(self)
			}
		}
	}
	@discardableResult
	 open func segment() throws -> SegmentContext {
		var _localctx: SegmentContext
		_localctx = SegmentContext(_ctx, getState())
		try enterRule(_localctx, 4, PathParser.RULE_segment)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(104)
		 	try _errHandler.sync(self)
		 	switch (PathParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .MEMBER_ACC:fallthrough
		 	case .OPEN_BRACKET:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(102)
		 		try childSegment()

		 		break

		 	case .DESC_ACC:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(103)
		 		try descendantSegment()

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class ChildSegmentContext: ParserRuleContext {
			open
			func bracketedSelection() -> BracketedSelectionContext? {
				return getRuleContext(BracketedSelectionContext.self, 0)
			}
			open
			func MEMBER_ACC() -> TerminalNode? {
				return getToken(PathParser.Tokens.MEMBER_ACC.rawValue, 0)
			}
			open
			func wildcardSelector() -> WildcardSelectorContext? {
				return getRuleContext(WildcardSelectorContext.self, 0)
			}
			open
			func memberNameShorthand() -> MemberNameShorthandContext? {
				return getRuleContext(MemberNameShorthandContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_childSegment
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterChildSegment(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitChildSegment(self)
			}
		}
	}
	@discardableResult
	 open func childSegment() throws -> ChildSegmentContext {
		var _localctx: ChildSegmentContext
		_localctx = ChildSegmentContext(_ctx, getState())
		try enterRule(_localctx, 6, PathParser.RULE_childSegment)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(112)
		 	try _errHandler.sync(self)
		 	switch (PathParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .OPEN_BRACKET:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(106)
		 		try bracketedSelection()

		 		break

		 	case .MEMBER_ACC:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(107)
		 		try match(PathParser.Tokens.MEMBER_ACC.rawValue)
		 		setState(110)
		 		try _errHandler.sync(self)
		 		switch (PathParser.Tokens(rawValue: try _input.LA(1))!) {
		 		case .WILDCARD:
		 			setState(108)
		 			try wildcardSelector()

		 			break
		 		case .TRUE:fallthrough
		 		case .FALSE:fallthrough
		 		case .NULL:fallthrough
		 		case .FUNC_NAME:fallthrough
		 		case .NAME:
		 			setState(109)
		 			try memberNameShorthand()

		 			break
		 		default:
		 			throw ANTLRException.recognition(e: NoViableAltException(self))
		 		}

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class DescendantSegmentContext: ParserRuleContext {
			open
			func DESC_ACC() -> TerminalNode? {
				return getToken(PathParser.Tokens.DESC_ACC.rawValue, 0)
			}
			open
			func bracketedSelection() -> BracketedSelectionContext? {
				return getRuleContext(BracketedSelectionContext.self, 0)
			}
			open
			func wildcardSelector() -> WildcardSelectorContext? {
				return getRuleContext(WildcardSelectorContext.self, 0)
			}
			open
			func memberNameShorthand() -> MemberNameShorthandContext? {
				return getRuleContext(MemberNameShorthandContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_descendantSegment
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterDescendantSegment(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitDescendantSegment(self)
			}
		}
	}
	@discardableResult
	 open func descendantSegment() throws -> DescendantSegmentContext {
		var _localctx: DescendantSegmentContext
		_localctx = DescendantSegmentContext(_ctx, getState())
		try enterRule(_localctx, 8, PathParser.RULE_descendantSegment)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(114)
		 	try match(PathParser.Tokens.DESC_ACC.rawValue)
		 	setState(118)
		 	try _errHandler.sync(self)
		 	switch (PathParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .OPEN_BRACKET:
		 		setState(115)
		 		try bracketedSelection()

		 		break

		 	case .WILDCARD:
		 		setState(116)
		 		try wildcardSelector()

		 		break
		 	case .TRUE:fallthrough
		 	case .FALSE:fallthrough
		 	case .NULL:fallthrough
		 	case .FUNC_NAME:fallthrough
		 	case .NAME:
		 		setState(117)
		 		try memberNameShorthand()

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SelectorContext: ParserRuleContext {
			open
			func nameSelector() -> NameSelectorContext? {
				return getRuleContext(NameSelectorContext.self, 0)
			}
			open
			func wildcardSelector() -> WildcardSelectorContext? {
				return getRuleContext(WildcardSelectorContext.self, 0)
			}
			open
			func indexSelector() -> IndexSelectorContext? {
				return getRuleContext(IndexSelectorContext.self, 0)
			}
			open
			func sliceSelector() -> SliceSelectorContext? {
				return getRuleContext(SliceSelectorContext.self, 0)
			}
			open
			func filterSelector() -> FilterSelectorContext? {
				return getRuleContext(FilterSelectorContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_selector
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterSelector(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitSelector(self)
			}
		}
	}
	@discardableResult
	 open func selector() throws -> SelectorContext {
		var _localctx: SelectorContext
		_localctx = SelectorContext(_ctx, getState())
		try enterRule(_localctx, 10, PathParser.RULE_selector)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(125)
		 	try _errHandler.sync(self)
		 	switch(try getInterpreter().adaptivePredict(_input,5, _ctx)) {
		 	case 1:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(120)
		 		try nameSelector()

		 		break
		 	case 2:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(121)
		 		try wildcardSelector()

		 		break
		 	case 3:
		 		try enterOuterAlt(_localctx, 3)
		 		setState(122)
		 		try indexSelector()

		 		break
		 	case 4:
		 		try enterOuterAlt(_localctx, 4)
		 		setState(123)
		 		try sliceSelector()

		 		break
		 	case 5:
		 		try enterOuterAlt(_localctx, 5)
		 		setState(124)
		 		try filterSelector()

		 		break
		 	default: break
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class NameSelectorContext: ParserRuleContext {
			open
			func stringLiteral() -> StringLiteralContext? {
				return getRuleContext(StringLiteralContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_nameSelector
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterNameSelector(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitNameSelector(self)
			}
		}
	}
	@discardableResult
	 open func nameSelector() throws -> NameSelectorContext {
		var _localctx: NameSelectorContext
		_localctx = NameSelectorContext(_ctx, getState())
		try enterRule(_localctx, 12, PathParser.RULE_nameSelector)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(127)
		 	try stringLiteral()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class WildcardSelectorContext: ParserRuleContext {
			open
			func WILDCARD() -> TerminalNode? {
				return getToken(PathParser.Tokens.WILDCARD.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_wildcardSelector
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterWildcardSelector(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitWildcardSelector(self)
			}
		}
	}
	@discardableResult
	 open func wildcardSelector() throws -> WildcardSelectorContext {
		var _localctx: WildcardSelectorContext
		_localctx = WildcardSelectorContext(_ctx, getState())
		try enterRule(_localctx, 14, PathParser.RULE_wildcardSelector)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(129)
		 	try match(PathParser.Tokens.WILDCARD.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class IndexSelectorContext: ParserRuleContext {
			open
			func INT() -> TerminalNode? {
				return getToken(PathParser.Tokens.INT.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_indexSelector
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterIndexSelector(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitIndexSelector(self)
			}
		}
	}
	@discardableResult
	 open func indexSelector() throws -> IndexSelectorContext {
		var _localctx: IndexSelectorContext
		_localctx = IndexSelectorContext(_ctx, getState())
		try enterRule(_localctx, 16, PathParser.RULE_indexSelector)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(131)
		 	try match(PathParser.Tokens.INT.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SliceSelectorContext: ParserRuleContext {
			open
			func slice() -> SliceContext? {
				return getRuleContext(SliceContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_sliceSelector
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterSliceSelector(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitSliceSelector(self)
			}
		}
	}
	@discardableResult
	 open func sliceSelector() throws -> SliceSelectorContext {
		var _localctx: SliceSelectorContext
		_localctx = SliceSelectorContext(_ctx, getState())
		try enterRule(_localctx, 18, PathParser.RULE_sliceSelector)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(133)
		 	try slice()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class FilterSelectorContext: ParserRuleContext {
			open
			func FILTER() -> TerminalNode? {
				return getToken(PathParser.Tokens.FILTER.rawValue, 0)
			}
			open
			func s() -> SContext? {
				return getRuleContext(SContext.self, 0)
			}
			open
			func logicalExpr() -> LogicalExprContext? {
				return getRuleContext(LogicalExprContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_filterSelector
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterFilterSelector(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitFilterSelector(self)
			}
		}
	}
	@discardableResult
	 open func filterSelector() throws -> FilterSelectorContext {
		var _localctx: FilterSelectorContext
		_localctx = FilterSelectorContext(_ctx, getState())
		try enterRule(_localctx, 20, PathParser.RULE_filterSelector)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(135)
		 	try match(PathParser.Tokens.FILTER.rawValue)
		 	setState(136)
		 	try s()
		 	setState(137)
		 	try logicalExpr()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class MemberNameShorthandContext: ParserRuleContext {
			open
			func name() -> NameContext? {
				return getRuleContext(NameContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_memberNameShorthand
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterMemberNameShorthand(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitMemberNameShorthand(self)
			}
		}
	}
	@discardableResult
	 open func memberNameShorthand() throws -> MemberNameShorthandContext {
		var _localctx: MemberNameShorthandContext
		_localctx = MemberNameShorthandContext(_ctx, getState())
		try enterRule(_localctx, 22, PathParser.RULE_memberNameShorthand)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(139)
		 	try name()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class NameContext: ParserRuleContext {
			open
			func NAME() -> TerminalNode? {
				return getToken(PathParser.Tokens.NAME.rawValue, 0)
			}
			open
			func FUNC_NAME() -> TerminalNode? {
				return getToken(PathParser.Tokens.FUNC_NAME.rawValue, 0)
			}
			open
			func TRUE() -> TerminalNode? {
				return getToken(PathParser.Tokens.TRUE.rawValue, 0)
			}
			open
			func FALSE() -> TerminalNode? {
				return getToken(PathParser.Tokens.FALSE.rawValue, 0)
			}
			open
			func NULL() -> TerminalNode? {
				return getToken(PathParser.Tokens.NULL.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_name
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterName(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitName(self)
			}
		}
	}
	@discardableResult
	 open func name() throws -> NameContext {
		var _localctx: NameContext
		_localctx = NameContext(_ctx, getState())
		try enterRule(_localctx, 24, PathParser.RULE_name)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(141)
		 	_la = try _input.LA(1)
		 	if (!(((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & 12943622144) != 0))) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SliceContext: ParserRuleContext {
			open
			func COLON() -> [TerminalNode] {
				return getTokens(PathParser.Tokens.COLON.rawValue)
			}
			open
			func COLON(_ i:Int) -> TerminalNode? {
				return getToken(PathParser.Tokens.COLON.rawValue, i)
			}
			open
			func s() -> [SContext] {
				return getRuleContexts(SContext.self)
			}
			open
			func s(_ i: Int) -> SContext? {
				return getRuleContext(SContext.self, i)
			}
			open
			func start() -> StartContext? {
				return getRuleContext(StartContext.self, 0)
			}
			open
			func end() -> EndContext? {
				return getRuleContext(EndContext.self, 0)
			}
			open
			func step() -> StepContext? {
				return getRuleContext(StepContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_slice
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterSlice(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitSlice(self)
			}
		}
	}
	@discardableResult
	 open func slice() throws -> SliceContext {
		var _localctx: SliceContext
		_localctx = SliceContext(_ctx, getState())
		try enterRule(_localctx, 26, PathParser.RULE_slice)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(146)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == PathParser.Tokens.INT.rawValue) {
		 		setState(143)
		 		try start()
		 		setState(144)
		 		try s()

		 	}

		 	setState(148)
		 	try match(PathParser.Tokens.COLON.rawValue)
		 	setState(149)
		 	try s()
		 	setState(153)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == PathParser.Tokens.INT.rawValue) {
		 		setState(150)
		 		try end()
		 		setState(151)
		 		try s()

		 	}

		 	setState(159)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == PathParser.Tokens.COLON.rawValue) {
		 		setState(155)
		 		try match(PathParser.Tokens.COLON.rawValue)

		 		setState(156)
		 		try s()
		 		setState(157)
		 		try step()


		 	}


		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class StartContext: ParserRuleContext {
			open
			func INT() -> TerminalNode? {
				return getToken(PathParser.Tokens.INT.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_start
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterStart(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitStart(self)
			}
		}
	}
	@discardableResult
	 open func start() throws -> StartContext {
		var _localctx: StartContext
		_localctx = StartContext(_ctx, getState())
		try enterRule(_localctx, 28, PathParser.RULE_start)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(161)
		 	try match(PathParser.Tokens.INT.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class EndContext: ParserRuleContext {
			open
			func INT() -> TerminalNode? {
				return getToken(PathParser.Tokens.INT.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_end
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterEnd(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitEnd(self)
			}
		}
	}
	@discardableResult
	 open func end() throws -> EndContext {
		var _localctx: EndContext
		_localctx = EndContext(_ctx, getState())
		try enterRule(_localctx, 30, PathParser.RULE_end)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(163)
		 	try match(PathParser.Tokens.INT.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class StepContext: ParserRuleContext {
			open
			func INT() -> TerminalNode? {
				return getToken(PathParser.Tokens.INT.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_step
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterStep(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitStep(self)
			}
		}
	}
	@discardableResult
	 open func step() throws -> StepContext {
		var _localctx: StepContext
		_localctx = StepContext(_ctx, getState())
		try enterRule(_localctx, 32, PathParser.RULE_step)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(165)
		 	try match(PathParser.Tokens.INT.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class BracketedSelectionContext: ParserRuleContext {
			open
			func OPEN_BRACKET() -> TerminalNode? {
				return getToken(PathParser.Tokens.OPEN_BRACKET.rawValue, 0)
			}
			open
			func s() -> [SContext] {
				return getRuleContexts(SContext.self)
			}
			open
			func s(_ i: Int) -> SContext? {
				return getRuleContext(SContext.self, i)
			}
			open
			func selector() -> [SelectorContext] {
				return getRuleContexts(SelectorContext.self)
			}
			open
			func selector(_ i: Int) -> SelectorContext? {
				return getRuleContext(SelectorContext.self, i)
			}
			open
			func CLOSE_BRACKET() -> TerminalNode? {
				return getToken(PathParser.Tokens.CLOSE_BRACKET.rawValue, 0)
			}
			open
			func COMMA() -> [TerminalNode] {
				return getTokens(PathParser.Tokens.COMMA.rawValue)
			}
			open
			func COMMA(_ i:Int) -> TerminalNode? {
				return getToken(PathParser.Tokens.COMMA.rawValue, i)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_bracketedSelection
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterBracketedSelection(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitBracketedSelection(self)
			}
		}
	}
	@discardableResult
	 open func bracketedSelection() throws -> BracketedSelectionContext {
		var _localctx: BracketedSelectionContext
		_localctx = BracketedSelectionContext(_ctx, getState())
		try enterRule(_localctx, 34, PathParser.RULE_bracketedSelection)
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt:Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(167)
		 	try match(PathParser.Tokens.OPEN_BRACKET.rawValue)
		 	setState(168)
		 	try s()
		 	setState(169)
		 	try selector()
		 	setState(177)
		 	try _errHandler.sync(self)
		 	_alt = try getInterpreter().adaptivePredict(_input,9,_ctx)
		 	while (_alt != 2 && _alt != ATN.INVALID_ALT_NUMBER) {
		 		if ( _alt==1 ) {
		 			setState(170)
		 			try s()
		 			setState(171)
		 			try match(PathParser.Tokens.COMMA.rawValue)
		 			setState(172)
		 			try s()
		 			setState(173)
		 			try selector()

		 	 
		 		}
		 		setState(179)
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input,9,_ctx)
		 	}
		 	setState(180)
		 	try s()
		 	setState(181)
		 	try match(PathParser.Tokens.CLOSE_BRACKET.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class LogicalExprContext: ParserRuleContext {
			open
			func logicalOrExpr() -> LogicalOrExprContext? {
				return getRuleContext(LogicalOrExprContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_logicalExpr
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterLogicalExpr(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitLogicalExpr(self)
			}
		}
	}
	@discardableResult
	 open func logicalExpr() throws -> LogicalExprContext {
		var _localctx: LogicalExprContext
		_localctx = LogicalExprContext(_ctx, getState())
		try enterRule(_localctx, 36, PathParser.RULE_logicalExpr)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(183)
		 	try logicalOrExpr()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class LogicalOrExprContext: ParserRuleContext {
			open
			func logicalAndExpr() -> [LogicalAndExprContext] {
				return getRuleContexts(LogicalAndExprContext.self)
			}
			open
			func logicalAndExpr(_ i: Int) -> LogicalAndExprContext? {
				return getRuleContext(LogicalAndExprContext.self, i)
			}
			open
			func s() -> [SContext] {
				return getRuleContexts(SContext.self)
			}
			open
			func s(_ i: Int) -> SContext? {
				return getRuleContext(SContext.self, i)
			}
			open
			func LOGICAL_OR() -> [TerminalNode] {
				return getTokens(PathParser.Tokens.LOGICAL_OR.rawValue)
			}
			open
			func LOGICAL_OR(_ i:Int) -> TerminalNode? {
				return getToken(PathParser.Tokens.LOGICAL_OR.rawValue, i)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_logicalOrExpr
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterLogicalOrExpr(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitLogicalOrExpr(self)
			}
		}
	}
	@discardableResult
	 open func logicalOrExpr() throws -> LogicalOrExprContext {
		var _localctx: LogicalOrExprContext
		_localctx = LogicalOrExprContext(_ctx, getState())
		try enterRule(_localctx, 38, PathParser.RULE_logicalOrExpr)
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt:Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(185)
		 	try logicalAndExpr()
		 	setState(193)
		 	try _errHandler.sync(self)
		 	_alt = try getInterpreter().adaptivePredict(_input,10,_ctx)
		 	while (_alt != 2 && _alt != ATN.INVALID_ALT_NUMBER) {
		 		if ( _alt==1 ) {
		 			setState(186)
		 			try s()
		 			setState(187)
		 			try match(PathParser.Tokens.LOGICAL_OR.rawValue)
		 			setState(188)
		 			try s()
		 			setState(189)
		 			try logicalAndExpr()

		 	 
		 		}
		 		setState(195)
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input,10,_ctx)
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class LogicalAndExprContext: ParserRuleContext {
			open
			func basicExpr() -> [BasicExprContext] {
				return getRuleContexts(BasicExprContext.self)
			}
			open
			func basicExpr(_ i: Int) -> BasicExprContext? {
				return getRuleContext(BasicExprContext.self, i)
			}
			open
			func s() -> [SContext] {
				return getRuleContexts(SContext.self)
			}
			open
			func s(_ i: Int) -> SContext? {
				return getRuleContext(SContext.self, i)
			}
			open
			func LOGICAL_AND() -> [TerminalNode] {
				return getTokens(PathParser.Tokens.LOGICAL_AND.rawValue)
			}
			open
			func LOGICAL_AND(_ i:Int) -> TerminalNode? {
				return getToken(PathParser.Tokens.LOGICAL_AND.rawValue, i)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_logicalAndExpr
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterLogicalAndExpr(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitLogicalAndExpr(self)
			}
		}
	}
	@discardableResult
	 open func logicalAndExpr() throws -> LogicalAndExprContext {
		var _localctx: LogicalAndExprContext
		_localctx = LogicalAndExprContext(_ctx, getState())
		try enterRule(_localctx, 40, PathParser.RULE_logicalAndExpr)
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt:Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(196)
		 	try basicExpr()
		 	setState(204)
		 	try _errHandler.sync(self)
		 	_alt = try getInterpreter().adaptivePredict(_input,11,_ctx)
		 	while (_alt != 2 && _alt != ATN.INVALID_ALT_NUMBER) {
		 		if ( _alt==1 ) {
		 			setState(197)
		 			try s()
		 			setState(198)
		 			try match(PathParser.Tokens.LOGICAL_AND.rawValue)
		 			setState(199)
		 			try s()
		 			setState(200)
		 			try basicExpr()

		 	 
		 		}
		 		setState(206)
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input,11,_ctx)
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class BasicExprContext: ParserRuleContext {
			open
			func parenExpr() -> ParenExprContext? {
				return getRuleContext(ParenExprContext.self, 0)
			}
			open
			func comparisonExpr() -> ComparisonExprContext? {
				return getRuleContext(ComparisonExprContext.self, 0)
			}
			open
			func testExpr() -> TestExprContext? {
				return getRuleContext(TestExprContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_basicExpr
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterBasicExpr(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitBasicExpr(self)
			}
		}
	}
	@discardableResult
	 open func basicExpr() throws -> BasicExprContext {
		var _localctx: BasicExprContext
		_localctx = BasicExprContext(_ctx, getState())
		try enterRule(_localctx, 42, PathParser.RULE_basicExpr)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(210)
		 	try _errHandler.sync(self)
		 	switch(try getInterpreter().adaptivePredict(_input,12, _ctx)) {
		 	case 1:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(207)
		 		try parenExpr()

		 		break
		 	case 2:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(208)
		 		try comparisonExpr()

		 		break
		 	case 3:
		 		try enterOuterAlt(_localctx, 3)
		 		setState(209)
		 		try testExpr()

		 		break
		 	default: break
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class ParenExprContext: ParserRuleContext {
			open
			func OPEN_PAREN() -> TerminalNode? {
				return getToken(PathParser.Tokens.OPEN_PAREN.rawValue, 0)
			}
			open
			func s() -> [SContext] {
				return getRuleContexts(SContext.self)
			}
			open
			func s(_ i: Int) -> SContext? {
				return getRuleContext(SContext.self, i)
			}
			open
			func logicalExpr() -> LogicalExprContext? {
				return getRuleContext(LogicalExprContext.self, 0)
			}
			open
			func CLOSE_PAREN() -> TerminalNode? {
				return getToken(PathParser.Tokens.CLOSE_PAREN.rawValue, 0)
			}
			open
			func logicalNotOp() -> LogicalNotOpContext? {
				return getRuleContext(LogicalNotOpContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_parenExpr
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterParenExpr(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitParenExpr(self)
			}
		}
	}
	@discardableResult
	 open func parenExpr() throws -> ParenExprContext {
		var _localctx: ParenExprContext
		_localctx = ParenExprContext(_ctx, getState())
		try enterRule(_localctx, 44, PathParser.RULE_parenExpr)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(215)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == PathParser.Tokens.EXCLAMATION_MARK.rawValue) {
		 		setState(212)
		 		try logicalNotOp()
		 		setState(213)
		 		try s()

		 	}

		 	setState(217)
		 	try match(PathParser.Tokens.OPEN_PAREN.rawValue)
		 	setState(218)
		 	try s()
		 	setState(219)
		 	try logicalExpr()
		 	setState(220)
		 	try s()
		 	setState(221)
		 	try match(PathParser.Tokens.CLOSE_PAREN.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class LogicalNotOpContext: ParserRuleContext {
			open
			func EXCLAMATION_MARK() -> TerminalNode? {
				return getToken(PathParser.Tokens.EXCLAMATION_MARK.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_logicalNotOp
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterLogicalNotOp(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitLogicalNotOp(self)
			}
		}
	}
	@discardableResult
	 open func logicalNotOp() throws -> LogicalNotOpContext {
		var _localctx: LogicalNotOpContext
		_localctx = LogicalNotOpContext(_ctx, getState())
		try enterRule(_localctx, 46, PathParser.RULE_logicalNotOp)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(223)
		 	try match(PathParser.Tokens.EXCLAMATION_MARK.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class TestExprContext: ParserRuleContext {
			open
			func filterQuery() -> FilterQueryContext? {
				return getRuleContext(FilterQueryContext.self, 0)
			}
			open
			func functionExpr() -> FunctionExprContext? {
				return getRuleContext(FunctionExprContext.self, 0)
			}
			open
			func logicalNotOp() -> LogicalNotOpContext? {
				return getRuleContext(LogicalNotOpContext.self, 0)
			}
			open
			func s() -> SContext? {
				return getRuleContext(SContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_testExpr
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterTestExpr(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitTestExpr(self)
			}
		}
	}
	@discardableResult
	 open func testExpr() throws -> TestExprContext {
		var _localctx: TestExprContext
		_localctx = TestExprContext(_ctx, getState())
		try enterRule(_localctx, 48, PathParser.RULE_testExpr)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(228)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == PathParser.Tokens.EXCLAMATION_MARK.rawValue) {
		 		setState(225)
		 		try logicalNotOp()
		 		setState(226)
		 		try s()

		 	}

		 	setState(232)
		 	try _errHandler.sync(self)
		 	switch (PathParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .ROOT:fallthrough
		 	case .CURRENT:
		 		setState(230)
		 		try filterQuery()

		 		break

		 	case .FUNC_NAME:
		 		setState(231)
		 		try functionExpr()

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class FilterQueryContext: ParserRuleContext {
			open
			func relQuery() -> RelQueryContext? {
				return getRuleContext(RelQueryContext.self, 0)
			}
			open
			func pathQuery() -> PathQueryContext? {
				return getRuleContext(PathQueryContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_filterQuery
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterFilterQuery(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitFilterQuery(self)
			}
		}
	}
	@discardableResult
	 open func filterQuery() throws -> FilterQueryContext {
		var _localctx: FilterQueryContext
		_localctx = FilterQueryContext(_ctx, getState())
		try enterRule(_localctx, 50, PathParser.RULE_filterQuery)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(236)
		 	try _errHandler.sync(self)
		 	switch (PathParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .CURRENT:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(234)
		 		try relQuery()

		 		break

		 	case .ROOT:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(235)
		 		try pathQuery()

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class RelQueryContext: ParserRuleContext {
			open
			func CURRENT() -> TerminalNode? {
				return getToken(PathParser.Tokens.CURRENT.rawValue, 0)
			}
			open
			func segments() -> SegmentsContext? {
				return getRuleContext(SegmentsContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_relQuery
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterRelQuery(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitRelQuery(self)
			}
		}
	}
	@discardableResult
	 open func relQuery() throws -> RelQueryContext {
		var _localctx: RelQueryContext
		_localctx = RelQueryContext(_ctx, getState())
		try enterRule(_localctx, 52, PathParser.RULE_relQuery)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(238)
		 	try match(PathParser.Tokens.CURRENT.rawValue)
		 	setState(239)
		 	try segments()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class ComparisonExprContext: ParserRuleContext {
			open
			func comparable() -> [ComparableContext] {
				return getRuleContexts(ComparableContext.self)
			}
			open
			func comparable(_ i: Int) -> ComparableContext? {
				return getRuleContext(ComparableContext.self, i)
			}
			open
			func s() -> [SContext] {
				return getRuleContexts(SContext.self)
			}
			open
			func s(_ i: Int) -> SContext? {
				return getRuleContext(SContext.self, i)
			}
			open
			func comparisonOp() -> ComparisonOpContext? {
				return getRuleContext(ComparisonOpContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_comparisonExpr
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterComparisonExpr(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitComparisonExpr(self)
			}
		}
	}
	@discardableResult
	 open func comparisonExpr() throws -> ComparisonExprContext {
		var _localctx: ComparisonExprContext
		_localctx = ComparisonExprContext(_ctx, getState())
		try enterRule(_localctx, 54, PathParser.RULE_comparisonExpr)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(241)
		 	try comparable()
		 	setState(242)
		 	try s()
		 	setState(243)
		 	try comparisonOp()
		 	setState(244)
		 	try s()
		 	setState(245)
		 	try comparable()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class LiteralContext: ParserRuleContext {
			open
			func nullLiteral() -> NullLiteralContext? {
				return getRuleContext(NullLiteralContext.self, 0)
			}
			open
			func boolLiteral() -> BoolLiteralContext? {
				return getRuleContext(BoolLiteralContext.self, 0)
			}
			open
			func intLiteral() -> IntLiteralContext? {
				return getRuleContext(IntLiteralContext.self, 0)
			}
			open
			func numLiteral() -> NumLiteralContext? {
				return getRuleContext(NumLiteralContext.self, 0)
			}
			open
			func stringLiteral() -> StringLiteralContext? {
				return getRuleContext(StringLiteralContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_literal
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterLiteral(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitLiteral(self)
			}
		}
	}
	@discardableResult
	 open func literal() throws -> LiteralContext {
		var _localctx: LiteralContext
		_localctx = LiteralContext(_ctx, getState())
		try enterRule(_localctx, 56, PathParser.RULE_literal)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(252)
		 	try _errHandler.sync(self)
		 	switch (PathParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .NULL:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(247)
		 		try nullLiteral()

		 		break
		 	case .TRUE:fallthrough
		 	case .FALSE:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(248)
		 		try boolLiteral()

		 		break

		 	case .INT:
		 		try enterOuterAlt(_localctx, 3)
		 		setState(249)
		 		try intLiteral()

		 		break

		 	case .NUMBER:
		 		try enterOuterAlt(_localctx, 4)
		 		setState(250)
		 		try numLiteral()

		 		break
		 	case .SQ_STRING:fallthrough
		 	case .DQ_STRING:
		 		try enterOuterAlt(_localctx, 5)
		 		setState(251)
		 		try stringLiteral()

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class NullLiteralContext: ParserRuleContext {
			open
			func NULL() -> TerminalNode? {
				return getToken(PathParser.Tokens.NULL.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_nullLiteral
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterNullLiteral(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitNullLiteral(self)
			}
		}
	}
	@discardableResult
	 open func nullLiteral() throws -> NullLiteralContext {
		var _localctx: NullLiteralContext
		_localctx = NullLiteralContext(_ctx, getState())
		try enterRule(_localctx, 58, PathParser.RULE_nullLiteral)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(254)
		 	try match(PathParser.Tokens.NULL.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class BoolLiteralContext: ParserRuleContext {
			open
			func TRUE() -> TerminalNode? {
				return getToken(PathParser.Tokens.TRUE.rawValue, 0)
			}
			open
			func FALSE() -> TerminalNode? {
				return getToken(PathParser.Tokens.FALSE.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_boolLiteral
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterBoolLiteral(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitBoolLiteral(self)
			}
		}
	}
	@discardableResult
	 open func boolLiteral() throws -> BoolLiteralContext {
		var _localctx: BoolLiteralContext
		_localctx = BoolLiteralContext(_ctx, getState())
		try enterRule(_localctx, 60, PathParser.RULE_boolLiteral)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(256)
		 	_la = try _input.LA(1)
		 	if (!(_la == PathParser.Tokens.TRUE.rawValue || _la == PathParser.Tokens.FALSE.rawValue)) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class IntLiteralContext: ParserRuleContext {
			open
			func INT() -> TerminalNode? {
				return getToken(PathParser.Tokens.INT.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_intLiteral
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterIntLiteral(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitIntLiteral(self)
			}
		}
	}
	@discardableResult
	 open func intLiteral() throws -> IntLiteralContext {
		var _localctx: IntLiteralContext
		_localctx = IntLiteralContext(_ctx, getState())
		try enterRule(_localctx, 62, PathParser.RULE_intLiteral)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(258)
		 	try match(PathParser.Tokens.INT.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class NumLiteralContext: ParserRuleContext {
			open
			func NUMBER() -> TerminalNode? {
				return getToken(PathParser.Tokens.NUMBER.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_numLiteral
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterNumLiteral(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitNumLiteral(self)
			}
		}
	}
	@discardableResult
	 open func numLiteral() throws -> NumLiteralContext {
		var _localctx: NumLiteralContext
		_localctx = NumLiteralContext(_ctx, getState())
		try enterRule(_localctx, 64, PathParser.RULE_numLiteral)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(260)
		 	try match(PathParser.Tokens.NUMBER.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class ComparableContext: ParserRuleContext {
			open
			func literal() -> LiteralContext? {
				return getRuleContext(LiteralContext.self, 0)
			}
			open
			func singularQuery() -> SingularQueryContext? {
				return getRuleContext(SingularQueryContext.self, 0)
			}
			open
			func functionExpr() -> FunctionExprContext? {
				return getRuleContext(FunctionExprContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_comparable
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterComparable(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitComparable(self)
			}
		}
	}
	@discardableResult
	 open func comparable() throws -> ComparableContext {
		var _localctx: ComparableContext
		_localctx = ComparableContext(_ctx, getState())
		try enterRule(_localctx, 66, PathParser.RULE_comparable)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(265)
		 	try _errHandler.sync(self)
		 	switch (PathParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .TRUE:fallthrough
		 	case .FALSE:fallthrough
		 	case .NULL:fallthrough
		 	case .INT:fallthrough
		 	case .NUMBER:fallthrough
		 	case .SQ_STRING:fallthrough
		 	case .DQ_STRING:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(262)
		 		try literal()

		 		break
		 	case .ROOT:fallthrough
		 	case .CURRENT:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(263)
		 		try singularQuery()

		 		break

		 	case .FUNC_NAME:
		 		try enterOuterAlt(_localctx, 3)
		 		setState(264)
		 		try functionExpr()

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class ComparisonOpContext: ParserRuleContext {
			open
			func CMP_EQ() -> TerminalNode? {
				return getToken(PathParser.Tokens.CMP_EQ.rawValue, 0)
			}
			open
			func CMP_NE() -> TerminalNode? {
				return getToken(PathParser.Tokens.CMP_NE.rawValue, 0)
			}
			open
			func CMP_LT() -> TerminalNode? {
				return getToken(PathParser.Tokens.CMP_LT.rawValue, 0)
			}
			open
			func CMP_LE() -> TerminalNode? {
				return getToken(PathParser.Tokens.CMP_LE.rawValue, 0)
			}
			open
			func CMP_GT() -> TerminalNode? {
				return getToken(PathParser.Tokens.CMP_GT.rawValue, 0)
			}
			open
			func CMP_GE() -> TerminalNode? {
				return getToken(PathParser.Tokens.CMP_GE.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_comparisonOp
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterComparisonOp(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitComparisonOp(self)
			}
		}
	}
	@discardableResult
	 open func comparisonOp() throws -> ComparisonOpContext {
		var _localctx: ComparisonOpContext
		_localctx = ComparisonOpContext(_ctx, getState())
		try enterRule(_localctx, 68, PathParser.RULE_comparisonOp)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(267)
		 	_la = try _input.LA(1)
		 	if (!(((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & 8257536) != 0))) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SingularQueryContext: ParserRuleContext {
			open
			func relSingularQuery() -> RelSingularQueryContext? {
				return getRuleContext(RelSingularQueryContext.self, 0)
			}
			open
			func absSingularQuery() -> AbsSingularQueryContext? {
				return getRuleContext(AbsSingularQueryContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_singularQuery
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterSingularQuery(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitSingularQuery(self)
			}
		}
	}
	@discardableResult
	 open func singularQuery() throws -> SingularQueryContext {
		var _localctx: SingularQueryContext
		_localctx = SingularQueryContext(_ctx, getState())
		try enterRule(_localctx, 70, PathParser.RULE_singularQuery)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(271)
		 	try _errHandler.sync(self)
		 	switch (PathParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .CURRENT:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(269)
		 		try relSingularQuery()

		 		break

		 	case .ROOT:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(270)
		 		try absSingularQuery()

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class RelSingularQueryContext: ParserRuleContext {
			open
			func CURRENT() -> TerminalNode? {
				return getToken(PathParser.Tokens.CURRENT.rawValue, 0)
			}
			open
			func singularQuerySegments() -> SingularQuerySegmentsContext? {
				return getRuleContext(SingularQuerySegmentsContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_relSingularQuery
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterRelSingularQuery(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitRelSingularQuery(self)
			}
		}
	}
	@discardableResult
	 open func relSingularQuery() throws -> RelSingularQueryContext {
		var _localctx: RelSingularQueryContext
		_localctx = RelSingularQueryContext(_ctx, getState())
		try enterRule(_localctx, 72, PathParser.RULE_relSingularQuery)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(273)
		 	try match(PathParser.Tokens.CURRENT.rawValue)
		 	setState(274)
		 	try singularQuerySegments()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class AbsSingularQueryContext: ParserRuleContext {
			open
			func ROOT() -> TerminalNode? {
				return getToken(PathParser.Tokens.ROOT.rawValue, 0)
			}
			open
			func singularQuerySegments() -> SingularQuerySegmentsContext? {
				return getRuleContext(SingularQuerySegmentsContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_absSingularQuery
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterAbsSingularQuery(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitAbsSingularQuery(self)
			}
		}
	}
	@discardableResult
	 open func absSingularQuery() throws -> AbsSingularQueryContext {
		var _localctx: AbsSingularQueryContext
		_localctx = AbsSingularQueryContext(_ctx, getState())
		try enterRule(_localctx, 74, PathParser.RULE_absSingularQuery)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(276)
		 	try match(PathParser.Tokens.ROOT.rawValue)
		 	setState(277)
		 	try singularQuerySegments()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SingularQuerySegmentsContext: ParserRuleContext {
			open
			func s() -> [SContext] {
				return getRuleContexts(SContext.self)
			}
			open
			func s(_ i: Int) -> SContext? {
				return getRuleContext(SContext.self, i)
			}
			open
			func nameSegment() -> [NameSegmentContext] {
				return getRuleContexts(NameSegmentContext.self)
			}
			open
			func nameSegment(_ i: Int) -> NameSegmentContext? {
				return getRuleContext(NameSegmentContext.self, i)
			}
			open
			func indexSegment() -> [IndexSegmentContext] {
				return getRuleContexts(IndexSegmentContext.self)
			}
			open
			func indexSegment(_ i: Int) -> IndexSegmentContext? {
				return getRuleContext(IndexSegmentContext.self, i)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_singularQuerySegments
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterSingularQuerySegments(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitSingularQuerySegments(self)
			}
		}
	}
	@discardableResult
	 open func singularQuerySegments() throws -> SingularQuerySegmentsContext {
		var _localctx: SingularQuerySegmentsContext
		_localctx = SingularQuerySegmentsContext(_ctx, getState())
		try enterRule(_localctx, 76, PathParser.RULE_singularQuerySegments)
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt:Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(286)
		 	try _errHandler.sync(self)
		 	_alt = try getInterpreter().adaptivePredict(_input,21,_ctx)
		 	while (_alt != 2 && _alt != ATN.INVALID_ALT_NUMBER) {
		 		if ( _alt==1 ) {
		 			setState(279)
		 			try s()
		 			setState(282)
		 			try _errHandler.sync(self)
		 			switch(try getInterpreter().adaptivePredict(_input,20, _ctx)) {
		 			case 1:
		 				setState(280)
		 				try nameSegment()

		 				break
		 			case 2:
		 				setState(281)
		 				try indexSegment()

		 				break
		 			default: break
		 			}

		 	 
		 		}
		 		setState(288)
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input,21,_ctx)
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class NameSegmentContext: ParserRuleContext {
			open
			func OPEN_BRACKET() -> TerminalNode? {
				return getToken(PathParser.Tokens.OPEN_BRACKET.rawValue, 0)
			}
			open
			func nameSelector() -> NameSelectorContext? {
				return getRuleContext(NameSelectorContext.self, 0)
			}
			open
			func CLOSE_BRACKET() -> TerminalNode? {
				return getToken(PathParser.Tokens.CLOSE_BRACKET.rawValue, 0)
			}
			open
			func MEMBER_ACC() -> TerminalNode? {
				return getToken(PathParser.Tokens.MEMBER_ACC.rawValue, 0)
			}
			open
			func memberNameShorthand() -> MemberNameShorthandContext? {
				return getRuleContext(MemberNameShorthandContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_nameSegment
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterNameSegment(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitNameSegment(self)
			}
		}
	}
	@discardableResult
	 open func nameSegment() throws -> NameSegmentContext {
		var _localctx: NameSegmentContext
		_localctx = NameSegmentContext(_ctx, getState())
		try enterRule(_localctx, 78, PathParser.RULE_nameSegment)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(295)
		 	try _errHandler.sync(self)
		 	switch (PathParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .OPEN_BRACKET:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(289)
		 		try match(PathParser.Tokens.OPEN_BRACKET.rawValue)
		 		setState(290)
		 		try nameSelector()
		 		setState(291)
		 		try match(PathParser.Tokens.CLOSE_BRACKET.rawValue)

		 		break

		 	case .MEMBER_ACC:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(293)
		 		try match(PathParser.Tokens.MEMBER_ACC.rawValue)
		 		setState(294)
		 		try memberNameShorthand()

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class IndexSegmentContext: ParserRuleContext {
			open
			func OPEN_BRACKET() -> TerminalNode? {
				return getToken(PathParser.Tokens.OPEN_BRACKET.rawValue, 0)
			}
			open
			func indexSelector() -> IndexSelectorContext? {
				return getRuleContext(IndexSelectorContext.self, 0)
			}
			open
			func CLOSE_BRACKET() -> TerminalNode? {
				return getToken(PathParser.Tokens.CLOSE_BRACKET.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_indexSegment
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterIndexSegment(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitIndexSegment(self)
			}
		}
	}
	@discardableResult
	 open func indexSegment() throws -> IndexSegmentContext {
		var _localctx: IndexSegmentContext
		_localctx = IndexSegmentContext(_ctx, getState())
		try enterRule(_localctx, 80, PathParser.RULE_indexSegment)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(297)
		 	try match(PathParser.Tokens.OPEN_BRACKET.rawValue)
		 	setState(298)
		 	try indexSelector()
		 	setState(299)
		 	try match(PathParser.Tokens.CLOSE_BRACKET.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class StringLiteralContext: ParserRuleContext {
			open
			func SQ_STRING() -> TerminalNode? {
				return getToken(PathParser.Tokens.SQ_STRING.rawValue, 0)
			}
			open
			func DQ_STRING() -> TerminalNode? {
				return getToken(PathParser.Tokens.DQ_STRING.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_stringLiteral
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterStringLiteral(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitStringLiteral(self)
			}
		}
	}
	@discardableResult
	 open func stringLiteral() throws -> StringLiteralContext {
		var _localctx: StringLiteralContext
		_localctx = StringLiteralContext(_ctx, getState())
		try enterRule(_localctx, 82, PathParser.RULE_stringLiteral)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(301)
		 	_la = try _input.LA(1)
		 	if (!(_la == PathParser.Tokens.SQ_STRING.rawValue || _la == PathParser.Tokens.DQ_STRING.rawValue)) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class FunctionNameContext: ParserRuleContext {
			open
			func FUNC_NAME() -> TerminalNode? {
				return getToken(PathParser.Tokens.FUNC_NAME.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_functionName
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterFunctionName(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitFunctionName(self)
			}
		}
	}
	@discardableResult
	 open func functionName() throws -> FunctionNameContext {
		var _localctx: FunctionNameContext
		_localctx = FunctionNameContext(_ctx, getState())
		try enterRule(_localctx, 84, PathParser.RULE_functionName)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(303)
		 	try match(PathParser.Tokens.FUNC_NAME.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class FunctionExprContext: ParserRuleContext {
			open
			func functionName() -> FunctionNameContext? {
				return getRuleContext(FunctionNameContext.self, 0)
			}
			open
			func OPEN_PAREN() -> TerminalNode? {
				return getToken(PathParser.Tokens.OPEN_PAREN.rawValue, 0)
			}
			open
			func s() -> [SContext] {
				return getRuleContexts(SContext.self)
			}
			open
			func s(_ i: Int) -> SContext? {
				return getRuleContext(SContext.self, i)
			}
			open
			func CLOSE_PAREN() -> TerminalNode? {
				return getToken(PathParser.Tokens.CLOSE_PAREN.rawValue, 0)
			}
			open
			func functionArgument() -> [FunctionArgumentContext] {
				return getRuleContexts(FunctionArgumentContext.self)
			}
			open
			func functionArgument(_ i: Int) -> FunctionArgumentContext? {
				return getRuleContext(FunctionArgumentContext.self, i)
			}
			open
			func COMMA() -> [TerminalNode] {
				return getTokens(PathParser.Tokens.COMMA.rawValue)
			}
			open
			func COMMA(_ i:Int) -> TerminalNode? {
				return getToken(PathParser.Tokens.COMMA.rawValue, i)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_functionExpr
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterFunctionExpr(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitFunctionExpr(self)
			}
		}
	}
	@discardableResult
	 open func functionExpr() throws -> FunctionExprContext {
		var _localctx: FunctionExprContext
		_localctx = FunctionExprContext(_ctx, getState())
		try enterRule(_localctx, 86, PathParser.RULE_functionExpr)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt:Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(305)
		 	try functionName()
		 	setState(306)
		 	try match(PathParser.Tokens.OPEN_PAREN.rawValue)
		 	setState(307)
		 	try s()
		 	setState(319)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & 56564402182) != 0)) {
		 		setState(308)
		 		try functionArgument()
		 		setState(316)
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input,23,_ctx)
		 		while (_alt != 2 && _alt != ATN.INVALID_ALT_NUMBER) {
		 			if ( _alt==1 ) {
		 				setState(309)
		 				try s()
		 				setState(310)
		 				try match(PathParser.Tokens.COMMA.rawValue)
		 				setState(311)
		 				try s()
		 				setState(312)
		 				try functionArgument()

		 		 
		 			}
		 			setState(318)
		 			try _errHandler.sync(self)
		 			_alt = try getInterpreter().adaptivePredict(_input,23,_ctx)
		 		}

		 	}

		 	setState(321)
		 	try s()
		 	setState(322)
		 	try match(PathParser.Tokens.CLOSE_PAREN.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class FunctionArgumentContext: ParserRuleContext {
			open
			func literal() -> LiteralContext? {
				return getRuleContext(LiteralContext.self, 0)
			}
			open
			func functionExpr() -> FunctionExprContext? {
				return getRuleContext(FunctionExprContext.self, 0)
			}
			open
			func filterQuery() -> FilterQueryContext? {
				return getRuleContext(FilterQueryContext.self, 0)
			}
			open
			func logicalExpr() -> LogicalExprContext? {
				return getRuleContext(LogicalExprContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_functionArgument
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterFunctionArgument(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitFunctionArgument(self)
			}
		}
	}
	@discardableResult
	 open func functionArgument() throws -> FunctionArgumentContext {
		var _localctx: FunctionArgumentContext
		_localctx = FunctionArgumentContext(_ctx, getState())
		try enterRule(_localctx, 88, PathParser.RULE_functionArgument)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(328)
		 	try _errHandler.sync(self)
		 	switch(try getInterpreter().adaptivePredict(_input,25, _ctx)) {
		 	case 1:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(324)
		 		try literal()

		 		break
		 	case 2:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(325)
		 		try functionExpr()

		 		break
		 	case 3:
		 		try enterOuterAlt(_localctx, 3)
		 		setState(326)
		 		try filterQuery()

		 		break
		 	case 4:
		 		try enterOuterAlt(_localctx, 4)
		 		setState(327)
		 		try logicalExpr()

		 		break
		 	default: break
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SContext: ParserRuleContext {
			open
			func BLANK() -> [TerminalNode] {
				return getTokens(PathParser.Tokens.BLANK.rawValue)
			}
			open
			func BLANK(_ i:Int) -> TerminalNode? {
				return getToken(PathParser.Tokens.BLANK.rawValue, i)
			}
		override open
		func getRuleIndex() -> Int {
			return PathParser.RULE_s
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.enterS(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? PathListener {
				listener.exitS(self)
			}
		}
	}
	@discardableResult
	 open func s() throws -> SContext {
		var _localctx: SContext
		_localctx = SContext(_ctx, getState())
		try enterRule(_localctx, 90, PathParser.RULE_s)
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt:Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(333)
		 	try _errHandler.sync(self)
		 	_alt = try getInterpreter().adaptivePredict(_input,26,_ctx)
		 	while (_alt != 2 && _alt != ATN.INVALID_ALT_NUMBER) {
		 		if ( _alt==1 ) {
		 			setState(330)
		 			try match(PathParser.Tokens.BLANK.rawValue)

		 	 
		 		}
		 		setState(335)
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input,26,_ctx)
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	static let _serializedATN:[Int] = [
		4,1,35,337,2,0,7,0,2,1,7,1,2,2,7,2,2,3,7,3,2,4,7,4,2,5,7,5,2,6,7,6,2,7,
		7,7,2,8,7,8,2,9,7,9,2,10,7,10,2,11,7,11,2,12,7,12,2,13,7,13,2,14,7,14,
		2,15,7,15,2,16,7,16,2,17,7,17,2,18,7,18,2,19,7,19,2,20,7,20,2,21,7,21,
		2,22,7,22,2,23,7,23,2,24,7,24,2,25,7,25,2,26,7,26,2,27,7,27,2,28,7,28,
		2,29,7,29,2,30,7,30,2,31,7,31,2,32,7,32,2,33,7,33,2,34,7,34,2,35,7,35,
		2,36,7,36,2,37,7,37,2,38,7,38,2,39,7,39,2,40,7,40,2,41,7,41,2,42,7,42,
		2,43,7,43,2,44,7,44,2,45,7,45,1,0,1,0,1,0,1,0,1,1,5,1,98,8,1,10,1,12,1,
		101,9,1,1,2,1,2,3,2,105,8,2,1,3,1,3,1,3,1,3,3,3,111,8,3,3,3,113,8,3,1,
		4,1,4,1,4,1,4,3,4,119,8,4,1,5,1,5,1,5,1,5,1,5,3,5,126,8,5,1,6,1,6,1,7,
		1,7,1,8,1,8,1,9,1,9,1,10,1,10,1,10,1,10,1,11,1,11,1,12,1,12,1,13,1,13,
		1,13,3,13,147,8,13,1,13,1,13,1,13,1,13,1,13,3,13,154,8,13,1,13,1,13,1,
		13,1,13,3,13,160,8,13,1,14,1,14,1,15,1,15,1,16,1,16,1,17,1,17,1,17,1,17,
		1,17,1,17,1,17,1,17,5,17,176,8,17,10,17,12,17,179,9,17,1,17,1,17,1,17,
		1,18,1,18,1,19,1,19,1,19,1,19,1,19,1,19,5,19,192,8,19,10,19,12,19,195,
		9,19,1,20,1,20,1,20,1,20,1,20,1,20,5,20,203,8,20,10,20,12,20,206,9,20,
		1,21,1,21,1,21,3,21,211,8,21,1,22,1,22,1,22,3,22,216,8,22,1,22,1,22,1,
		22,1,22,1,22,1,22,1,23,1,23,1,24,1,24,1,24,3,24,229,8,24,1,24,1,24,3,24,
		233,8,24,1,25,1,25,3,25,237,8,25,1,26,1,26,1,26,1,27,1,27,1,27,1,27,1,
		27,1,27,1,28,1,28,1,28,1,28,1,28,3,28,253,8,28,1,29,1,29,1,30,1,30,1,31,
		1,31,1,32,1,32,1,33,1,33,1,33,3,33,266,8,33,1,34,1,34,1,35,1,35,3,35,272,
		8,35,1,36,1,36,1,36,1,37,1,37,1,37,1,38,1,38,1,38,3,38,283,8,38,5,38,285,
		8,38,10,38,12,38,288,9,38,1,39,1,39,1,39,1,39,1,39,1,39,3,39,296,8,39,
		1,40,1,40,1,40,1,40,1,41,1,41,1,42,1,42,1,43,1,43,1,43,1,43,1,43,1,43,
		1,43,1,43,1,43,5,43,315,8,43,10,43,12,43,318,9,43,3,43,320,8,43,1,43,1,
		43,1,43,1,44,1,44,1,44,1,44,3,44,329,8,44,1,45,5,45,332,8,45,10,45,12,
		45,335,9,45,1,45,0,0,46,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,
		34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,
		82,84,86,88,90,0,4,2,0,23,25,32,33,1,0,23,24,1,0,17,22,1,0,34,35,328,0,
		92,1,0,0,0,2,99,1,0,0,0,4,104,1,0,0,0,6,112,1,0,0,0,8,114,1,0,0,0,10,125,
		1,0,0,0,12,127,1,0,0,0,14,129,1,0,0,0,16,131,1,0,0,0,18,133,1,0,0,0,20,
		135,1,0,0,0,22,139,1,0,0,0,24,141,1,0,0,0,26,146,1,0,0,0,28,161,1,0,0,
		0,30,163,1,0,0,0,32,165,1,0,0,0,34,167,1,0,0,0,36,183,1,0,0,0,38,185,1,
		0,0,0,40,196,1,0,0,0,42,210,1,0,0,0,44,215,1,0,0,0,46,223,1,0,0,0,48,228,
		1,0,0,0,50,236,1,0,0,0,52,238,1,0,0,0,54,241,1,0,0,0,56,252,1,0,0,0,58,
		254,1,0,0,0,60,256,1,0,0,0,62,258,1,0,0,0,64,260,1,0,0,0,66,265,1,0,0,
		0,68,267,1,0,0,0,70,271,1,0,0,0,72,273,1,0,0,0,74,276,1,0,0,0,76,286,1,
		0,0,0,78,295,1,0,0,0,80,297,1,0,0,0,82,301,1,0,0,0,84,303,1,0,0,0,86,305,
		1,0,0,0,88,328,1,0,0,0,90,333,1,0,0,0,92,93,5,1,0,0,93,94,3,2,1,0,94,95,
		5,0,0,1,95,1,1,0,0,0,96,98,3,4,2,0,97,96,1,0,0,0,98,101,1,0,0,0,99,97,
		1,0,0,0,99,100,1,0,0,0,100,3,1,0,0,0,101,99,1,0,0,0,102,105,3,6,3,0,103,
		105,3,8,4,0,104,102,1,0,0,0,104,103,1,0,0,0,105,5,1,0,0,0,106,113,3,34,
		17,0,107,110,5,3,0,0,108,111,3,14,7,0,109,111,3,22,11,0,110,108,1,0,0,
		0,110,109,1,0,0,0,111,113,1,0,0,0,112,106,1,0,0,0,112,107,1,0,0,0,113,
		7,1,0,0,0,114,118,5,4,0,0,115,119,3,34,17,0,116,119,3,14,7,0,117,119,3,
		22,11,0,118,115,1,0,0,0,118,116,1,0,0,0,118,117,1,0,0,0,119,9,1,0,0,0,
		120,126,3,12,6,0,121,126,3,14,7,0,122,126,3,16,8,0,123,126,3,18,9,0,124,
		126,3,20,10,0,125,120,1,0,0,0,125,121,1,0,0,0,125,122,1,0,0,0,125,123,
		1,0,0,0,125,124,1,0,0,0,126,11,1,0,0,0,127,128,3,82,41,0,128,13,1,0,0,
		0,129,130,5,5,0,0,130,15,1,0,0,0,131,132,5,27,0,0,132,17,1,0,0,0,133,134,
		3,26,13,0,134,19,1,0,0,0,135,136,5,6,0,0,136,137,3,90,45,0,137,138,3,36,
		18,0,138,21,1,0,0,0,139,140,3,24,12,0,140,23,1,0,0,0,141,142,7,0,0,0,142,
		25,1,0,0,0,143,144,3,28,14,0,144,145,3,90,45,0,145,147,1,0,0,0,146,143,
		1,0,0,0,146,147,1,0,0,0,147,148,1,0,0,0,148,149,5,7,0,0,149,153,3,90,45,
		0,150,151,3,30,15,0,151,152,3,90,45,0,152,154,1,0,0,0,153,150,1,0,0,0,
		153,154,1,0,0,0,154,159,1,0,0,0,155,156,5,7,0,0,156,157,3,90,45,0,157,
		158,3,32,16,0,158,160,1,0,0,0,159,155,1,0,0,0,159,160,1,0,0,0,160,27,1,
		0,0,0,161,162,5,27,0,0,162,29,1,0,0,0,163,164,5,27,0,0,164,31,1,0,0,0,
		165,166,5,27,0,0,166,33,1,0,0,0,167,168,5,9,0,0,168,169,3,90,45,0,169,
		177,3,10,5,0,170,171,3,90,45,0,171,172,5,13,0,0,172,173,3,90,45,0,173,
		174,3,10,5,0,174,176,1,0,0,0,175,170,1,0,0,0,176,179,1,0,0,0,177,175,1,
		0,0,0,177,178,1,0,0,0,178,180,1,0,0,0,179,177,1,0,0,0,180,181,3,90,45,
		0,181,182,5,10,0,0,182,35,1,0,0,0,183,184,3,38,19,0,184,37,1,0,0,0,185,
		193,3,40,20,0,186,187,3,90,45,0,187,188,5,16,0,0,188,189,3,90,45,0,189,
		190,3,40,20,0,190,192,1,0,0,0,191,186,1,0,0,0,192,195,1,0,0,0,193,191,
		1,0,0,0,193,194,1,0,0,0,194,39,1,0,0,0,195,193,1,0,0,0,196,204,3,42,21,
		0,197,198,3,90,45,0,198,199,5,15,0,0,199,200,3,90,45,0,200,201,3,42,21,
		0,201,203,1,0,0,0,202,197,1,0,0,0,203,206,1,0,0,0,204,202,1,0,0,0,204,
		205,1,0,0,0,205,41,1,0,0,0,206,204,1,0,0,0,207,211,3,44,22,0,208,211,3,
		54,27,0,209,211,3,48,24,0,210,207,1,0,0,0,210,208,1,0,0,0,210,209,1,0,
		0,0,211,43,1,0,0,0,212,213,3,46,23,0,213,214,3,90,45,0,214,216,1,0,0,0,
		215,212,1,0,0,0,215,216,1,0,0,0,216,217,1,0,0,0,217,218,5,11,0,0,218,219,
		3,90,45,0,219,220,3,36,18,0,220,221,3,90,45,0,221,222,5,12,0,0,222,45,
		1,0,0,0,223,224,5,14,0,0,224,47,1,0,0,0,225,226,3,46,23,0,226,227,3,90,
		45,0,227,229,1,0,0,0,228,225,1,0,0,0,228,229,1,0,0,0,229,232,1,0,0,0,230,
		233,3,50,25,0,231,233,3,86,43,0,232,230,1,0,0,0,232,231,1,0,0,0,233,49,
		1,0,0,0,234,237,3,52,26,0,235,237,3,0,0,0,236,234,1,0,0,0,236,235,1,0,
		0,0,237,51,1,0,0,0,238,239,5,2,0,0,239,240,3,2,1,0,240,53,1,0,0,0,241,
		242,3,66,33,0,242,243,3,90,45,0,243,244,3,68,34,0,244,245,3,90,45,0,245,
		246,3,66,33,0,246,55,1,0,0,0,247,253,3,58,29,0,248,253,3,60,30,0,249,253,
		3,62,31,0,250,253,3,64,32,0,251,253,3,82,41,0,252,247,1,0,0,0,252,248,
		1,0,0,0,252,249,1,0,0,0,252,250,1,0,0,0,252,251,1,0,0,0,253,57,1,0,0,0,
		254,255,5,25,0,0,255,59,1,0,0,0,256,257,7,1,0,0,257,61,1,0,0,0,258,259,
		5,27,0,0,259,63,1,0,0,0,260,261,5,29,0,0,261,65,1,0,0,0,262,266,3,56,28,
		0,263,266,3,70,35,0,264,266,3,86,43,0,265,262,1,0,0,0,265,263,1,0,0,0,
		265,264,1,0,0,0,266,67,1,0,0,0,267,268,7,2,0,0,268,69,1,0,0,0,269,272,
		3,72,36,0,270,272,3,74,37,0,271,269,1,0,0,0,271,270,1,0,0,0,272,71,1,0,
		0,0,273,274,5,2,0,0,274,275,3,76,38,0,275,73,1,0,0,0,276,277,5,1,0,0,277,
		278,3,76,38,0,278,75,1,0,0,0,279,282,3,90,45,0,280,283,3,78,39,0,281,283,
		3,80,40,0,282,280,1,0,0,0,282,281,1,0,0,0,283,285,1,0,0,0,284,279,1,0,
		0,0,285,288,1,0,0,0,286,284,1,0,0,0,286,287,1,0,0,0,287,77,1,0,0,0,288,
		286,1,0,0,0,289,290,5,9,0,0,290,291,3,12,6,0,291,292,5,10,0,0,292,296,
		1,0,0,0,293,294,5,3,0,0,294,296,3,22,11,0,295,289,1,0,0,0,295,293,1,0,
		0,0,296,79,1,0,0,0,297,298,5,9,0,0,298,299,3,16,8,0,299,300,5,10,0,0,300,
		81,1,0,0,0,301,302,7,3,0,0,302,83,1,0,0,0,303,304,5,32,0,0,304,85,1,0,
		0,0,305,306,3,84,42,0,306,307,5,11,0,0,307,319,3,90,45,0,308,316,3,88,
		44,0,309,310,3,90,45,0,310,311,5,13,0,0,311,312,3,90,45,0,312,313,3,88,
		44,0,313,315,1,0,0,0,314,309,1,0,0,0,315,318,1,0,0,0,316,314,1,0,0,0,316,
		317,1,0,0,0,317,320,1,0,0,0,318,316,1,0,0,0,319,308,1,0,0,0,319,320,1,
		0,0,0,320,321,1,0,0,0,321,322,3,90,45,0,322,323,5,12,0,0,323,87,1,0,0,
		0,324,329,3,56,28,0,325,329,3,86,43,0,326,329,3,50,25,0,327,329,3,36,18,
		0,328,324,1,0,0,0,328,325,1,0,0,0,328,326,1,0,0,0,328,327,1,0,0,0,329,
		89,1,0,0,0,330,332,5,26,0,0,331,330,1,0,0,0,332,335,1,0,0,0,333,331,1,
		0,0,0,333,334,1,0,0,0,334,91,1,0,0,0,335,333,1,0,0,0,27,99,104,110,112,
		118,125,146,153,159,177,193,204,210,215,228,232,236,252,265,271,282,286,
		295,316,319,328,333
	]

	public
	static let _ATN = try! ATNDeserializer().deserialize(_serializedATN)
}
