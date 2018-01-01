#!/bin/bash

# Create Mongo or any systemd service

echo "
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
