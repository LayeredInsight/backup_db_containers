#!/bin/sh
# Backs up all postgres databases on a given host.
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

PGSQL_HOME=/var/lib/postgresql
PSQL=/usr/bin/psql
PGDUMP=/usr/bin/pg_dump
DATE=`date +%Y-%m-%d`

if [ $# -gt 0 ]; then
  BACKUP_DIR=$1
else
  echo "Usage: $0 <backup_directory>"
  exit
fi

if [ ! -d $PGSQL_HOME ] ; then
  echo "Could not find $PGSQL_HOME. Is postgres installed?"
  exit 1
fi

DUMP_OPTIONS="-Fd -f $BACKUP_DIR"
DATABASES=`echo "\l" | su - postgres -c "$PSQL -qt" | grep -v template0 | grep -v template1 | cut -d'|' -f1 | awk '{print $1}' | grep -v ^$`

mkdir -p $BACKUP_DIR
chown postgres $BACKUP_DIR
for dbname in $DATABASES ; do
  echo "Backing up $dbname"
  su - postgres -c "$PGDUMP $DUMP_OPTIONS $dbname"
done
