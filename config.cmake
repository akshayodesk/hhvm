#set(HPHP_HOME "/usr/bin/hphpize")

include_directories(
        ./
        /usr/include/php/20151012/
        /usr/include/php/20151012/Zend/
        /usr/include/php/20151012/TSRM/
        /usr/include/php/20151012/main/
)
HHVM_EXTENSION(vaeql VaeQueryLanguageLexer.cpp  VaeQueryLanguageParser.cpp  VaeQueryLanguageTreeParser.cpp vaeql.cpp php_vaeql.cpp) 
HHVM_SYSTEMLIB(vaeql ext_vaeql.php)
