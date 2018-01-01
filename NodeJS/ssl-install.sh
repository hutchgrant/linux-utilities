#!/bin/bash

# Add SSL Certificate and configure nginx via letsencrypt.org's certbot

DOMAIN="yoursite.com"
DOMAIN_EMAIL="you@yoursite.com"

apt-get -y install software-properties-common
add-apt-repository -y ppa:certbot/certbot
apt-get update
apt-get -y install python-certbot-nginx 
certbot certonly --standalone --agree-tos -m $DOMAIN_EMAIL -d $DOMAIN -d www.$DOMAIN
