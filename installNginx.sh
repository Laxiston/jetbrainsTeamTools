#!/bin/bash

type="y"
echo "Y - Run installation."
echo -n "Do you want to continue? [Y|n]: "
read type

if [ "$type" == "n" ]; then
  exit 0
fi

echo "*********************************************************************"
echo "In order to continue installing need set a few properties for proxy:"

echo -n "Main domain url: "
read mainDomain
echo -n "Hub domain url: "
read hubDomain
echo -n "Hub port: "
read hubPort

echo -n "YouTrack domain url: "
read youTrackDomain
echo -n "YouTrack port: "
read youTrackPort

echo -n "UpSource domain url: "
read upSourceDomain
echo -n "UpSource port: "
read upSourcePort

echo -n "Cron E-mail: "
read cronEmail

printParams() {
	echo "*****************************************"
	echo
	echo "Main domain url: $mainDomain"
	echo "Hub domain url: $hubDomain"
	echo "Hub port: $hubPort"
	echo "YouTrack domain url: $youTrackDomain"
	echo "YouTrack port: $youTrackPort"
	echo "UpSource domain url: $upSourceDomain"
	echo "UpSource port: $upSourcePort"
	echo "Cron email: $cronEmail"
	echo
	echo "*****************************************"
}

if [ "$mainDomain" == "" ] || [ "$hubDomain" == "" ] || [ "$hubPort" == "" ] || [ "$youTrackDomain" == "" ] || [ "$youTrackPort" == "" ] || [ "$upSourceDomain" == "" ] || [ "$upSourcePort" == "" ] || [ "$cronEmail" == "" ]; then
  echo "You have mistake into parameters!"
  exit 1
fi

printParams

echo -n "Do you continue? [Y|n]"
read type

if [ "$type" == "n" ]; then
  exit 0
fi

echo "Installing Nginx."

wget http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
echo 'deb http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list
echo 'deb-src http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list
apt-get update && apt-get install nginx

echo
echo "Configuring nginx"

mkdir -p /usr/jetbrains/hub/certs
mkdir -p /usr/jetbrains/youtrack/certs
mkdir -p /usr/jetbrains/upsource/certs

cat >./default<<EOF
server {
	listen 443;
	listen [::]:443;

	server_name ${youTrackDomain};
	server_tokens off;

    ssl         on;
    ssl_certificate      /usr/jetbrains/youtrack/certs/ssl.${youTrackDomain}.pem;
    ssl_certificate_key  /usr/jetbrains/youtrack/certs/ssl.${youTrackDomain}.key;

	location / {
		proxy_set_header X-Forwarded-Host \$http_host;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto \$scheme;
		proxy_http_version 1.1;

		proxy_pass http://localhost:${youTrackPort}/;
	}
}

server {
	listen 443;
	listen [::]:443;

	server_name ${upSourceDomain};
	server_tokens off;

    ssl         on;
    ssl_certificate      /usr/jetbrains/upsource/certs/ssl.${upSourceDomain}.pem;
    ssl_certificate_key  /usr/jetbrains/upsource/certs/ssl.${upSourceDomain}.key;

	location / {
		proxy_set_header X-Forwarded-Host \$http_host;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto \$scheme;
		proxy_http_version 1.1;

		proxy_set_header Upgrade \$http_upgrade;
		proxy_set_header Connection "upgrade";

		proxy_pass http://localhost:${upSourcePort}/;
	}
}

server {
	listen 443;
	listen [::]:443;

	server_name ${hubDomain};
	server_tokens off;

    ssl         on;
    ssl_certificate      /usr/jetbrains/hub/certs/ssl.${hubDomain}.pem;
    ssl_certificate_key  /usr/jetbrains/hub/certs/ssl.${hubDomain}.key;

	location / {
		proxy_set_header X-Forwarded-Host \$http_host;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto \$scheme;
		proxy_http_version 1.1;

		proxy_pass http://localhost:${hubPort}/;
	}
}

server {
	listen 80 default_server;
	listen [::]:80 default_server;

	root /var/www/html;

	index index.html index.htm index.nginx-debian.html;

	server_name ${mainDomain};
	server_tokens off;

	location / {
		try_files \$uri \$uri/ =404;
	}
}
EOF
cp -f default /etc/nginx/conf.d/proxy.conf

service nginx restart