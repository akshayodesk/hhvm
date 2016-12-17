dnl
dnl $ Id: $
dnl

PHP_ARG_ENABLE(vaeql, whether to enable vaeql functions,
        [  --enable-vaeql         Enable vaeql support])

    PHP_REQUIRE_CXX
    AC_LANG_CPLUSPLUS
    export OLD_CPPFLAGS="$CPPFLAGS"
    export CPPFLAGS="$CPPFLAGS $INCLUDES -DHAVE_VAEQL"

AC_MSG_CHECKING(PHP version)
    AC_TRY_COMPILE([#include <php_version.h>], [
#if PHP_VERSION_ID < 40000
#error  this extension requires at least PHP version 4.0.0
#endif
            ],
            [AC_MSG_RESULT(ok)],
            [AC_MSG_ERROR([need at least PHP 4.0.0])])

    export CPPFLAGS="$OLD_CPPFLAGS"
    export LDFLAGS="-L/usr/local/lib -g -lantlr3c"
    export LIBS="-lantlr3c"


AC_DEFINE(HAVE_VAEQL, 1, [ ])

PHP_NEW_EXTENSION(vaeql, VaeQueryLanguageLexer.cpp  VaeQueryLanguageParser.cpp  VaeQueryLanguageTreeParser.cpp vaeql.cpp php_vaeql.cpp, $ext_shared)

