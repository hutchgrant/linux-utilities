#!/bin/bash

# save in /usr/share/applications/your-application.desktop so it's accessible for all users
# for a specific user save in ~/.local/share/applications/your-application.desktop

DIR="/usr/share/applications/your-application.desktop"

echo "
[Desktop Entry]
Type=Application
Terminal=false
Icon=/home/user/somefolder/someicon.png
Name=Your-Application
Exec=/home/user/somefolder/somefile
Categories=Development; " > $DIR
