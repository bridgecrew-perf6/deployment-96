#!/usr/bin/bash

read -p "Downgrade where? (qa): " cluster

src_ip="10.4.90.100"

if [ $cluster == "qa" ]; then
  deploy_ip="10.4.90.150"
fi

if [ $cluster == "prod" ]; then
  deploy_ip="10.4.90.50"
  deploy_ip_sec="10.4.90.60"
fi

if [ -v $deploy_ip ]; then
  echo "Give a proper cluster (prod,qa)."
  exit 1
fi

current_ver=$(cat version)

echo "Current Version: $current_ver"

version_num=$(cat last_version)

read -p "Confirm version: $version_num (y/n) " confirm

if [ $confirm != "y" ]; then
  exit 0
fi

ssh webserver@$deploy_ip "sudo ln -fns /home/webserver/websiteFiles/$version_num /var/www/html; sudo systemctl restart nginx"
ssh webserver@$deploy_ip "rm -r /home/webserver/websiteFiles/$current_ver"

if [ $cluster == "prod" ]; then
  ssh webserver@$deploy_ip_sec "sudo ln -fns /home/webserver/websiteFiles/$version_num /var/www/html; sudo systemctl restart nginx"
  ssh webserver@$deploy_ip_sec "rm -r /home/webserver/websiteFiles/$current_ver"
fi

echo "$version_num" > version
echo $(($version_num - 1)) > last_version

echo "Done."
