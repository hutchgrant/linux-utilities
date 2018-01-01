#!/bin/bash

# Configure Nginx for port 3000

domain="yoursite.com"

echo "
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
