#!/bin/bash

# Install Dependencies: node, npm, pm2, redis, git, graphicsmagick, imagemagick, nginx, update nodejs

apt-get -y install nodejs npm redis-server git graphicsmagick imagemagick nginx
ln -s "$(which nodejs)" /usr/bin/node
npm install -g n bower pm2@latest
n stable
