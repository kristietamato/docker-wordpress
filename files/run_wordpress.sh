#!/bin/bash

function rand64() {
  tr -dc -- '-;.~,.<>[]{}!@#$%^&*()_+=`0-9a-zA-Z' < /dev/urandom | head -c64;echo
}

RAND1="$(rand64)"
RAND2="$(rand64)"
RAND3="$(rand64)"
RAND4="$(rand64)"
RAND5="$(rand64)"
RAND6="$(rand64)"
RAND7="$(rand64)"
RAND8="$(rand64)"

DATABASE_NAME="${DATABASE_NAME:-wordpress}"
DATABASE_USER="${DATABASE_USER:-wordpress}"
DATABASE_PASSWORD="${DATABASE_PASSWORD:-WordpressPassword}"
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
/usr/sbin/httpd -DFOREGROUND
