#!/usr/bin/bash

read -p "Deploy where? (prod,qa): " cluster

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
version_num=$(($current_ver + 1))
read -p "Confirm version: $version_num (y/n) " confirm

if [ $confirm != "y" ]; then
  exit 0
fi

ssh webserver@$deploy_ip "mkdir /home/webserver/websiteFiles/$version_num"

scp -r webserver@$src_ip:/var/www/html webserver@$deploy_ip:/home/webserver/websiteFiles/$version_num

ssh webserver@$deploy_ip "sudo ln -fns /home/webserver/websiteFiles/$version_num /var/www/html; sudo systemctl restart nginx"


if [ $cluster == "prod" ]; then
  ssh webserver@$deploy_ip_sec "mkdir /home/webserver/websiteFiles/$version_num"

  scp -r webserver@$src_ip:/var/www/html webserver@$deploy_ip_sec:/home/webserver/websiteFiles/$version_num

  ssh webserver@$deploy_ip_sec "sudo ln -fns /home/webserver/websiteFiles/$version_num /var/www/html; sudo systemctl restart nginx"
fi

echo "$version_num" > version
echo "$current_ver" > last_version

echo "Done."
