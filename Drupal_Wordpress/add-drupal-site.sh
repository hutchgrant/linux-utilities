#!/bin/bash

#  Add a new Drupal site to a pre-existing local LAMP development environment, 
#  create drush alias for site @local.yoursitename
#  Add site to apache config

clear

rootDir="/home/$USER/public_html"
srvUrl="http://localhost/~$USER"

db_user="your-mysql-user"
db_pass="your-mysql-pass"
db_url="localhost"

drupUsr="your-drupal-user"
drupPass="your-drupal-password"
drupEmail="your-email@email.com"


echo "What do you want to name the new site?"
read newsite

# check for drush
if ! [ -x "$(command -v drush)" ]; then
	echo "Drush is missing, atempting to install drush"
	if ! [ -x "$(command -v php)" ]; then
		echo "you must install php first to continue. sudo apt-get install php"
		exit
	fi
	sudo apt-get install drush -y
	cd ~/
	php -r "readfile('http://files.drush.org/drush.phar');" > drush
	drushlocation="$(which drush)"
	chmod +x ~/drush
	sudo mv ~/drush $drushlocation
	$drushlocation init
fi

# create alias / alias group
if [ ! -f ~/.drush/local.aliases.drushrc.php ]; then
    echo "drush local alias not found! Creating a new alias group ~/.drush/local.aliases.drushrc.php"
    sudo echo -e "<?php \n" > /home/$USER/.drush/local.aliases.drushrc.php
fi

sudo sh -c "echo \"\\\$aliases['$newsite'] = array( \n \
    'uri' => '$srvUrl/$newsite/', \n \
    'root' => '$rootDir/$newsite', \n \
); \n\" >> /home/$USER/.drush/local.aliases.drushrc.php"

# download drupal
drush dl drupal --destination="$rootDir" --drupal-project-rename="$newsite"

# install, configure, set permissions
cd $rootDir/$newsite

drush -y @local.$newsite site-install standard --db-url=mysql://$db_user:$db_pass@$db_url/$newsite --account-mail="$drupEmail" --account-name="$drupUsr" --account-pass="$drupPass" --site-name="$newsite"

# update apache config
sudo sed -i '/# Available/i\ <Directory "'$rootDir/$newsite'" > \
            Options Indexes FollowSymLinks MultiViews \
            AllowOverride All \
            Order allow,deny \
            allow from all \
        </Directory> \n ' /etc/apache2/sites-available/000-default.conf

sudo service apache2 restart

# set files folder permissions
chmod 777 $rootDir/$newsite/sites/default/files

# reset cache
drush @local.$newsite cache-rebuild

google-chrome $srvUrl/$newsite

if ! [ -x "$(command -v google-chrome)" ]; then
    firefox $srvUrl/$newsite
fi
