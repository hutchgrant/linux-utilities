#!/bin/bash

# Add a new unix user with sudo permissions

UNIX_USER="someuser"
UNIX_PASS="somepass"

useradd -u 12345 -g users -m -d /home/$UNIX_USER -s /bin/bash $UNIX_USER
echo $UNIX_USER:$UNIX_PASS | chpasswd
usermod -aG sudo $UNIX_USER
