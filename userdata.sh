#!/bin/bash
sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx
sudo chmod 777 /var/www/html/index.nginx-debian.html
sudo echo Hello from `hostname -f` > /var/www/html/index.nginx-debian.html