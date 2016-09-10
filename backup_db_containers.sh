#!/bin/sh
#
# DB server backup script
# Gets list of mysql, postgres, and mongo server containers running on local
# Docker host, then execs a backup script on each, gathering backups
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

MYSQL_CONTAINER_KEYWORD="mysql"       # In case you name your containers "db-" etc
MYSQL_BACKUP_SCRIPT="/usr/local/bin/backup_mysql_databases.sh"
MYSQL_BACKUP_SCRIPT_NAME=`basename $MYSQL_BACKUP_SCRIPT`
MONGO_CONTAINER_KEYWORD="mongo"
MONGO_BACKUP_SCRIPT="/usr/local/bin/backup_mongo_databases.sh"
MONGO_BACKUP_SCRIPT_NAME=`basename $MONGO_BACKUP_SCRIPT`
MAX_BACKUP_AGE=30               # Max backup age, in days
MYSQL_HOME="/var/lib/mysql"
MYSQL_BACKUP_HOME="$MYSQL_HOME/backups"
LOCAL_BACKUP_DIR="/data01/backups"
DATE=`date +%Y%m%d%H%M`

backup_mysql_containers() {
  # Presuming if a container has $MYSQL_CONTAINER_KEYWORD in the name, it's running a MySQL server.
  # TODO: would be nice to optionally search for containers with a mysql label.
  mysql_containers=`docker ps --filter name=$MYSQL_CONTAINER_KEYWORD --filter status=running |awk '{if(NR>1) print $NF}'`

  for container in $mysql_containers; do
    echo "Backing up mysql databases on $container:"
    mysql_backup_dir="$MYSQL_BACKUP_HOME/$container-$DATE"
    echo "Copying mysql backup script to container"
    docker cp $MYSQL_BACKUP_SCRIPT $container:/
    echo "Running backups:"
    docker exec $container sh -c "/$MYSQL_BACKUP_SCRIPT_NAME $mysql_backup_dir"
    echo "Extracting backups from container"
    docker cp $container:$mysql_backup_dir $LOCAL_BACKUP_DIR/$container-$DATE
    echo "Removing backup from container"
    docker exec $container sh -c "rm -r $mysql_backup_dir"
    echo "Removing backup script from container"
    docker exec $container rm /$MYSQL_BACKUP_SCRIPT_NAME
  done
}

backup_mongo_containers() {
  # Presuming if a container has $MONGO_CONTAINER_KEYWORD in the name, it's running a mongo server.
  mongo_containers=`docker ps --filter name=$MONGO_CONTAINER_KEYWORD --filter status=running |awk '{if(NR>1) print $NF}'`

  for container in $mongo_containers; do
    echo "Backing up mongo databases on $container:"
    mongo_backup_dir="/$container-$DATE"
    echo "Copying mongo backup script to container"
    docker cp $MONGO_BACKUP_SCRIPT $container:/
    echo "Running backups:"
    docker exec $container sh -c "/$MONGO_BACKUP_SCRIPT_NAME $mongo_backup_dir"
    echo "Extracting backups from container"
    docker cp $container:$mongo_backup_dir $LOCAL_BACKUP_DIR/$container-$DATE
    echo "Removing backup from container"
    docker exec $container sh -c "rm -r $mongo_backup_dir"
    echo "Removing backup script from container"
    docker exec $container rm /$MONGO_BACKUP_SCRIPT_NAME
  done
}

backup_mysql_containers
backup_mongo_containers
echo "Erasing backups over $MAX_BACKUP_AGE days:"
find $LOCAL_BACKUP_DIR -ctime +$MAX_BACKUP_AGE -exec rm -rf {} \;
