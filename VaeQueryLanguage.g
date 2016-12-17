grammar VaeQueryLanguage;
options {
  language = C;
  output = AST;
}

tokens {
  NODE_ABSOLUTE ;
  NODE_FUNCTION ;
  NODE_IF ;
  NODE_PARENEXPR ;
	NODE_PATH ;
	NODE_PATHREF ;
	NODE_PREDICATE ;
	NODE_SQL ;
	NODE_STAR ;
	NODE_VALUE ;
  NODE_XPATHFUNCTION ;

  SPECIAL_NEXT = 'next()' ;
  SPECIAL_PREV = 'prev()' ;

	DIV = '//' ;
	MULT = '**' ;
	SLASH = '/' ;
	STAR = '*' ;
	SQL = '~' ;
	AT = '@' ;

	XPATH_AXIS_SEP = '::' ;
	EQUALITY = '==' ;
	EQUALITY_ALT = '=' ;
	INEQUALITY = '!=' ;
	INEQUALITY_ALT = '<>' ;
	LESS = '<' ;
	LTE = '<=' ;
	GREATER = '>' ;
	GTE = '>=' ;
	AND = '&&' ;
	OR = '||' ;
	XOR = '^' ;
	NOT = '!' ;
	ADD_TOK = '+' ;
	SUB = '-' ;
	MOD = '%';

	PIPE = '|';

	IFTRUE = '?' ;
	COLON = ':' ;
	PATHREF = '&' ;

	LBRACKET = '[' ;
	RBRACKET = ']' ;
	LPAREN = '(' ;
	RPAREN = ')' ;
	COMMA = ',' ;
}

/*------------------------------------------------------------------
 * PARSER RULES
 *------------------------------------------------------------------*/

start
	:	expr EOF -> ^(expr)
	;

expr
  : orExpr
	;

orExpr
  : xorExpr (orOper^ xorExpr)*
  ;

xorExpr
  : andExpr (xorOper^ andExpr)*
  ;

andExpr
  : comparisonExpr (andOper^ comparisonExpr)*
  ;

comparisonExpr
  : addSubExpr (comparisonOper^ addSubExpr)*
  ;

addSubExpr
  : multExpr (addSubOper^ multExpr)*
  ;

multExpr
  : ifExpr (multOper^ ifExpr)*
  ;

ifExpr
	: e1=notExpr (IFTRUE^ notExpr COLON! notExpr)?
	;

notExpr
	: NOT valueExpr -> ^(NOT valueExpr)
	| valueExpr
	;

valueExpr
	: (LPAREN expr RPAREN) -> ^(expr)
	|	(path | value | function)
	;

function
	: FUNCTION expressionList RPAREN -> ^(NODE_FUNCTION FUNCTION expressionList)
	;

expressionList
  : expr? ( COMMA^ expr )*
  ;

functionNoArgs
  : FUNCTION RPAREN -> ^(NODE_FUNCTION FUNCTION)
  ;

path
  : rootPath -> ^(NODE_PATH rootPath)
	|	SQL pathStep -> ^(NODE_SQL pathStep)
	| SPECIAL_PREV -> ^(NODE_PATH SPECIAL_PREV)
	| SPECIAL_NEXT -> ^(NODE_PATH SPECIAL_NEXT)
  ;

rootPath
  : unionPath
  | idPath
  | absolutePath
  | permalink
  ;

permalink
  : AT PERMALINK -> ^(AT PERMALINK)
  | PERMALINK
  ;

absolutePath
  : AT SLASH unionPath? -> ^(AT ^(NODE_ABSOLUTE unionPath))
  | SLASH unionPath? -> ^(NODE_ABSOLUTE unionPath)
  ;

idPath
	: AT^? (INT | variable | functionNoArgs) SLASH^ relativePath
	| AT^ (INT | variable | functionNoArgs)
	;

relativePath
  : pathStep (SLASH^ pathStepInternal)*
  ;

relativePathWithoutPredicates
  : (NAME | DOT_STEP) (SLASH^ (NAME | DOT_STEP))*
  ;

unionPath
  : relativePath (PIPE^ relativePath)*
  ;

pathStep
  : ( axisSpecifier^? (NAME | DOT_STEP | STAR) ) predicate^*
  ;

pathStepInternal
  : INT
  | variable
  | function
  | pathStep
  ;

axisSpecifier
  : XPATH_AXES XPATH_AXIS_SEP^
  | AT^
  ;

predicate
  : LBRACKET predicateExpr RBRACKET -> ^(NODE_PREDICATE predicateExpr)
  ;

predicateExpr
  : predicateAndExpr (orOper^ predicateAndExpr)*
  | relativePathWithoutPredicates COLON^ function
  | INT
  ;

predicateAndExpr
  : predicateComparisonExpr (andOper^ predicateComparisonExpr)?
  ;

predicateComparisonExpr
  : predicatePathExpr comparisonOper^ predicatePathExpr
  ;

predicatePathExpr
  : unionPath
  | PATHREF unionPath -> ^(NODE_PATHREF ^(NODE_PATH unionPath))
  | filterExpr (SLASH^ relativePath)?
  ;

filterExpr
  : primaryExpr predicate?
  ;

primaryExpr
  : LPAREN predicateExpr RPAREN -> ^(NODE_PARENEXPR predicateExpr)
  | value
  | function
  | xpathFunction
  ;

xpathFunction
	: XPATH_FUNCTION expressionList RPAREN -> ^(NODE_XPATHFUNCTION XPATH_FUNCTION expressionList)
  ;

andOper
  : AND | AND_ALT
  ;

orOper
  : OR | OR_ALT
  ;

xorOper
  : XOR | XOR_ALT
  ;

value
	:	variable
	| STRING -> ^(NODE_VALUE STRING)
	| INT -> ^(NODE_VALUE INT)
	| FLOAT -> ^(NODE_VALUE FLOAT)
	;

variable
  : VARIABLE -> ^(NODE_VALUE VARIABLE)
  ;

comparisonOper
	:	EQUALITY | EQUALITY_ALT | INEQUALITY | INEQUALITY_ALT | LESS | LTE | GREATER | GTE
	;

addSubOper
	:	ADD_TOK | SUB
	;

multOper
  : MULT | DIV | MOD
	;

/*------------------------------------------------------------------
 * LEXER RULES
 *------------------------------------------------------------------*/

STRING
  :  ('"' (~('\\'|'"') | ESC_SEQ)* '"')
  |  ('\'' (~('\\'|'\'') | ESC_SEQ)* '\'')
  ;

PERMALINK
  : 'permalink/' ('a'..'z'|'A'..'Z'|'0'..'9'|'-'|'_'|'/'|'.')*
  ;

FLOAT
  : ('0'..'9')+ '.' ('0'..'9')*
  | '.' ('0'..'9')+
  ;

INT
  :	'0'..'9'+
  ;

VARIABLE
	:	'$' ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
  ;

XPATH_FUNCTION
  : 'node-name('
  | 'nilled('
  | 'data('
  | 'base-uri('
  | 'document-uri('
  | 'error('
  | 'trace('
  | 'number('
  | 'abs('
  | 'ceiling('
  | 'round('
  | 'round-half-to-even('
  | 'string('
  | 'codepoints-to-string('
  | 'string-to-codepoints('
  | 'codepoint-equal('
  | 'compare('
  | 'concat('
  | 'string-join('
  | 'substring('
  | 'string-length('
  | 'normalize-space('
  | 'normalize-unicode('
  | 'lower-case('
  | 'translate('
  | 'escape-uri('
  | 'contains('
  | 'starts-with('
  | 'ends-with('
  | 'substring-before('
  | 'substring-after('
  | 'matches('
  | 'replace('
  | 'tokenize('
  | 'resolve-uri('
  | 'boolean('
  | 'not('
  | 'true('
  | 'false('
  | 'dateTime('
  | 'years-from-duration('
  | 'months-from-duration('
  | 'days-from-duration('
  | 'hours-from-duration('
  | 'minutes-from-duration('
  | 'seconds-from-duration('
  | 'year-from-dateTime('
  | 'month-from-dateTime('
  | 'day-from-dateTime('
  | 'hours-from-dateTime('
  | 'minutes-from-dateTime('
  | 'seconds-from-dateTime('
  | 'timezone-from-dateTime('
  | 'year-from-date('
  | 'month-from-date('
  | 'day-from-date('
  | 'timezone-from-date('
  | 'hours-from-time('
  | 'minutes-from-time('
  | 'seconds-from-time('
  | 'timezone-from-time('
  | 'adjust-dateTime-to-timezone('
  | 'adjust-date-to-timezone('
  | 'adjust-time-to-timezone('
  | 'QName('
  | 'local-name-from-QName('
  | 'namespace-uri-from-QName('
  | 'namespace-uri-for-prefix('
  | 'in-scope-prefixes('
  | 'resolve-QName('
  | 'name('
  | 'local-name('
  | 'namespace-uri('
  | 'lang('
  | 'root('
  | 'index-of('
  | 'remove('
  | 'empty('
  | 'exists('
  | 'distinct-values('
  | 'insert-before('
  | 'reverse('
  | 'subsequence('
  | 'unordered('
  | 'zero-or-one('
  | 'one-or-mpre('
  | 'exactly-one('
  | 'deep-equal('
  | 'count('
  | 'avg('
  | 'max('
  | 'min('
  | 'sum('
  | 'id('
  | 'idref('
  | 'doc('
  | 'doc-available('
  | 'collection('
  | 'position('
  | 'last('
  | 'current-dateTime('
  | 'current-date('
  | 'current-time('
  | 'implicit-timezone('
  | 'default-collection('
  | 'static-base-uri('
  ;

FUNCTION
	:	('a'..'z'|'A'..'Z'|'0'..'9'|'_')+ '('
  ;

AND_ALT
	:	('A'|'a') ('N'|'n') ('D'|'d')
	;

OR_ALT
	:	('O'|'o') ('R'|'r')
	;

XOR_ALT
	:	('X'|'x') ('O'|'o') ('R'|'r')
	;

XPATH_AXES
  : 'ancestor'  | 'ancestor-or-self'  | 'attribute' |
    'child'     | 'descendant'        | 'descendant-or-self' |
    'following' | 'following-sibling' | 'namespace' |
    'parent'    | 'preceding'         | 'preceding-sibling' |
    'self'
  ;

NAME
  : ('a'..'z'|'_') ('a'..'z'|'0'..'9'|'_')*
  ;

DOT_STEP
  : '.' | '..'
  ;

WS
  : (' '|'\t'|'\r'|'\n') { $channel=HIDDEN; }
  ;

fragment
ESC_SEQ
  : '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
  ;
