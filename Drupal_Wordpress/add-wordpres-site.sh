#!/bin/bash

#  Add a new wordpress multi-site to a pre-existing local LAMP development environment, 
#  Install WP-CLI if missing
#  Add site to apache config
#  Enable modrewrite in .htaccess

wpUsr="your-wordpress-user"
wpPass="your-wordpass-password"
wpEmail="your-email@email.com"

dbUsr="your-mysql-user"
dbPass="your-mysql-pass"
dbUrl="localhost"

srvUrl="http://localhost/~$USER"
rootDir="/home/$USER/public_html"
base="/~$USER"

echo "What do you want to name the site?"
read newsite

# check for wp-cli
if ! [ -x "$(command -v wp)" ]; then
	echo "WP-CLI is missing, atempting to install"
	if ! [ -x "$(command -v curl)" ]; then
		echo "you must install curl first to continue. sudo apt-get install curl"
		exit
	fi
	cd ~/
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x ~/wp-cli.phar
	sudo mv ~/wp-cli.phar /usr/local/bin/wp
fi

# download WP
wp core download --path=$rootDir/$newsite

# configure
wp core config --dbhost=$dbUrl --dbname=$newsite --dbuser=$dbUsr --dbpass=$dbPass --path=$rootDir/$newsite

# create DB
wp db create --path=$rootDir/$newsite

# install WP
wp core multisite-install --url=$srvUrl/$newsite --title=$newsite --admin_user=$wpUsr --admin_password=$wpPass --admin_email=$wpEmail --path=$rootDir/$newsite --base=$base/$newsite/

# add .htaccess rewrite rules
echo "RewriteEngine On \
RewriteBase /~$USER/$newsite/ \
RewriteRule ^index\.php$ - [L] \

# add a trailing slash to /wp-admin \
RewriteRule ^([_0-9a-zA-Z-]+/)?wp-admin$ $1wp-admin/ [R=301,L] \

RewriteCond %{REQUEST_FILENAME} -f [OR] \
RewriteCond %{REQUEST_FILENAME} -d \
RewriteRule ^ - [L] \
RewriteRule ^([_0-9a-zA-Z-]+/)?(wp-(content|admin|includes).*) $2 [L] \
RewriteRule ^([_0-9a-zA-Z-]+/)?(.*\.php)$ $2 [L] \
RewriteRule . index.php [L]" > $rootDir/$newsite/.htaccess

# update apache config
sudo sed -i '/# Available/i\ <Directory "'$rootDir/$newsite'" > \
            Options Indexes FollowSymLinks MultiViews \
            AllowOverride All \
            Order allow,deny \
            allow from all \
        </Directory> \n ' /etc/apache2/sites-available/000-default.conf

sudo service apache2 restart

google-chrome $srvUrl/$newsite

if ! [ -x "$(command -v google-chrome)" ]; then
    firefox $srvUrl/$newsite
fi
