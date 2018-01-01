#!/bin/bash

# Setup firewall whitelist mongo locally, ssh and ports 80 + 443 globally

ufw allow from 127.0.0.1/32 to any port 27017
ufw default deny incoming 
ufw default allow outgoing
ufw allow ssh
ufw allow 80
ufw allow 443
ufw enable
