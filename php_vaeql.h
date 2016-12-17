#ifndef PHP_VAEQL_H
#define PHP_VAEQL_H
extern zend_module_entry VaeQueryLanguage_module_entry;
#ifdef ZTS
#include "TSRM.h"
#endif

#define phpext_VaeQueryLanguage_ptr &VaeQueryLanguage_module_entry;

#define PHP_VAEQUERYLANGUAGE_API


PHP_MINIT_FUNCTION(VaeQueryLanguage);
PHP_MSHUTDOWN_FUNCTION(VaeQueryLanguage);
PHP_RINIT_FUNCTION(VaeQueryLanguage);
PHP_RSHUTDOWN_FUNCTION(VaeQueryLanguage);
PHP_MINFO_FUNCTION(VaeQueryLanguage);

ZEND_NAMED_FUNCTION(_vaeql_query_internal);

#endif
