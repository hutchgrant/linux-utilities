#!/bin/bash

# Create systemd service

echo "
[Unit]
Description=Some daemon you need to run
After=network.target

[Service]
User=root
ExecStart=/usr/bin/yourservice --quiet

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/yourservice.service

systemctl start yourservice
systemctl enable yourservice
