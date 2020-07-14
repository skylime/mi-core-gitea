#!/usr/bin/env bash
# This script configure SSL, htaccess and start our NGINX webserver
# service.

# Defaults
SSL_HOME='/opt/local/etc/nginx/ssl/'
SVC_NAME='svc:/pkgsrc/nginx:default'

# Create folder if it doesn't exists
mkdir -p "${SSL_HOME}"

# Self-signed certificate generator
/opt/core/bin/ssl-selfsigned.sh -d ${SSL_HOME} -f nginx

# Enable NGINX webserver service
svcadm enable ${SVC_NAME}

# Try to provide Let's Encrypt SSL certificate
/opt/core/bin/ssl-generator.sh ${SSL_HOME} nginx_ssl nginx ${SVC_NAME}

# Restart NGINX webserver service
svcadm restart ${SVC_NAME}
