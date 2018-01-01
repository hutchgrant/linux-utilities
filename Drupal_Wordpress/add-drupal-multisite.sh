#!/bin/bash

#  Add a new Drupal site to a pre-existing drupal multi-site
#  Add site to apache config

clear

db_user="your-mysql-user"
db_pass="your-mysql-pass"
db_url="localhost"

drupUsr="your-drupal-user"
drupPass="your-drupal-password"
drupEmail="your-email@email.com"

srvRoot="/home/$USER/public_html"
srvUrl="http://localhost/~$USER"

baseSite="theming"

echo "Which multisite do you want to add to?"
read baseSite

echo "What do you want to name the new site?"
read newsite

drush -y @local.$baseSite site-install standard --db-url=mysql://$db_user:$db_pass@$db_url/$newsite --sites-subdir="$newsite" --account-mail="$drupEmail" --account-name="$drupUsr" --account-pass="$drupPass" --site-name="$newsite"

sed -i "/);/i \'localhost.~$USER.$newsite' => '$newsite', " $srvRoot/$baseSite/sites/sites.php

sudo sed -i '/# Available/i\ <Directory "'$srvRoot/$newsite'" > \
            Options Indexes FollowSymLinks MultiViews \
            AllowOverride All \
            Order allow,deny \
            allow from all \
        </Directory> \n ' /etc/apache2/sites-available/000-default.conf

sudo service apache2 restart

ln -s $srvRoot/$baseSite $srvRoot/$newsite

chmod 777 $srvRoot/$baseSite/sites/$newsite/files

drush @local.$baseSite -l $newsite cache-rebuild
