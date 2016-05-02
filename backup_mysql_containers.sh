#!/bin/sh
#
# Mysql server backup script
# Gets list of mysql server containers running on local Docker host,
# then execs a backup script on each, gathering backups
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

CONTAINER_KEYWORD="mysql"       # In case you name your containers "db-" etc
MYSQL_BACKUP_SCRIPT="/usr/local/bin/backup_mysql_databases.sh"
BACKUP_SCRIPT_NAME=`basename $MYSQL_BACKUP_SCRIPT`
MAX_BACKUP_AGE=30               # Max backup age, in days
MYSQL_HOME="/var/lib/mysql"
BACKUP_HOME="$MYSQL_HOME/backups"
LOCAL_BACKUP_DIR="/data01/backups"
DATE=`date +%Y%m%d%H%M`

# Presuming if a container has "mysql" in the name, it's...running a MySQL server.
# TODO: would be nice to optionally search for containers with a mysql label.
mysql_containers=`docker ps --filter name=$CONTAINER_KEYWORD --filter status=running |awk '{if(NR>1) print $NF}'`

for container in $mysql_containers; do
  echo "Backing up databases on $container:"
  mysql_backup_dir="$BACKUP_HOME/$container-$DATE"
  echo "Copying backup script to container"
  docker cp $MYSQL_BACKUP_SCRIPT $container:/
  echo "Running backups:"
  docker exec $container sh -c "/$BACKUP_SCRIPT_NAME $mysql_backup_dir"
  echo "Extracting backups from container"
  docker cp $container:$mysql_backup_dir $LOCAL_BACKUP_DIR/$container-$DATE
  echo "Removing backup from container"
  docker exec $container sh -c "rm -r $mysql_backup_dir"
  echo "Removing backup script from container"
  docker exec $container rm /$BACKUP_SCRIPT_NAME
done

echo "Erasing backups over $MAX_BACKUP_AGE days:"
find $LOCAL_BACKUP_DIR -ctime +$MAX_BACKUP_AGE -exec rm -rf {} \;
