tree grammar VaeQueryLanguageTreeParser;

options 
{
  tokenVocab = VaeQueryLanguage;
  language = C;
  ASTLabelType = pANTLR3_BASE_TREE;
}

@header
{
#include "vaeql.h"
#define FUNCTION_ARG_LIST_SIZE 25
}

@members
{

  char *functionArgList[FUNCTION_ARG_LIST_SIZE+1];
  char functionArgCount;

  int asBoolean(pANTLR3_STRING a) {
    double dummy;
    if (!strlen(a->chars)) {
      return 0;
    }
    if (sscanf(a->chars, "\%lf", &dummy)) {
      return (dummy != 0);
    }
    return strcmp(a->chars, "");
  }
  
  int asInt(pANTLR3_STRING a) {
    return atoi(a->chars);
  }
  
  double asNumber(pANTLR3_STRING a) {
    return strtod(a->chars, NULL);
  }

  int bothNumbers(pANTLR3_STRING a, pANTLR3_STRING b) {
    double dummy;
    return (sscanf(a->chars, "\%lf", &dummy) && sscanf(b->chars, "\%lf", &dummy));
  }

  char *replace_str(char *str, char *orig, char *rep) {
    static char buffer[1024];
    char buffer2[1024];
    char *p, *b = buffer, *b2 = buffer2;
    strncpy(buffer, str, 1023);
    do {
      if(!(p = strstr(b, orig))) {
        return buffer;
      }
      strncpy(buffer2, buffer, 1023);
      sprintf(p, "\%s\%s", rep, b2+(p-buffer)+strlen(orig));
      b += (p-buffer)+strlen(rep);
    } while (1);
  }
  
  pANTLR3_STRING booleanResponse(int t, pANTLR3_BASE_TREE e) {
    if (t) {
      return e->strFactory->newStr(e->strFactory, "1");
    } else {
      return e->strFactory->newStr(e->strFactory, "0");
    }
  }
  
  pANTLR3_STRING escapeApos(pANTLR3_STRING e) {
    if (strstr(e->chars, "'")) {
      e->set8(e, replace_str(replace_str(e->chars, "&#039;", "'"), "'", "',\"'\",'"));
	    e->insert8(e, 0, "concat('");
	    e->append8(e, "')");
    } else {
	    e->insert8(e, 0, "'");
	    e->append8(e, "'");
	  }
	}
  
  pANTLR3_STRING predicateResult(pANTLR3_STRING p1, pANTLR3_STRING p2, char *sym) {
    if (!strlen(p1->chars)) {
      return p1;
    } else if (!strlen(p2->chars)) {
      return p2;
    } else {
      p1->append8(p1, sym);
      p1->appendS(p1, p2);
      return p1;
    }
  }
  
  pANTLR3_STRING newStr(pANTLR3_BASE_TREE e, char *c) {
    return e->strFactory->newStr(e->strFactory, c);
  }
  
  pANTLR3_STRING numberResponse(double t, pANTLR3_BASE_TREE e) {
    char buf[30];
    sprintf(buf, "\%lg", t);
    return e->strFactory->newStr(e->strFactory, buf);
  }

  pANTLR3_STRING longResponse(long t, pANTLR3_BASE_TREE e) {
    char buf[30];
    sprintf(buf, "\%ld", t);
    return e->strFactory->newStr(e->strFactory, buf);
  }

}

start
returns [ pANTLR3_STRING result, int isPath ]
  : expr EOF
    {
      $isPath = ($expr.isPath > 0);
      $result = $expr.result;
    }
  ;
  
at
returns [ pANTLR3_STRING result ]
  : ^(AT p1=path)
    {
      $result = $p1.result;
      $result->insert8($result, 0, "@");
    }
  | ^(XPATH_AXIS_SEP XPATH_AXES p2=path)
    {
      $result = $XPATH_AXES.text;
      $result->appendS($result, $XPATH_AXIS_SEP.text);
      $result->appendS($result, $p2.result);
    }
  ;
  
expr
returns [ pANTLR3_STRING result, int isPath ]
  : rootExpr
    {
      $isPath = $rootExpr.isPath;
      $result = $rootExpr.result;
    }
	| rootPath
	  {
	    $isPath = 1;
	    $result = $rootPath.result;
	  }
	;
	
evaledExpr
returns [ pANTLR3_STRING result ]
  : expr
    {
      if ($expr.isPath == 1) {
        $result = $expr.result;
        char *value = resolvePath($expr.result->chars);
        $result->set8($result, value);
        free(value);
      } else {
        $result = $expr.result;
      }
    }
  ;
	
function
returns [ pANTLR3_STRING result ]
	:	^(NODE_FUNCTION FUNCTION 
	    {
	      functionArgCount = 0;
        functionArgList[0] = NULL;
	    }
	    expressionList?
	  )
	  {
	    char *value = resolveFunction($FUNCTION.text->subString($FUNCTION.text, 0, strlen($FUNCTION.text->chars) - 1)->chars, functionArgList);
	    $result = newStr($FUNCTION, value);
	    free(value);
	  }
	;

expressionList
  : ^(COMMA expressionList expressionList) 
  | evaledExpr
    {
      if (functionArgCount < FUNCTION_ARG_LIST_SIZE) {
        functionArgList[functionArgCount] = $evaledExpr.result->chars;
        functionArgCount++;
        functionArgList[functionArgCount] = NULL;
      }
    }
  ;
  
oper
returns [ pANTLR3_STRING result, int isPath ]
	:	^(e=IFTRUE e1=evaledExpr ie2=expr ie3=expr)
    {
      int t = asBoolean($e1.result);
      $isPath = (t ? $ie2.isPath : $ie3.isPath);
      $result = (t ? $ie2.result : $ie3.result);
    }
	|	^((e=EQUALITY | e=EQUALITY_ALT) e1=evaledExpr e2=evaledExpr)
    {
      $isPath = 0;
      $result = booleanResponse((bothNumbers($e1.result, $e2.result) ? asNumber($e1.result) == asNumber($e2.result) : !strcmp($e1.result->chars, $e2.result->chars)), $e);
    }
	|	^((e=INEQUALITY | e=INEQUALITY_ALT) e1=evaledExpr e2=evaledExpr)
    {
      $isPath = 0;
      $result = booleanResponse((bothNumbers($e1.result, $e2.result) ? asNumber($e1.result) != asNumber($e2.result) : strcmp($e1.result->chars, $e2.result->chars)), $e);
    }
	|	^(e=LESS e1=evaledExpr e2=evaledExpr)
    {
      $isPath = 0;
      $result = booleanResponse((bothNumbers($e1.result, $e2.result) ? asNumber($e1.result) < asNumber($e2.result) : strcmp($e1.result->chars, $e2.result->chars) < 0), $e);
    }
	|	^(e=LTE e1=evaledExpr e2=evaledExpr)
    {
      $isPath = 0;
      $result = booleanResponse((bothNumbers($e1.result, $e2.result) ? asNumber($e1.result) <= asNumber($e2.result) : strcmp($e1.result->chars, $e2.result->chars) <= 0), $e);
    }
	|	^(e=GREATER e1=evaledExpr e2=evaledExpr)
    {
      $isPath = 0;
      $result = booleanResponse((bothNumbers($e1.result, $e2.result) ? asNumber($e1.result) > asNumber($e2.result) : strcmp($e1.result->chars, $e2.result->chars) > 0), $e);
    }
	|	^(e=GTE e1=evaledExpr e2=evaledExpr)
    {
      $isPath = 0;
      $result = booleanResponse((bothNumbers($e1.result, $e2.result) ? asNumber($e1.result) >= asNumber($e2.result) : strcmp($e1.result->chars, $e2.result->chars) >= 0), $e);
    }
	|	^((e=AND | e=AND_ALT) e1=evaledExpr e2=evaledExpr)
    {
      $isPath = 0;
      $result = booleanResponse(asBoolean($e1.result) && asBoolean($e2.result), $e);
    }
	|	^((e=OR | e=OR_ALT) e1=evaledExpr e2=evaledExpr)
    {
      $isPath = 0;
      $result = booleanResponse(asBoolean($e1.result) || asBoolean($e2.result), $e);
    }
	|	^((e=XOR | e=XOR_ALT) e1=evaledExpr e2=evaledExpr)
    {
      $isPath = 0;
      $result = booleanResponse(asBoolean($e1.result) ^ asBoolean($e2.result), $e);
    }
	|	^(e=ADD_TOK e1=evaledExpr e2=evaledExpr)
    {
      $isPath = 0;
      $result = numberResponse(asNumber($e1.result) + asNumber($e2.result), $e);
    }
	|	^(e=SUB e1=evaledExpr e2=evaledExpr)
    {
      $isPath = 0;
      $result = numberResponse(asNumber($e1.result) - asNumber($e2.result), $e);
    }
	|	^(e=MULT e1=evaledExpr e2=evaledExpr)
    {
      $isPath = 0;
      $result = numberResponse(asNumber($e1.result) * asNumber($e2.result), $e);
    }
	|	^(e=DIV e1=evaledExpr e2=evaledExpr)
    {
      $isPath = 0;
      $result = numberResponse(asNumber($e1.result) / asNumber($e2.result), $e);
    }
	|	^(e=MOD e1=evaledExpr e2=evaledExpr)
    {
      $isPath = 0;
      $result = numberResponse(asInt($e1.result) \% asInt($e2.result), $e);
    }
  | ^(e=NOT e1=evaledExpr)
    {
      $isPath = 0;
      $result = numberResponse(!asInt($e1.result), $e);
    }
	;
  
path
returns [ pANTLR3_STRING result ]
  : slash
    {
      $result = $slash.result;
    }
  | at
    {
      $result = $at.result;
    }
  | piper
    {
      $result = $piper.result;
    }
  | ^(NODE_PREDICATE predicate p3=path)
    {
      $result = $p3.result;
      if (strlen($predicate.result->chars)) {
        $result->append8($result, "[");
        $result->appendS($result, $predicate.result);
        $result->append8($result, "]");
      }
    }
  | INT
    {
      $result = $INT.text;
    }
  | NAME
    {
      $result = $NAME.text;
    }
  | STAR
    {
      $result = $STAR.text;
    }
  | DOT_STEP
    {
      $result = $DOT_STEP.text;
    }
  | PERMALINK
    {
      $result = $PERMALINK.text;
    }
  | SPECIAL_NEXT
    {
      $result = $SPECIAL_NEXT.text;
    }
  | SPECIAL_PREV
    {
      $result = $SPECIAL_PREV.text;
    }
  | variable
    {
      $result = $variable.result;
    }
  | function
    {
      $result = $function.result;
    }
  ;
  
piper  
returns [ pANTLR3_STRING result ]
  : ^(PIPE p1=path p2=path)
    {
      $result = $p1.result;
      $result->append8($result, "|");
      $result->appendS($result, $p2.result);
    }
  ;

predicate
returns [ pANTLR3_STRING result ]
  : INT
    {
      return $INT.text;
    }
  | predicateOper
    {
      return $predicateOper.result;
    }
  ;
  
predicateExpr
returns [ pANTLR3_STRING result ]
  : predicatePath
    {
      $result = $predicatePath.result;
    }
  | xpathFunction
	  {
	    $result = $xpathFunction.result;
	  }
  | value
	  {
	    $result = $value.result;
	    if (!$value.isBlankVariable) {
	      escapeApos($result);
      }
	  }
  | predicateOper
    {
      $result = $predicateOper.result;
    }
  ;
  
predicateOper
returns [ pANTLR3_STRING result ]
  : predicateEqualityOper
    {
      return $predicateEqualityOper.result;
    }
  | predicateInequalityOper
    {
      return $predicateInequalityOper.result;
    }
  | predicateAndOper
    {
      return $predicateAndOper.result;
    }
  | predicateOrOper
    {
      return $predicateOrOper.result;
    }
  | predicateComparisonOper
    {
      return $predicateComparisonOper.result;
    }
  | predicateRangeOper
    {
      return $predicateRangeOper.result;
    }
  ;

predicatePath
returns [ pANTLR3_STRING result ]
  : slash
    {
      $result = $slash.result;
    }
  | ^(AT p=predicatePath)
    {
      $result = $AT.text;
      $result->appendS($result, $p.result);
    }
  | ^(NODE_PATHREF evaledExpr)
    {
      $result = $evaledExpr.result;
	    escapeApos($result);
    }
  | NAME
    {
      $result = $NAME.text;
    }
  ;
  
predicateEqualityOper
returns [ pANTLR3_STRING result ]
  : ^(equalityOper p1=predicateExpr p2=predicateExpr)
	  {
	    $result = predicateResult($p1.result, $p2.result, "=");
	  }
	;
	
predicateInequalityOper
returns [ pANTLR3_STRING result ]
  : ^(inequalityOper p1=predicateExpr p2=predicateExpr)
	  {
	    $result = predicateResult($p1.result, $p2.result, "!=");
	  }
	;
	
predicateAndOper
returns [ pANTLR3_STRING result ]
  : ^(andOper p1=predicateExpr p2=predicateExpr)
	  {
	    $result = predicateResult($p1.result, $p2.result, " and ");
	  }
	;
	
predicateOrOper
returns [ pANTLR3_STRING result ]
  : ^(orOper p1=predicateExpr p2=predicateExpr)
	  {
	    $result = predicateResult($p1.result, $p2.result, " or ");
	  }
	;
	
predicateComparisonOper
returns [ pANTLR3_STRING result ]
  : ^(comparisonOper p1=predicateExpr p2=predicateExpr)
	  {
	    $result = predicateResult($p1.result, $p2.result, $comparisonOper.text->chars);
	  }
	;
	
predicateRangeOper
returns [ pANTLR3_STRING result ]
  : ^(COLON p1=predicateExpr p2=rangeFunction)
	  {
      $result = newStr($COLON, $p1.result->chars);
      if (strcmp($p2.lowResult->chars, "") && strcmp($p2.highResult->chars, "")) {
        $result->append8($result, ">='");
        $result->appendS($result, $p2.lowResult);
        $result->append8($result, "'][");
        $result->appendS($result, $p1.result);
        $result->append8($result, "<'");
        $result->appendS($result, $p2.highResult);
        $result->append8($result, "'");
      } else {
        $result->append8($result, "='0'");
      }
	  }
	;
	
rangeFunction
returns [ pANTLR3_STRING lowResult, pANTLR3_STRING highResult ]
	:	^(NODE_FUNCTION FUNCTION 
	    {
	      functionArgCount = 0;
        functionArgList[0] = NULL;
	    }
	    expressionList?
	  )
	  {
	    RangeFunctionRange ret = resolveRangeFunction($FUNCTION.text->subString($FUNCTION.text, 0, strlen($FUNCTION.text->chars) - 1)->chars, functionArgList);
	    $lowResult = longResponse(ret.low, $FUNCTION);
	    $highResult = longResponse(ret.high, $FUNCTION);
	  }
	;
	
rootExpr
returns [ pANTLR3_STRING result, int isPath ]
  : oper
    {
      $isPath = $oper.isPath;
      $result = $oper.result;
    }
  | value
    {
      $isPath = $value.isPath;
      $result = $value.result;
    }
  ;
  
rootPath
returns [ pANTLR3_STRING result, int isPath ]
  : ^(NODE_SQL path)
    {
      $result = newStr($NODE_SQL, "~");
      $result->appendS($result, $path.result);
      $isPath = 1;
    }
  | ^(NODE_PATH path) 
    {
      $isPath = 1;
      $result = $path.result;
    }
  ;
  
slash  
returns [ pANTLR3_STRING result ]
  : ^(NODE_ABSOLUTE p3=path)
    {
      $result = $p3.result;
      $result->insert8($result, 0, "/");
    }
  | ^(SLASH p1=path p2=path)
    {
      $result = $p1.result;
      $result->append8($result, "/");
      $result->appendS($result, $p2.result);
    }
  ;
	
value
returns [ pANTLR3_STRING result, int isPath, int isBlankVariable ]
  : ^(NODE_VALUE STRING)
    {
      $isPath = 0;
      $isBlankVariable = 0;
      $result = $STRING.text->subString($STRING.text, 1, strlen($STRING.text->chars) - 1);
    }
  | ^(NODE_VALUE FLOAT)
    {
      $isPath = 0;
      $isBlankVariable = 0;
      $result = $FLOAT.text;
    }
  | ^(NODE_VALUE INT)
    {
      $isPath = 2;
      $isBlankVariable = 0;
      $result = $INT.text;
    }
	| variable
	  {
      $isPath = 0;
	    $result = $variable.result;
      $isBlankVariable = (strlen($result->chars) == 0);
	  }
	| function 
	  {
      $isPath = 0;
      $isBlankVariable = 0;
	    $result = $function.result;
	  }
	;
	
variable
returns [ pANTLR3_STRING result ]
  : ^(NODE_VALUE VARIABLE)
    {
      $result = $VARIABLE.text->subString($VARIABLE.text, 1, strlen($VARIABLE.text->chars));
      char *value = resolveVariable($result->chars);
      $result->set8($result, value);
      free(value);
    }
  ;
  
xpathExpr
returns [ pANTLR3_STRING result ]
  : ^(NODE_PATH predicatePath)
    {
      $result = $predicatePath.result;
    }
  | xpathFunction
	  {
	    $result = $xpathFunction.result;
	  }
  | value
	  {
	    $result = $value.result;
	    escapeApos($result);
	  }
  ;
  
xpathFunction
returns [ pANTLR3_STRING result ]
	:	^(NODE_XPATHFUNCTION XPATH_FUNCTION xpathFunctionExpression?)
	  {
	    $result = $XPATH_FUNCTION.text;
	    $result->appendS($result, $xpathFunctionExpression.result);
	    $result->append8($result, ")");
	  }
	;
	
xpathFunctionExpression
returns [ pANTLR3_STRING result ]
  : ^(COMMA x1=xpathFunctionExpression x2=xpathFunctionExpression) 
    {
      $result = $x1.result;
      $result->append8($result, ",");
      $result->appendS($result, $x2.result);
    }
  | xpathExpr
    {
      $result = $xpathExpr.result;
    }
  ;

andOper
  : AND | AND_ALT
  ;
  
orOper
  : OR | OR_ALT
  ;
	
equalityOper
	:	EQUALITY | EQUALITY_ALT
	;
	
inequalityOper
	:	INEQUALITY | INEQUALITY_ALT
	;

comparisonOper
  : LESS | LTE | GREATER | GTE
	;
