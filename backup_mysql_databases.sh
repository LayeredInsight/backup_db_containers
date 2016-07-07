#!/bin/sh
# Backs up all mysql databases on a given host.
#
#  Copyright 2016 John Kinsella
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###

# This script expects $MYSQL_ROOT_PASSWORD to contain the root
# password for the mysql server.

MYSQLHOME=/var/lib/mysql
MYSQLDUMP=/usr/bin/mysqldump
MYSQLUSER=root
DUMP_OPTIONS="-u $MYSQLUSER --password=$MYSQL_ROOT_PASSWORD --opt --compress --single-transaction"
DATE=`date +%Y-%m-%d`

if [ $# -gt 0 ]; then
  BACKUP_DIR=$1
else
  echo "Usage: $0 <backup_directory>"
fi

DATABASES=`echo "show databases" | mysql --user=root --password=$MYSQL_ROOT_PASSWORD |tail --lines=+2`

if [ ! -d $MYSQL_HOME ] ; then
  echo "Could not find $MYSQL_HOME. Is mysql installed?"
  exit 1
fi

mkdir -p $BACKUP_DIR
for dbname in $DATABASES ; do
  echo "Backing up $dbname"
  $MYSQLDUMP $DUMP_OPTIONS $dbname | gzip > $BACKUP_DIR/$dbname.backup.gz
done
