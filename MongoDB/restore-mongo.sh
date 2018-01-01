#!/bin/bash

# Mongo Restore

# If archive was dumped via mongodump:
# mongorestore --gzip --archive=/path/to/archive

# If not an archive:
# mongorestore --db training2 dump/training

# See http://docs.mongodb.org/manual/reference/program/mongorestore/ 

DATE=`date +%d-%b-%Y`
BACKUPDIR=/var/backups/$USER
BACKUPFILE="fullbackup-$DATE.tar.gz"

mongorestore --gzip --archive=/$BACKUPDIR/mongobackups/$BACKUPFILE


