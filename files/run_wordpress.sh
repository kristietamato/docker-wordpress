#!/bin/bash

function rand64() {
  tr -dc -- '-;.~,.<>[]{}!@#$%^&*()_+=`0-9a-zA-Z' < /dev/urandom | head -c64;echo
}

# generate random 64 characters used in the wordpress seeds
RAND1="$(rand64)"
RAND2="$(rand64)"
RAND3="$(rand64)"
RAND4="$(rand64)"
RAND5="$(rand64)"
RAND6="$(rand64)"
RAND7="$(rand64)"
RAND8="$(rand64)"

if [ "${DATABASE_NAME:-default}" = default ]; then
  until [ -f /mnt/mysql_wordpress_database ]; do sleep 1; done
  DATABASE_NAME="$(< /mnt/mysql_wordpress_database)"
fi
if [ "${DATABASE_USER:-default}" = default ]; then
  until [ -f /mnt/mysql_wordpress_user ]; do sleep 1; done
  DATABASE_USER="$(< /mnt/mysql_wordpress_user)"
fi
if [ "${DATABASE_PASSWORD:-default}" = default ]; then
  until [ -f /mnt/mysql_wordpress_password ]; do sleep 1; done
  DATABASE_PASSWORD="$(< /mnt/mysql_wordpress_password)"
fi

DATABASE_HOST="${DATABASE_HOST:-mysql}"
TABLE_PREFIX="${TABLE_PREFIX:-wp_}"
WORDPRESS_DEBUG="${WORDPRESS_DEBUG:-false}"
if [[ "$WORDPRESS_DEBUG" != "false" && "$WORDPRESS_DEBUG" != "true" ]]; then
  WORDPRESS_DEBUG=false
fi
table_prefix='$table_prefix'
export ${!RAND*} ${!DATABASE*} TABLE_PREFIX table_prefix WORDPRESS_DEBUG
if [ ! -f /var/www/html/wp-config.php ]; then
  rsync -av /usr/local/share/wordpress/ /var/www/html/
  envsubst < /wp-config.php.tpl > /var/www/html/wp-config.php
  chown -R apache: /var/www/html
fi

# start the web service
/usr/sbin/httpd -DFOREGROUND
