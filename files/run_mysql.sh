#!/bin/bash

set -e

# initialize database if not already initialized
if [ ! -d /var/lib/mysql/mysql ]; then
  UUID_PASSWORD="$(uuidgen)"
  INITIAL_ROOT_PASSWORD="${INITIAL_ROOT_PASSWORD:-$UUID_PASSWORD}"
  if [ "$INITIAL_ROOT_PASSWORD" = "$UUID_PASSWORD" ]; then
    # save the initial root password since it was generated
    passfile=/mnt/mysql_pass
    touch "$passfile"
    chmod 600 "$passfile"
    echo "$INITIAL_ROOT_PASSWORD" > "$passfile"
    unset passfile
  fi
  WORDPRESS_USER="${WORDPRESS_USER:-wordpress}"
  WORDPRESS_PASSWORD="${WORDPRESS_PASSWORD:-WordpressPassword}"
  WORDPRESS_DATABASE="${WORDPRESS_DATABASE:-wordpress}"
  /usr/libexec/mariadb-prepare-db-dir
  /usr/bin/mysqld_safe --basedir=/usr &
  MYSQL_PID=$!
  /usr/libexec/mariadb-wait-ready $MYSQL_PID
  mysqladmin -u root password "$INITIAL_ROOT_PASSWORD"
  mysql -u root -p"$INITIAL_ROOT_PASSWORD" <<< ""
  mysql -u root -p"$INITIAL_ROOT_PASSWORD" <<EOF
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${INITIAL_ROOT_PASSWORD}' WITH GRANT OPTION;
CREATE USER '${WORDPRESS_USER}'@'%' IDENTIFIED BY '${WORDPRESS_PASSWORD}';
CREATE DATABASE ${WORDPRESS_DATABASE};
GRANT ALL PRIVILEGES ON ${WORDPRESS_DATABASE}.* TO '${WORDPRESS_USER}'@'%' IDENTIFIED BY '${WORDPRESS_PASSWORD}';
EOF
  kill $(pgrep -P $MYSQL_PID)
  while pgrep -P $MYSQL_PID;do sleep 1;done
fi

rm -f /var/log/mariadb/mariadb.log
mkfifo /var/log/mariadb/mariadb.log
chown mysql: /var/log/mariadb/mariadb.log
/usr/bin/mysqld_safe --basedir=/usr &
MYSQL_PID=$!

trap "kill -SIGQUIT $MYSQL_PID" INT
tail -f /var/log/mariadb/mariadb.log
