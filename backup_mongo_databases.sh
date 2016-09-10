#!/bin/sh
# Backs up all mongo databases on a given host.
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

MONGODUMP=/usr/bin/mongodump

if [ $# -gt 0 ]; then
  BACKUP_DIR=$1
else
  echo "Usage: $0 <backup_directory>"
  exit
fi

DUMP_OPTIONS="--out $BACKUP_DIR --gzip"

mkdir -p $BACKUP_DIR
echo "Backing up all mongo databases:"
$MONGODUMP $DUMP_OPTIONS
