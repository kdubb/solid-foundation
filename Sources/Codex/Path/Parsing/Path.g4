grammar Path;

@header {
// swift-format-ignore-file: AllPublicDeclarationsHaveDocumentation, BeginDocumentationCommentWithOneLineSummary, NoLeadingUnderscores, NeverForceUnwrap, NeverUseForceTry
}

pathQuery : ROOT segments EOF;

segments
  : segment*
  ;

segment
  : childSegment
  | descendantSegment
  ;

childSegment
  : bracketedSelection
  | MEMBER_ACC (wildcardSelector | memberNameShorthand)
  ;

descendantSegment
  : DESC_ACC (bracketedSelection | wildcardSelector | memberNameShorthand)
  ;

selector
  : nameSelector
  | wildcardSelector
  | indexSelector
  | sliceSelector
  | filterSelector
  ;

nameSelector
  : stringLiteral
  ;

wildcardSelector
  : WILDCARD
  ;

indexSelector
  : INT
  ;

sliceSelector
  : slice
  ;

filterSelector
  : FILTER s logicalExpr
  ;

memberNameShorthand
  : name
  ;

name
  : NAME
  | FUNC_NAME
  | TRUE | FALSE | NULL
  ;

slice
  : (start s)? COLON s (end s)? (COLON (s step))?
  ;

start
  : INT
  ;

end
  : INT
  ;

step
  : INT
  ;

bracketedSelection
  : OPEN_BRACKET s selector (s COMMA s selector)* s CLOSE_BRACKET
  ;

logicalExpr
  : logicalOrExpr
  ;

logicalOrExpr
  : logicalAndExpr (s LOGICAL_OR s logicalAndExpr)*
  ;

logicalAndExpr
  : basicExpr (s LOGICAL_AND s basicExpr)*
  ;

basicExpr
  : parenExpr
  | comparisonExpr
  | testExpr
  ;

parenExpr
  : (logicalNotOp s)? OPEN_PAREN s logicalExpr s CLOSE_PAREN
  ;

logicalNotOp
  : EXCLAMATION_MARK
  ;

testExpr
  : (logicalNotOp s)? (filterQuery | functionExpr)
  ;

filterQuery
  : relQuery
  | pathQuery
  ;

relQuery
  : CURRENT segments
  ;

comparisonExpr
  : comparable s comparisonOp s comparable
  ;

literal
  : nullLiteral
  | boolLiteral
  | intLiteral
  | numLiteral
  | stringLiteral
  ;

nullLiteral
  : NULL
  ;

boolLiteral
  : TRUE
  | FALSE
  ;

intLiteral
  : INT
  ;

numLiteral
  : NUMBER
  ;

comparable
  : literal
  | singularQuery
  | functionExpr
  ;

comparisonOp
  : CMP_EQ | CMP_NE | CMP_LT | CMP_LE | CMP_GT | CMP_GE
  ;

singularQuery
  : relSingularQuery
  | absSingularQuery
  ;

relSingularQuery
  : CURRENT singularQuerySegments
  ;

absSingularQuery
  : ROOT singularQuerySegments
  ;

singularQuerySegments
  : (s (nameSegment | indexSegment))*
  ;

nameSegment
  : OPEN_BRACKET nameSelector CLOSE_BRACKET
  | MEMBER_ACC memberNameShorthand
  ;

indexSegment
  : OPEN_BRACKET indexSelector CLOSE_BRACKET
  ;

stringLiteral
  : SQ_STRING
  | DQ_STRING
  ;

functionName
  : FUNC_NAME
  ;

functionExpr
  : functionName OPEN_PAREN s (functionArgument (s COMMA s functionArgument)*)? s CLOSE_PAREN
  ;

functionArgument
  : literal
  | functionExpr
  | filterQuery
  | logicalExpr
  ;

s : BLANK* ;


ROOT : '$';
CURRENT : '@' ;

MEMBER_ACC  : '.' ;
DESC_ACC : '..' ;

WILDCARD : '*' ;
FILTER : '?' ;

COLON : ':' ;
SEMI : ';' ;
OPEN_BRACKET : '[' ;
CLOSE_BRACKET : ']' ;
OPEN_PAREN : '(' ;
CLOSE_PAREN : ')' ;
COMMA : ',' ;

EXCLAMATION_MARK : '!' ;

LOGICAL_AND : '&&' ;
LOGICAL_OR : '||' ;

CMP_EQ : '==' ;
CMP_NE : '!=' ;
CMP_GT : '>' ;
CMP_GE : '>=' ;
CMP_LT : '<' ;
CMP_LE : '<=' ;

TRUE : 'true' ;
FALSE : 'false' ;
NULL : 'null' ;

BLANK : [ \t\r\n] ;

INT : '0' | ('-'? DIGIT1 DIGIT*);
DIGIT1 : [1-9];

// Number parts
NUMBER : (INT | '-0') FRAC? EXP?;
fragment FRAC: '.' DIGIT+;
fragment EXP: [eE] [+\-]? DIGIT+;

fragment HEXCHAR: NON_SURROGATE | HIGH_SURROGATE ESC 'u' LOW_SURROGATE;
fragment HEXDIGIT: [0-9A-Fa-f];
fragment NON_SURROGATE: (HEXDIGIT HEXDIGIT HEXDIGIT HEXDIGIT);
fragment HIGH_SURROGATE: 'D' [89AB] HEXDIGIT HEXDIGIT;
fragment LOW_SURROGATE: 'D' [CDEF] HEXDIGIT HEXDIGIT;


// Characters

fragment DIGIT: [0-9];
fragment ALPHA: [a-zA-Z];
fragment UNICODE_RANGE: [\u0080-\uD7FF\uE000-\u{10FFFF}];

fragment ESC
    : '\\'
    ;

fragment ESCAPABLE
    : 'b'
    | 'f'
    | 'n'
    | 'r'
    | 't'
    | '/'
    | '\\'
    | 'u' HEXCHAR
    ;

fragment UNESCAPED
    : '\u0020'..'\u0021'
    | '\u0023'..'\u0026'
    | '\u0028'..'\u005B'
    | '\u005D'..'\uD7FF'
    | '\uE000'..'\u{10FFFF}'
    ;

SQOT: '\'' ;
DQOT: '"' ;

fragment ESCAPABLE_CHAR
  : 'b'
  | 'f'
  | 'n'
  | 'r'
  | 't'
  | '/'
  | '\\'
  | 'u' HEXCHAR
  ;

fragment LCALPHA: [a-z];
fragment UCALPHA: [A-Z];

FUNC_NAME: FUNC_FIRST FUNC_CHAR*;

fragment FUNC_FIRST
  : LCALPHA
  ;

fragment FUNC_CHAR
  : FUNC_FIRST
  | '_'
  | DIGIT
  ;

NAME: NAME_FIRST NAME_CHAR* ;

fragment NAME_FIRST
  : ALPHA
  | '_'
  | '\u0080'..'\uD7FF'
  | '\uE000'..'\u{10FFFF}'
  ;

fragment NAME_CHAR
  : NAME_FIRST
  | DIGIT
  ;

fragment SQ_CHARS
  : UNESCAPED | DQOT | ESC SQOT | ESC ESCAPABLE
  ;

SQ_STRING
  : SQOT SQ_CHARS* SQOT
  ;

fragment DQ_CHARS
  : UNESCAPED | SQOT | ESC DQOT | ESC ESCAPABLE
  ;

DQ_STRING
  : DQOT DQ_CHARS* DQOT
  ;
