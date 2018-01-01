#!/bin/bash

# Create a fresh theme and install it in a local drupal site (development)

clear

srvRoot="/home/$USER/public_html"
newsite="your-new-site"
author="your-user"

DrupThemeDesc="Bootstrap 3 Starter Theme"
DrupTheme="bootstrap"

# Check for less
checkLess () {

if ! [ -x "$(command -v lessc)" ]; then
	echo "Less is missing, atempting to install Less"
	sudo apt-get install less -y
fi

}

echo "What do you want to name the new custom theme?"
read themename

echo "Which theme do you want to fork by default?"
echo "1) $DrupThemeDesc"
read themechoice

case $themechoice in

1)
checkLess
# Get bootstrap default theme + start kit, create new theme
drush @local.$newsite en bootstrap -y
cp $srvRoot/$newsite/themes/bootstrap/starterkits/less $srvRoot/$newsite/themes/$themename -R
find $srvRoot/$newsite/themes/$themename/ -name "THEMENAME*" -exec rename 's/THEMENAME/skynet/' '{}' \;
mv $srvRoot/$newsite/themes/$themename/$themename.starterkit.yml $srvRoot/$newsite/themes/$themename/$themename.info.yml 
find $srvRoot/$newsite/themes/$themename/ -exec sed -i 's/THEMENAME/skynet/g' '{}' \;
sed -i 's/THEMENAME/skynet/g' $srvRoot/$newsite/themes/$themename/$themename.info.yml
sed -i 's/THEMETITLE/skynet/g' $srvRoot/$newsite/themes/$themename/$themename.info.yml
sed -i 's/THEMETITLE/skynet/g' $srvRoot/$newsite/themes/$themename/config/schema/$themename.info.yml

# Get bootstrap source
wget https://github.com/twbs/bootstrap/archive/v3.3.7.zip -P $srvRoot/$newsite/themes/
unzip $srvRoot/$newsite/themes/v3.3.7.zip -d $srvRoot/$newsite/themes/$themename/
mv $srvRoot/$newsite/themes/$themename/bootstrap-3.3.7 $srvRoot/$newsite/themes/$themename/bootstrap
rm $srvRoot/$newsite/themes/v3.3.7.zip

lessc $srvRoot/$newsite/themes/$themename/less/style.less $srvRoot/$newsite/themes/$themename/css/style.css

echo "enable on a specific multisite? [y/n]"
read multisite


if [ $multisite == "y" ]; then
echo "Which sub-site of this multisite do you want to enable the theme on?"
read specmulti

drush @local.$newsite -l $specmulti pm-uninstall bartik
drush @local.$newsite -l $specmulti pm-enable $themename
drush @local.$newsite -l $specmulti config-set system.theme default $themename
drush @local.$newsite -l cache-rebuild
else
drush @local.$newsite pm-uninstall bartik
drush @local.$newsite pm-enable $themename
drush @local.$newsite config-set system.theme default $themename
drush @local.$newsite cache-rebuild
fi

;;
esac
