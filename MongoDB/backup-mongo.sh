#!/bin/bash

# Mongo Backup

# If you want to dump to an archive
# mongodump --db <yourdb> --gzip --archive=/path/to/archive

# If not an archive:
# mongodump --db <yourdb> -o /path/to/dump

# See http://docs.mongodb.org/manual/reference/program/mongodump/ 

DATE=`date +%d-%b-%Y`
BACKUPDB="my-mongo-db"
BACKUPDIR=/var/backups/$USER
BACKUPFILE="fullbackup-$DATE.tar.gz"

mongodump --db $BACKUPDB --gzip --archive=$BACKUPDIR/mongobackups/$BACKUPFILE
