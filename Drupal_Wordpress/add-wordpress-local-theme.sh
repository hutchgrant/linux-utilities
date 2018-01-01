#!/bin/bash

# Create and install a new fresh wordpress theme based on a number of starter themes

clear

srvRoot="/home/$USER/public_html"
newsite="your-new-site"
author="someuser"

WPThemeDesc="Bootstrap 3 Starter Theme by SimonPadbury"
WPTheme="bst"
WPThemeUrl="https://github.com/SimonPadbury/bst/archive/master.zip"

WPTheme2Desc="Bootstrap 4-alpha Starter Theme by SimonPadbury"
WPTheme2="b4st"
WPTheme2Url="https://github.com/SimonPadbury/b4st/archive/master.zip"

echo "What do you want to name the new custom theme?"
read themename

echo "Which theme do you want to fork by default?"
echo "1) $WPThemeDesc"
echo "2) $WPThemeDesc"
read themechoice

case $themechoice in

1)
theme="$WPTheme"
themeUrl="$WPThemeUrl"
;;
2)
theme=$WPTheme2
themeUrl=$WPTheme2Url
;;
esac

wp theme install $themeUrl --path=$srvRoot/$newsite

cp $srvRoot/$newsite/wp-content/themes/$theme $srvRoot/$newsite/wp-content/themes/$themename -R
rm $srvRoot/$newsite/wp-content/themes/$theme -R

echo -e "/*
Theme Name: $themename 
Theme URI: http://$author.com 
Description: Bootstrap Starter Theme for WordPress. Using Twitter Bootstrap 3.3.5
Author: $author
Author URI: http://$author.github.io
Version: 2.7.1
License: MIT License
License URI: http://opensource.org/licenses/MIT 
*/ \n" > $srvRoot/$newsite/wp-content/themes/$themename/style.css

echo "Activate theme immediately on this site? [y/n]"
read themeactive

echo "Enable theme for all sites on a multisite? [y/n]"
read thememulti

if [ $themeactive == "y" ]; then
if [ $thememulti == "y" ]; then
wp theme enable $themename --path=$srvRoot/$newsite --activate --network
else
wp theme activate $themename --path=$srvRoot/$newsite
fi
fi

