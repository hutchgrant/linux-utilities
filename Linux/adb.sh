#!/bin/bash

# setup ADB

export PATH=~/Android/Sdk/platform-tools:$PATH
export PATH=~/Android/Sdk/tools:$PATH


echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

