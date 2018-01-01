#!/bin/bash

# Remotely deploy NodeJS Application to new server from repository, install dependencies and configure
# include node-install.sh in your project's root directory for remote deploy. 
# May adjust this in the future. If you want to scp that file or run it over ssh, please submit a pull request

clear

sshAccount="user@whatever"

mongoUser="someuser"
mongoPass="somepassword"
mongoDB="some-mongo-db"

domainEmail="your-email@mail.com"
domain="your-site.com"

user='newuser'
password='somepass'

remMount="/home/user/server"

appRepo="your-application-repo.git"
appFolder="your-application-main-folder"

# Deploy remote, install dependencies, set server/db/application configurations
deployRemote() {

ssh -it $sshAccount << EOF1
apt-get -y update
apt-get -y upgrade
apt-get -y install git

useradd -u 12345 -g users -m -d /home/$user -s /bin/bash $user
echo $user:$password | chpasswd
usermod -aG sudo $user

echo $password | su $user -c bash << EOF2
	mkdir $remMount		
	cd $remMount
	git clone $appRepo
	cd ./$appFolder
	chmod +x ./node-install.sh
	echo $password | sudo -S ./node-install.sh $domain $domainEmail $mongoDB $mongoUser $mongoPass
	npm install
	bower install -f
	pm2 start ./bin/www && pm2 save
EOF2
pm2 startup

exit
EOF1
}

installMenu() {

	echo "What is your domain admin email contact (for let's encrypt reminders)"
	read domainEmail
	echo "What is your domain (e.g. something.com no http/www. )?"
	read domain
	echo "What do you want to make your mongo username?"
	read mongoUser
	echo "What do you want to make your mongo user password?"
	read mongoPass
}

# Display and control Main Menu
getMainMenu() {
Exit=0
until [ $Exit -eq 1 ]; do
echo "------------------------------------------------"
echo "----------- ---NodeJS Deploy -------------------"
echo "---------------by hutchgrant--------------------"
echo "------------------------------------------------"
echo "1) Deploy Remotely"
echo "2) Deploy locally"
echo "3) Exit"
read choice

case $choice in
1)

	echo "What is your ssh account and IP(e.g. root@127.0.0.1)"
	read sshAccount
	echo "What is the name of the new unix user you want to add?"
	read user
	echo "What is the password for that new user?"
	read password
	echo "What directory do you want to store and run the application?"
	read remMount

	installMenu
	deployRemote

	Exit=1
;;
2)
	installMenu
	chmod +x ./node-install.sh
	sudo ./node-install.sh $domain $domainEmail $mongoDB $mongoUser $mongoPass
	npm install
	bower install -f
	pm2 start ./bin/www && pm2 save
	Exit=1
;;
3) Exit=1
;;
esac
done
}

getMainMenu


