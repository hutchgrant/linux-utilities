#!/bin/bash

# Add mongo user to database

MONGO_USER="someuser"
MONGO_PASS="somepassword"
MONGO_DATABASE="any-database-name"

echo "
db.createUser( { user: \"$MONGO_USER\",
		 pwd: \"$MONGO_PASS\",
		 customData: { },
		 roles: [ { role: \"clusterAdmin\", db: \"admin\" },
		          { role: \"readAnyDatabase\", db: \"admin\" },
		                  \"readWrite\"] },
		 { w: \"majority\" , wtimeout: 5000 } )" | mongo $MONGO_DATABASE
