#ifndef VEBRQL_H_
#define VEBRQL_H_

#ifdef __cplusplus
extern "C" {
#endif
typedef struct RangeFunctionRange {
  long low;
  long high;
} RangeFunctionRange;

char *resolveFunction(char *function, char **args);
RangeFunctionRange resolveRangeFunction(char *function, char **args);
char *resolvePath(char *path);
char *resolveVariable(char *variable);
#ifdef __cplusplus
}
#endif

#endif
