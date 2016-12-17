#include "VaeQueryLanguageLexer.h"
#include "VaeQueryLanguageParser.h"
#include "VaeQueryLanguageTreeParser.h"

/*
char *resolveFunction(char *function, char **args) {
  return function;
}

RangeFunctionRange resolveRangeFunction(char *function, char **args) {
  RangeFunctionRange r;
  r.low = r.high = function;
  return r;
}

char *resolvePath(char *path) {
  return "124";
}

char *resolveVariable(char *variable) {
  return "123";
}
*/


int ANTLR3_CDECL main(int argc, char *argv[]) {
  VaeQueryLanguageParser_start_return langAST;
  
  pVaeQueryLanguageLexer	lxr;
  pVaeQueryLanguageParser psr;
  pVaeQueryLanguageTreeParser treePsr;
  
  pANTLR3_INPUT_STREAM istream;
  pANTLR3_COMMON_TOKEN_STREAM	tstream;
  pANTLR3_COMMON_TREE_NODE_STREAM	nodes;
  VaeQueryLanguageTreeParser_start_return result;
  
  char *i = argv[1];
  //char i[] = "artists[name=\"Jake\'s Dilemma\"]";

  istream = antlr3NewAsciiStringInPlaceStream((uint8_t *)i, (ANTLR3_UINT64)strlen(i), NULL);

  lxr	= VaeQueryLanguageLexerNew(istream);
  if (lxr == NULL) {
		fprintf(stderr, "Unable to create the lexer due to malloc() failure1\n");
		exit(ANTLR3_ERR_NOMEM);
  }
  tstream = antlr3CommonTokenStreamSourceNew(ANTLR3_SIZE_HINT, TOKENSOURCE(lxr));
  if (tstream == NULL) {
		fprintf(stderr, "Out of memory trying to allocate token stream\n");
		exit(ANTLR3_ERR_NOMEM);
  }
  psr	= VaeQueryLanguageParserNew(tstream);
  if (psr == NULL) {
		fprintf(stderr, "Out of memory trying to allocate parser\n");
		exit(ANTLR3_ERR_NOMEM);
  }
  langAST = psr->start(psr);
	if (psr->pParser->rec->state->errorCount == 0) {
		nodes	= antlr3CommonTreeNodeStreamNewTree(langAST.tree, ANTLR3_SIZE_HINT);
		printf("Nodes: %s\n", langAST.tree->toStringTree(langAST.tree)->chars);
    treePsr	= VaeQueryLanguageTreeParserNew(nodes);
	  result = treePsr->start(treePsr);
	  if (result.isPath) {
      printf("Path: %s\n", result.result->chars);
    } else {
      printf("Result: %s\n", result.result->chars);
    }
	  treePsr->free(treePsr);
	  nodes->free(nodes);
	} else {
    printf("Unable to parse VaeQL Expression\n");
  }
	tstream->free(tstream);
	psr->free(psr);
	lxr->free(lxr);
	istream->close(istream);
  return 0;
}
