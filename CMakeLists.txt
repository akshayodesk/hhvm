CMAKE_MINIMUM_REQUIRED(VERSION 2.8.5 FATAL_ERROR)
PROJECT(hphp C CXX ASM)

set (CMAKE_SHARED_LINKER_FLAGS "-L/usr/local/lib -g -shared -fPIC -Wl,-undefined,dynamic_lookup -lantlr3c")

set(HHVM_DEFINITIONS ";THRIFT_MUTEX_EMULATE_PTHREAD_TIMEDLOCK;HHVM_DYNAMIC_EXTENSION_DIR=\"/usr/lib/x86_64-linux-gnu/hhvm/extensions\";HAVE_LIBDL;HAVE_BOOST1_49;HAVE_FEATURES_H=1;PHP_MYSQL_UNIX_SOCK_ADDR=\"/var/run/mysqld/mysqld.sock\";HAVE_CURL_MULTI_WAIT;USE_JEMALLOC=1;NO_TCMALLOC=1;USE_EDITLINE;LIBDWARF_USE_INIT_C;HAVE_ELF_GETSHDRSTRNDX;FOLLY_HAVE_WEAK_SYMBOLS=1;FOLLY_HAVE_MEMRCHR=1;FOLLY_HAVE_PREADV=1;FOLLY_HAVE_PWRITEV=1;FOLLY_HAVE_LIBGFLAGS=0;_REENTRANT=1;_PTHREADS=1;__STDC_FORMAT_MACROS;_GNU_SOURCE;RELEASE=1;NDEBUG;ENABLE_FASTCGI=1;HPHP_OSS=1;PACKAGE=hhvm;PACKAGE_VERSION=Release;DEFAULT_CONFIG_DIR=\"/etc/hhvm/\";HAVE_INTTYPES_H;NO_LIB_GFLAGS;MBFL_STATIC;PCRE_STATIC=1;ZIP_EXTERN=;FOLLY_NO_CONFIG=1;FOLLY_HAVE_CLOCK_GETTIME=1;FOLLY_HAVE_PTHREAD_ATFORK=1;FOLLY_HAVE_PTHREAD_SPINLOCK_T=1;FOLLY_HAVE_FEATURES_H=1;FOLLY_HAVE_VLA=1;FOLLY_HAVE_BITS_FUNCTEXCEPT_H=1;FOLLY_HAVE_LINUX_MEMBARRIER_H=0;HHVM;USE_CMAKE")
set(HHVM_API_VERSION "20150212")
set(CMAKE_INSTALL_PREFIX "/usr")
set(CMAKE_INSTALL_LIBDIR "lib/x86_64-linux-gnu")
set(CMAKE_BUILD_TYPE "Release")
set(ENABLE_ZEND_COMPAT "ON")

option(HHVM_DSO_TEST_MODE "Build against source headers, not installed ones" Off)
if (HHVM_DSO_TEST_MODE)
  set(HHVM_INCLUDE_DIRS "/tmp/tmp.qMpa57lCbI;/usr/include;/usr/include;/usr/include;/usr/include/x86_64-linux-gnu;/tmp/tmp.qMpa57lCbI/third-party/re2/src;/tmp/tmp.qMpa57lCbI/third-party/squangle/src;/tmp/tmp.qMpa57lCbI/third-party/webscalesqlclient/src/include;/usr/include;/usr/include;/usr/include/libxml2;/usr/include/double-conversion;/usr/include;/usr/include/x86_64-linux-gnu;/usr/include;/usr/include;/usr/include;/usr/include;/usr/include;/usr/include;/usr/include;/usr/include;/usr/include;/tmp/tmp.qMpa57lCbI/hphp;/tmp/tmp.qMpa57lCbI/third-party;/tmp/tmp.qMpa57lCbI/third-party/libmbfl;/tmp/tmp.qMpa57lCbI/third-party/libmbfl/mbfl;/tmp/tmp.qMpa57lCbI/third-party/libmbfl/filters;/tmp/tmp.qMpa57lCbI/third-party/timelib;/tmp/tmp.qMpa57lCbI/third-party/folly;/tmp/tmp.qMpa57lCbI/third-party/folly/src;/tmp/tmp.qMpa57lCbI/third-party/fatal;/tmp/tmp.qMpa57lCbI/third-party/wangle/src;/tmp/tmp.qMpa57lCbI/third-party/brotli/src;/tmp/tmp.qMpa57lCbI/third-party/proxygen/src;/tmp/tmp.qMpa57lCbI/third-party/thrift/src;/tmp/tmp.qMpa57lCbI/third-party/libafdt/src/src;/tmp/tmp.qMpa57lCbI/third-party/mcrouter/src;/tmp/tmp.qMpa57lCbI/third-party/fastlz/src;/tmp/tmp.qMpa57lCbI/third-party/pcre;/tmp/tmp.qMpa57lCbI/third-party/libzip/src/lib;/tmp/tmp.qMpa57lCbI/third-party/libzip/src/lib;/tmp/tmp.qMpa57lCbI/hphp;/tmp/tmp.qMpa57lCbI;/usr/include")
  set(CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_SOURCE_DIR}
    "/tmp/tmp.qMpa57lCbI/CMake" "/tmp/tmp.qMpa57lCbI/hphp/public_tld/CMake"
    ${CMAKE_MODULE_PATH})
else()
  set(HHVM_INCLUDE_DIRS "/usr/include;/usr/include;/usr/include;/usr/include;/usr/include/x86_64-linux-gnu;/usr/include/hphp/third-party/re2/src;/usr/include/hphp/third-party/squangle/src;/usr/include/hphp/third-party/webscalesqlclient/src/include;/usr/include;/usr/include;/usr/include/libxml2;/usr/include/double-conversion;/usr/include;/usr/include/x86_64-linux-gnu;/usr/include;/usr/include;/usr/include;/usr/include;/usr/include;/usr/include;/usr/include;/usr/include;/usr/include;/usr/include/hphp;/usr/include/hphp/third-party;/usr/include/hphp/third-party/libmbfl;/usr/include/hphp/third-party/libmbfl/mbfl;/usr/include/hphp/third-party/libmbfl/filters;/usr/include/hphp/third-party/timelib;/usr/include/hphp/third-party/folly/src;/usr/include/hphp/third-party/fatal;/usr/include/hphp/third-party/wangle/src;/usr/include/hphp/third-party/brotli/src;/usr/include/hphp/third-party/proxygen/src;/usr/include/hphp/third-party/thrift/src;/usr/include/hphp/third-party/libafdt/src/src;/usr/include/hphp/third-party/mcrouter/src;/usr/include/hphp/third-party/fastlz/src;/usr/include/hphp/third-party/pcre;/usr/include/hphp/third-party/libzip/src/lib;/usr/include/hphp/third-party/libzip/src/lib;/usr/include/hphp;/usr/include")
  set(CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_SOURCE_DIR}
    "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/hhvm/CMake"
    ${CMAKE_MODULE_PATH})
endif()

message(STATUS "Configuring for HHVM API version ${HHVM_API_VERSION}")

include(HPHPFunctions)
include(HPHPIZEFunctions)
include(HPHPCompiler)
include(config)

foreach (dir ${HHVM_INCLUDE_DIRS})
  include_directories(${dir})
endforeach()

add_definitions("-DHHVM_BUILD_DSO")
foreach (def ${HHVM_DEFINITIONS})
  add_definitions("-D${def}")
endforeach()

add_custom_target(test COMMAND
                       HHVM_BIN=${CMAKE_INSTALL_PREFIX}/bin/hhvm
                       ${CMAKE_CURRENT_SOURCE_DIR}/run-test
                       -a "-vDynamicExtensions.99=${EXTENSION_NAME}.so" test
                       DEPENDS ${EXTENSION_NAME})
