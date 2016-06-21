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

code=`lsb_release -a | grep Codename | sed 's/[[:space:]]//g' | cut -f2 -d:`

echo
echo "Debian codename:"
echo "$code"
echo

echo
echo "Configuring nginx"

apt-get install -t ${code}-backports nginx -y

cat >./default<<EOF
                    # Server globals
user                    www-data;
worker_processes        2;
error_log               /var/log/nginx/error.log;
pid                     /var/run/nginx.pid;


# Worker config
events {
        worker_connections  1024;
        use                 epoll;
}


http {
    # Main settings
    sendfile                        on;
    tcp_nopush                      on;
    tcp_nodelay                     on;
    client_header_timeout           1m;
    client_body_timeout             1m;
    client_header_buffer_size       2k;
    client_body_buffer_size         256k;
    client_max_body_size            256m;
    large_client_header_buffers     4   8k;
    send_timeout                    30;
    keepalive_timeout               60 60;
    reset_timedout_connection       on;
    server_tokens                   off;
    server_name_in_redirect         off;
    server_names_hash_max_size      512;
    server_names_hash_bucket_size   512;


    # Log format
    log_format  main    '$remote_addr - $remote_user [$time_local] $request '
                        '"$status" $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';
    log_format  bytes   '$body_bytes_sent';
    #access_log          /var/log/nginx/access.log  main;
    access_log off;


    # Mime settings
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;


    # Compression
    gzip                on;
    gzip_comp_level     9;
    gzip_min_length     512;
    gzip_buffers        8 64k;
    gzip_types          text/plain text/css text/javascript
                        application/x-javascript application/javascript;
    gzip_proxied        any;


    # Proxy settings
    proxy_redirect      off;
    proxy_set_header    Host            $host;
    proxy_set_header    X-Real-IP       $remote_addr;
    proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_pass_header   Set-Cookie;
    proxy_connect_timeout   90;
    proxy_send_timeout  90;
    proxy_read_timeout  90;
    proxy_buffers       32 4k;


    # Cloudflare https://www.cloudflare.com/ips
    set_real_ip_from   199.27.128.0/21;
    set_real_ip_from   173.245.48.0/20;
    set_real_ip_from   103.21.244.0/22;
    set_real_ip_from   103.22.200.0/22;
    set_real_ip_from   103.31.4.0/22;
    set_real_ip_from   141.101.64.0/18;
    set_real_ip_from   108.162.192.0/18;
    set_real_ip_from   190.93.240.0/20;
    set_real_ip_from   188.114.96.0/20;
    set_real_ip_from   197.234.240.0/22;
    set_real_ip_from   198.41.128.0/17;
    set_real_ip_from   162.158.0.0/15;
    set_real_ip_from   104.16.0.0/12;
    set_real_ip_from   172.64.0.0/13;
    #set_real_ip_from   2400:cb00::/32;
    #set_real_ip_from   2606:4700::/32;
    #set_real_ip_from   2803:f800::/32;
    #set_real_ip_from   2405:b500::/32;
    #set_real_ip_from   2405:8100::/32;
    real_ip_header     CF-Connecting-IP;


#    # SSL PCI Compliance
#    ssl_session_cache   shared:SSL:10m;
#    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
#    ssl_prefer_server_ciphers on;
#    ssl_ciphers        "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
# SSL PCI Compliance
    ssl_session_cache   shared:SSL:10m;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
    ssl_prefer_server_ciphers on;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;
    ssl_session_timeout 1d;
    ssl_stapling on;
    ssl_stapling_verify on;
    add_header Strict-Transport-Security max-age=15768000;


    # Error pages
    error_page          403          /error/403.html;
    error_page          404          /error/404.html;
    error_page          502 503 504  /error/50x.html;


    # Cache
    proxy_cache_path /var/cache/nginx levels=2 keys_zone=cache:10m inactive=60m max_size=512m;
    proxy_cache_key "$host$request_uri $cookie_user";
    proxy_temp_path  /var/cache/nginx/temp;
    proxy_ignore_headers Expires Cache-Control;
    proxy_cache_use_stale error timeout invalid_header http_502;
    proxy_cache_valid any 3d;

    map $http_cookie $no_cache {
        default 0;
        ~SESS 1;
        ~wordpress_logged_in 1;
    }


    # Wildcard include
    include             /etc/nginx/conf.d/*.conf;
}
EOF

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