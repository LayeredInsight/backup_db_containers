# backup_db_containers
This set of scripts will attempt to detect mysql, postgres, or mongodb
containers on a host, and run appropriate backup scripts for each.

This script has been designed to work with the following "official"
container images:

* [Offical MySQL Docker image](https://hub.docker.com/_/mysql/), using
  the supported environment variable MYSQL_ROOT_PASSWORD to set the 
  server's root password. In the future it may support other methods
  of determining mysql server authentication details.
* [Official Postgres db Docker image](https://hub.docker.com/_/postgres/)
* [Official mongo db Docker image](https://hub.docker.com/_/mongo/)

# Usage
Packaging/install scripts will be created as requested...I guess
this could be a privilged container, but personally that doesn't
thrill me.

Copy the shell scripts in this directory to /usr/local/bin on your
docker host
```
cp *sh /usr/local/bin
chmod 755 /usr/local/bin/
```
Review the constants set in each to see if they fit your needs or 
need any modification.

After you're set up, running backup_db_containers.sh will find a
list of containers, copy the appropriate backup*.sh script into it,
and then run backups as necessary, cleaning up afterwards.

When all's said and done, backups will be placed in $LOCAL_BACKUP_DIR,
which is /data01/backups by default. 

Old backups will be deleted - the default value is backups older than 30 days.

## Scheduling
For the moment, the periodical execution of the backup scripts is
left as an exercise for the reader. I'm currently using a cronjob
on the docker host, but would rather something more centralized.

## Origins
This project is based on https://github.com/jlk/backup_mysql_containers.
