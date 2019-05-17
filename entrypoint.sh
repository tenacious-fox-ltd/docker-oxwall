#!/bin/bash
set -e

if [ ! -e '/var/www/html/index.php' ]; then
	tar cf - --one-file-system -C /usr/src/oxwall . | tar xf -
	chown -R www-data /var/www/html
fi

chfn -f 'Oxwall Admin' www-data

/etc/init.d/mysql start
/etc/init.d/proftpd start


exec "$@"