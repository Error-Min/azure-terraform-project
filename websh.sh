#!/bin/bash
sudo su -
yum install -y httpd
cd /var/www/html
systemctl start httpd