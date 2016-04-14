# backup_mysql_containers
This set of scripts will attempt to run a mysql backup on any
container running on the local host that has "mysql" in it's container
name. For each container, it will attempt to get a list of databases,
and run mysql_dump against each one.

This script has been designed to work with the (Offical MySQL Docker
images)[https://hub.docker.com/_/mysql/], using the supported
environment variable MYSQL_ROOT_PASSWORD to set the server's root
password. In the future it may support other methods of determining
mysql server authentication details.

# Usage
Packaging/install scripts will be created as requested...I guess
this could be a privilged container, but personally that doesn't
thrill me.

Copy the two shell scripts here to somewhere on your docker host
```
cp *sh /usr/local/bin
chmod 755 /usr/local/bin/
```
...and then review the constants set in each to see if they fit 
your needs or need any modification.

## Scheduling
For the moment, the periodical execution of the backup scripts is
left as an exercise for the reader. I'm currently using a cronjob
on the docker host, but would rather something more centralized.
