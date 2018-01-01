#!/bin/bash
clear

# Install and configure LAMP, Apache, MySQL, phpmyadmin, PHP, local Drupal/Wordpress single/multi site development environment

# EDIT WITH YOUR MYSQL CREDENTIALS
db_user="your-mysql-user"
db_pass="your-mysql-pass"
db_url="localhost"

# EDIT WITH YOUR PREFERRED DRUPAL/WORDPRESS DEFAULT ADMIN CREDENTIALS
Usr="your-wordpress-user"
Pass="your-wordpress-pass"
Email="your-email@email.com"

# FOR CUSTOM PATHS, EDIT THESE
srvRoot="/home/$USER/public_html"
srvUrl="http://localhost/~$USER"
base="/~$USER"


# Check if apache mod_rewrite is enabled
checkRewrite () {

if [ ! -f /etc/apache2/mods-enabled/rewrite.load ]; then
    echo "Apache mod_rewrite not enabled, enabling..."
    sudo a2enmod rewrite
    sudo service apache2 restart;
fi

}

# Check if apache mod_userdir is enabled
checkUserDir () {

if [ ! -f /etc/apache2/mods-enabled/userdir.load ]; then
    echo "Apache mod_userdir not enabled, enabling..."
    sudo a2enmod userdir
    echo "creating ~/public_html directory for your sites"
    mkdir ~/public_html && chmod 0755 ~/public_html
    echo "editing /etc/apache2/mods-available/php7.0.conf to enable php in your public_html directory"
    sudo sed -e '/php_admin_flag/ s/^#*/#/' -i /etc/apache2/mods-available/php7.0.conf
    sudo service apache2 restart;
fi

}

# Check for LAMP
checkLAMP () {

if ! [ -x "$(command -v apache2)" ]; then
if [ "`lsb_release -is`" == "Ubuntu" ] || [ "`lsb_release -is`" == "Debian" ]
then
    echo -e "\n Missing LAMP server! Attempting to install Apache2, MySQL, PHP7, phpmyadmin"
    echo "-------------------------------------------------------------------------------"
    echo "----REMINDER: You will be asked to create and then re-enter a mysql password----"
    echo "------------- Make sure you write it down, you will need to manually edit -----"
    echo "--------------the top of this script with it after it's completed or it -------"
    echo "--------------will not work! press enter to continue --------------------------"
    echo "-------------------------------------------------------------------------------"
    read cont
    sudo apt-get -y install mysql-server mysql-client libmysqld-dev;
    sudo apt-get -y install apache2 php7.0 libapache2-mod-php php-mcrypt phpmyadmin;
    sudo chmod 755 -R /var/www/;
    sudo printf "<?php\nphpinfo();\n?>" > /var/www/html/info.php;
    checkRewrite
    checkUserDir
    echo "-------------------------------------------------------------------------------"
    echo "-------------------------------------------------------------------------------"
    echo "LAMP install completed. You can now put your sites in /var/www/ accessible by with http://127.0.0.1/yoursite"
    echo "This script will put your sites in /home/$USER/public_html and you can access it with http://localhost/~$USER/yoursite"
    echo "-------------------------------------------------------------------------------"
    echo "To continue installing your first site, we need the mysql password, it's recommended you manually edit it into the top of this script, along with other credentials you want to add, then save it. rerun this script afterwords when completed".
    echo "---------------------------------------------------------------------------------"
    echo "---------------------press enter to open gedit and continue ---------------------"
    echo "---------------------------------------------------------------------------------"
    read cont2
    gedit ./addsite
    exit
else
    echo "Missing LAMP server for your distribution, you'll have to install it and run again."
    exit
fi
else
    checkRewrite
    checkUserDir
fi

}

# Check for drush
checkDrush () {

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

}

# Check for WP-CLI 
checkWPCLI () {

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

}

# Create Single Drupal site
singleDrupal () {

## create alias / alias group
if [ ! -f ~/.drush/local.aliases.drushrc.php ]; then
    echo "drush local alias not found! Creating a new alias group ~/.drush/local.aliases.drushrc.php"
    sudo echo -e "<?php \n" > /home/$USER/.drush/local.aliases.drushrc.php
fi

sudo sh -c "echo \"\\\$aliases['$newsite'] = array( \n \
    'uri' => '$srvUrl/$newsite/', \n \
    'root' => '$srvRoot/$newsite', \n \
); \n\" >> /home/$USER/.drush/local.aliases.drushrc.php"

## Download and extract drupal
drush dl drupal --destination="$srvRoot" --drupal-project-rename="$newsite"

cd $srvRoot/$newsite

## Install and configure drupal
drush -y @local.$newsite site-install standard --db-url=mysql://$db_user:$db_pass@$db_url/$newsite --account-mail="$Email" --account-name="$Usr" --account-pass="$Pass" --site-name="$newsite"

## Set drupal permissions
chmod 777 $srvRoot/$newsite/sites/default/files

## clear cache
drush @local.$newsite cache-rebuild

}


# Add multisite subdirectory to Drupal site
multiDrupal () {

## Install and configure drupal
drush -y @local.$baseSite site-install standard --db-url=mysql://$db_user:$db_pass@$db_url/$newsite --sites-subdir="$newsite" --account-mail="$Email" --account-name="$Usr" --account-pass="$Pass" --site-name="$newsite"

## Add new multisite config to sites.php
sed -i "/);/i \'localhost.~$USER.$newsite' => '$newsite', " $srvRoot/$baseSite/sites/sites.php

## Link folder in base directory to site
ln -s $srvRoot/$baseSite $srvRoot/$newsite
## Set drupal permissions
chmod 777 $srvRoot/$baseSite/sites/$newsite/files

## clear cache of multisite
drush @local.$baseSite -l $newsite cache-rebuild

}

# Download, Extract, Configure Wordpress
setupWP () {

## download WP
wp core download --path=$srvRoot/$newsite

## configure
wp core config --dbhost=$db_url --dbname=$newsite --dbuser=$db_user --dbpass=$db_pass --path=$srvRoot/$newsite

## create DB
wp db create --path=$srvRoot/$newsite
}

# Create Single Wordpress Site
singleWP () {

setupWP

## install WP
wp core install --url=$srvUrl/$newsite --title=$newsite --admin_user=$Usr --admin_password=$Pass --admin_email=$Email --path=$srvRoot/$newsite

}

# Create Multi Wordpress Site
multiWP () {

setupWP

## install WP multisite
wp core multisite-install --url=$srvUrl/$newsite --title=$newsite --admin_user=$Usr --admin_password=$Pass --admin_email=$Email --path=$srvRoot/$newsite --base=$base/$newsite/

## add .htaccess rewrite rules
echo -e "RewriteEngine On  \n \
RewriteBase $base/$newsite/  \n \
RewriteRule ^index\.php$ - [L] \n \

# add a trailing slash to /wp-admin  \n \
RewriteRule ^([_0-9a-zA-Z-]+/)?wp-admin$ \$1wp-admin/ [R=301,L]  \n \

RewriteCond %{REQUEST_FILENAME} -f [OR]  \n \
RewriteCond %{REQUEST_FILENAME} -d \n \
RewriteRule ^ - [L] \n \
RewriteRule ^([_0-9a-zA-Z-]+/)?(wp-(content|admin|includes).*) \$2 [L] \n \
RewriteRule ^([_0-9a-zA-Z-]+/)?(.*\.php)$ \$2 [L] \n \
RewriteRule . index.php [L]" > $srvRoot/$newsite/.htaccess

}

# modify Apache config and restart
modifyApache () {

sudo sed -i '/# Available/i\ <Directory "'$srvRoot/$newsite'" > \
            Options Indexes FollowSymLinks MultiViews \
            AllowOverride All \
            Order allow,deny \
            allow from all \
        </Directory> \n ' /etc/apache2/sites-available/000-default.conf

sudo service apache2 restart

}

# open browser to display site
openSite () {

if ! [ -x "$(command -v google-chrome)" ]; then
    firefox $srvUrl/$newsite
else
    google-chrome $srvUrl/$newsite
fi

## Open sublime/nautilus
if ! [ -x "$(command -v subl)" ]; then
    echo "sublime not installed, opening nautilus"
    nautilus $srvRoot/$newsite
else
    subl $srvRoot/$newsite
fi

}

# Get multisite base site name
getMultiName () {
	echo "Which multisite(pre-existing drupal site dir name) do you want to add to?"
	read baseSite
}

echo "------------------------------------------------"
echo "Instant Drupal/Wordpress Development Environment"
echo "---------------by hutchgrant--------------------"
echo "------------------------------------------------"

checkLAMP

echo "Which CMS do you want to use?"
echo "1) Drupal"
echo "2) Wordpress"
read cms

echo "What do you want to name the new site? (case sensitive, dont use spaces, caps or special chars)"
read newsite

echo "Do you want to create a multisite(Drupal sites must be created as regular site first)? [y/n]"
read multisite

case $cms in
     1)
	checkDrush
	if [ $multisite == "y" ]
	then
	getMultiName
	multiDrupal
	else
	singleDrupal
	fi 
	modifyApache
	openSite
     ;;
     2)
	checkWPCLI
	if [ $multisite == "y" ]
	then
	multiWP
	else
	singleWP
	fi 
	modifyApache
	openSite
     ;;
esac



