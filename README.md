# VaeQL

PHP Extension that provides accelerated parsing for VaeDB queries.

Build and install this before Vae Remote.


## License

Copyright (c) 2007-2016 Action Verb, LLC.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program, in the file called COPYING-AGPL.
If not, see http://www.gnu.org/licenses/.


## Prerequisites

 - PHP 7.0
 - libantlr3c (MUST be version 3.2)


### Installing prerequisites on Mac:

DO NOT install libantlr3c using Homebrew, as that only supplies 
version 3.4.

To compile libantlr3c:

    wget http://www.antlr3.org/download/C/libantlr3c-3.2.tar.gz
    tar -zxvf libantlr3c-3.2.tar.gz
    cd libantlr3c-3.2
    ./configure --enable-64bit
    make
    make install


I recommend using Homebrew for PHP so future version management of PHP
is easier.  To do so, run: 

    brew install php70
    brew install php70-opcache

As part of installing PHP 7.0 from Homebrew, you'll need to update your
$PATH in your shell to use their PHP 7.0 as the default PHP binaries.
This is key because VaeQL uses the "php-config" binary for its
installation process.

At this point, running `php` should work.

Ensure that you have Opcache installed because it's also used in our
production environment and can cause errors, so you want to make sure
it's also being used for the unit tests.  You should see output when you
run:

    php -i | grep "Zend O"

... and it should mention Zend Opcache.

With these two things ready, you should be able to compile VaeQL.


## Compiling:

    phpize
    ./configure --enable-vaeql --with-php-config=/usr/bin/php-config   CFLAGS='-fpermissive' CXXFLAGS='-fpermissive'
    You might need to add "LDFLAGS = -L/usr/local/lib -lantlr3c -g" to Makefile
    make

Then add this line to your php.ini.  If you are using Homebrew the path
is /usr/local/etc/php/7.0/php.ini.  Otherwise, it might be in /etc.  Run
php --ini to look for candidate locations for the file.

    extension=vaeql.so


## Testing:

You should be able to run this command and see some output.  There
should be no dylib or load errors.

    php -i | grep VaeQueryLanguage

This project is tested entirely using the test suite in Vae Remote.  It
is very easy to add more tasks to that test suite and we likely do not
need one here.
