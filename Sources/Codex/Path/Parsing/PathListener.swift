// Generated from Sources/Codex/PathParsing/Path.g4 by ANTLR 4.13.2
import Antlr4

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link PathParser}.
 */
public protocol PathListener: ParseTreeListener {
	/**
	 * Enter a parse tree produced by {@link PathParser#pathQuery}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterPathQuery(_ ctx: PathParser.PathQueryContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#pathQuery}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitPathQuery(_ ctx: PathParser.PathQueryContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#segments}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSegments(_ ctx: PathParser.SegmentsContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#segments}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSegments(_ ctx: PathParser.SegmentsContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#segment}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSegment(_ ctx: PathParser.SegmentContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#segment}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSegment(_ ctx: PathParser.SegmentContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#childSegment}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterChildSegment(_ ctx: PathParser.ChildSegmentContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#childSegment}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitChildSegment(_ ctx: PathParser.ChildSegmentContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#descendantSegment}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterDescendantSegment(_ ctx: PathParser.DescendantSegmentContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#descendantSegment}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitDescendantSegment(_ ctx: PathParser.DescendantSegmentContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#selector}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSelector(_ ctx: PathParser.SelectorContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#selector}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSelector(_ ctx: PathParser.SelectorContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#nameSelector}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterNameSelector(_ ctx: PathParser.NameSelectorContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#nameSelector}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitNameSelector(_ ctx: PathParser.NameSelectorContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#wildcardSelector}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterWildcardSelector(_ ctx: PathParser.WildcardSelectorContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#wildcardSelector}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitWildcardSelector(_ ctx: PathParser.WildcardSelectorContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#indexSelector}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterIndexSelector(_ ctx: PathParser.IndexSelectorContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#indexSelector}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitIndexSelector(_ ctx: PathParser.IndexSelectorContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#sliceSelector}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSliceSelector(_ ctx: PathParser.SliceSelectorContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#sliceSelector}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSliceSelector(_ ctx: PathParser.SliceSelectorContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#filterSelector}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterFilterSelector(_ ctx: PathParser.FilterSelectorContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#filterSelector}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitFilterSelector(_ ctx: PathParser.FilterSelectorContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#memberNameShorthand}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterMemberNameShorthand(_ ctx: PathParser.MemberNameShorthandContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#memberNameShorthand}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitMemberNameShorthand(_ ctx: PathParser.MemberNameShorthandContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#name}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterName(_ ctx: PathParser.NameContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#name}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitName(_ ctx: PathParser.NameContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#slice}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSlice(_ ctx: PathParser.SliceContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#slice}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSlice(_ ctx: PathParser.SliceContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#start}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterStart(_ ctx: PathParser.StartContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#start}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitStart(_ ctx: PathParser.StartContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#end}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterEnd(_ ctx: PathParser.EndContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#end}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitEnd(_ ctx: PathParser.EndContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#step}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterStep(_ ctx: PathParser.StepContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#step}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitStep(_ ctx: PathParser.StepContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#bracketedSelection}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterBracketedSelection(_ ctx: PathParser.BracketedSelectionContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#bracketedSelection}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitBracketedSelection(_ ctx: PathParser.BracketedSelectionContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#logicalExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterLogicalExpr(_ ctx: PathParser.LogicalExprContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#logicalExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitLogicalExpr(_ ctx: PathParser.LogicalExprContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#logicalOrExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterLogicalOrExpr(_ ctx: PathParser.LogicalOrExprContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#logicalOrExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitLogicalOrExpr(_ ctx: PathParser.LogicalOrExprContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#logicalAndExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterLogicalAndExpr(_ ctx: PathParser.LogicalAndExprContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#logicalAndExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitLogicalAndExpr(_ ctx: PathParser.LogicalAndExprContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#basicExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterBasicExpr(_ ctx: PathParser.BasicExprContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#basicExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitBasicExpr(_ ctx: PathParser.BasicExprContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#parenExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterParenExpr(_ ctx: PathParser.ParenExprContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#parenExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitParenExpr(_ ctx: PathParser.ParenExprContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#logicalNotOp}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterLogicalNotOp(_ ctx: PathParser.LogicalNotOpContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#logicalNotOp}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitLogicalNotOp(_ ctx: PathParser.LogicalNotOpContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#testExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterTestExpr(_ ctx: PathParser.TestExprContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#testExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitTestExpr(_ ctx: PathParser.TestExprContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#filterQuery}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterFilterQuery(_ ctx: PathParser.FilterQueryContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#filterQuery}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitFilterQuery(_ ctx: PathParser.FilterQueryContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#relQuery}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterRelQuery(_ ctx: PathParser.RelQueryContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#relQuery}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitRelQuery(_ ctx: PathParser.RelQueryContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#comparisonExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterComparisonExpr(_ ctx: PathParser.ComparisonExprContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#comparisonExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitComparisonExpr(_ ctx: PathParser.ComparisonExprContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#literal}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterLiteral(_ ctx: PathParser.LiteralContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#literal}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitLiteral(_ ctx: PathParser.LiteralContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#nullLiteral}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterNullLiteral(_ ctx: PathParser.NullLiteralContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#nullLiteral}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitNullLiteral(_ ctx: PathParser.NullLiteralContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#boolLiteral}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterBoolLiteral(_ ctx: PathParser.BoolLiteralContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#boolLiteral}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitBoolLiteral(_ ctx: PathParser.BoolLiteralContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#intLiteral}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterIntLiteral(_ ctx: PathParser.IntLiteralContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#intLiteral}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitIntLiteral(_ ctx: PathParser.IntLiteralContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#numLiteral}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterNumLiteral(_ ctx: PathParser.NumLiteralContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#numLiteral}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitNumLiteral(_ ctx: PathParser.NumLiteralContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#comparable}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterComparable(_ ctx: PathParser.ComparableContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#comparable}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitComparable(_ ctx: PathParser.ComparableContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#comparisonOp}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterComparisonOp(_ ctx: PathParser.ComparisonOpContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#comparisonOp}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitComparisonOp(_ ctx: PathParser.ComparisonOpContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#singularQuery}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSingularQuery(_ ctx: PathParser.SingularQueryContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#singularQuery}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSingularQuery(_ ctx: PathParser.SingularQueryContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#relSingularQuery}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterRelSingularQuery(_ ctx: PathParser.RelSingularQueryContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#relSingularQuery}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitRelSingularQuery(_ ctx: PathParser.RelSingularQueryContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#absSingularQuery}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterAbsSingularQuery(_ ctx: PathParser.AbsSingularQueryContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#absSingularQuery}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitAbsSingularQuery(_ ctx: PathParser.AbsSingularQueryContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#singularQuerySegments}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSingularQuerySegments(_ ctx: PathParser.SingularQuerySegmentsContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#singularQuerySegments}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSingularQuerySegments(_ ctx: PathParser.SingularQuerySegmentsContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#nameSegment}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterNameSegment(_ ctx: PathParser.NameSegmentContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#nameSegment}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitNameSegment(_ ctx: PathParser.NameSegmentContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#indexSegment}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterIndexSegment(_ ctx: PathParser.IndexSegmentContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#indexSegment}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitIndexSegment(_ ctx: PathParser.IndexSegmentContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#stringLiteral}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterStringLiteral(_ ctx: PathParser.StringLiteralContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#stringLiteral}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitStringLiteral(_ ctx: PathParser.StringLiteralContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#functionName}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterFunctionName(_ ctx: PathParser.FunctionNameContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#functionName}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitFunctionName(_ ctx: PathParser.FunctionNameContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#functionExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterFunctionExpr(_ ctx: PathParser.FunctionExprContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#functionExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitFunctionExpr(_ ctx: PathParser.FunctionExprContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#functionArgument}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterFunctionArgument(_ ctx: PathParser.FunctionArgumentContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#functionArgument}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitFunctionArgument(_ ctx: PathParser.FunctionArgumentContext)
	/**
	 * Enter a parse tree produced by {@link PathParser#s}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterS(_ ctx: PathParser.SContext)
	/**
	 * Exit a parse tree produced by {@link PathParser#s}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitS(_ ctx: PathParser.SContext)
}