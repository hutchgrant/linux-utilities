#!/bin/bash
clear

domain=$1
domainEmail=$2
mongoDB=$3
mongoUser=$4
mongoPass=$5

installNginx() {

# Install Dependencies, update nodejs
apt-get -y install nodejs npm redis-server git graphicsmagick imagemagick nginx jq
ln -s "$(which nodejs)" /usr/bin/node
npm install -g n bower pm2@latest
n stable
}

installCertbot() {

# Add SSL Certificate via letsencrypt.org's certbot
apt-get -y install software-properties-common
add-apt-repository -y ppa:certbot/certbot
apt-get update
apt-get -y install python-certbot-nginx 
certbot certonly --standalone --agree-tos -m $domainEmail -d $domain -d www.$domain
}


installMongo() {

# Install and Configure mongoDb 3.2 - needs to be upgraded to 3.6
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
apt-get update
apt-get install -y mongodb-org
mkdir -p /data/db

echo -e "
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target

[Service]
User=root
ExecStart=/usr/bin/mongod --quiet

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/mongodb.service

systemctl start mongodb
systemctl enable mongodb

echo -e "
db.createUser( { user: \"$mongoUser\",
		 pwd: \"$mongoPass\",
		 customData: { },
		 roles: [ { role: \"clusterAdmin\", db: \"admin\" },
		          { role: \"readAnyDatabase\", db: \"admin\" },
		                  \"readWrite\"] },
		 { w: \"majority\" , wtimeout: 5000 } )" | mongo $mongoDB

}

configNginx() {
# Configure Nginx
echo -e "
server {

	listen 80 default_server;
	server_name $domain www.$domain;

	# redirect all urls to https
	return 301 https://\$server_name\$request_uri;
}

server {

	listen 443 ssl;

	server_name $domain www.$domain;

	# add Strict-Transport-Security to prevent man in the middle attacks
	add_header Strict-Transport-Security \"max-age=31536000\";

	client_max_body_size 10M;

	# ssl certificate config
	ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
	ssl_trusted_certificate /etc/letsencrypt/live/$domain/chain.pem;

	access_log /var/log/nginx/$domain.log;

	location / {
		proxy_set_header X-Real-IP \\$remote_addr;
		proxy_set_header X-Forwarded-For \\$proxy_add_x_forwarded_for;
		proxy_set_header Host \\$http_host;
		proxy_set_header X-NginX-Proxy true;

		proxy_pass http://127.0.0.1:3000;
		proxy_redirect off;

		proxy_http_version 1.1;
		proxy_set_header Upgrade \\$http_upgrade;
		proxy_set_header Connection \"upgrade\";
	}
}" >> /etc/nginx/sites-available/$domain

ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/   
rm /etc/nginx/sites-enabled/default

service nginx restart

}

enableFirewall() {

ufw allow from 127.0.0.1/32 to any port 27017
ufw default deny incoming 
ufw default allow outgoing
ufw allow ssh
ufw allow 80
ufw allow 443
ufw enable

}

installNginx
installCertbot
installMongo
configNginx
enableFirewall
