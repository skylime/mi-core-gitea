#!/usr/bin/env bash
# Modify sample configuration file and start gitea service

HOSTNAME=$(hostname)
GITEA_APP_INI=/opt/local/etc/gitea/conf/app.ini

# Secrets
INTERNAL_TOKEN=$(/opt/core/bin/mdata-create-password.sh -m gitea_internal_token)
SECRET_KEY=$(/opt/core/bin/mdata-create-password.sh -m gitea_secret_key)

LFS_JWT_SECRET=$(/opt/core/bin/mdata-create-password.sh -m gitea_lfs_jwt_secret -s $(gitea generate secret JWT_SECRET))
JWT_SECRET=$(/opt/core/bin/mdata-create-password.sh -m gitea_jwt_secret -s $(gitea generate secret JWT_SECRET))

GITEA_ADMIN_INITIAL_PW=$(/opt/core/bin/mdata-create-password.sh -m gitea_admin_initial_pw)
GITEA_ADMIN_EMAIL=$(mdata-get gitea_admin_email || mdata-get mail_adminaddr)

DISABLE_REGISTRATION=$(mdata-get gitea_disable_registration || echo "true")

cat > ${GITEA_APP_INI} <<EOF
#
# configuration file provided by zoneinit (core-gitea)
# DO NOT MODIFY THIS FILE, IT WILL BE OVERWRITTEN BY ANY REPROVISION
#
APP_NAME = ${HOSTNAME}
RUN_USER = git
RUN_MODE = prod

[repository]
ROOT                    = /var/db/gitea/gitea-repositories
ENABLE_PUSH_CREATE_USER = true
ENABLE_PUSH_CREATE_ORG  = true

[repository.upload]
TEMP_PATH = /var/db/gitea/data/tmp/uploads

[server]
PROTOCOL         = unix
DOMAIN           = ${HOSTNAME}
ROOT_URL         = https://%(DOMAIN)s/
HTTP_ADDR        = /tmp/gitea.sock
OFFLINE_MODE     = true
LFS_START_SERVER = true
LFS_CONTENT_PATH = /var/db/gitea/lfs
LFS_JWT_SECRET   = ${LFS_JWT_SECRET}

[database]
DB_TYPE  = sqlite3
PATH     = /var/db/gitea/gitea.db

[indexer]
ISSUE_INDEXER_TYPE = bleve
ISSUE_INDEXER_PATH = /var/db/gitea/indexers/issues.bleve

[security]
INSTALL_LOCK   = true
INTERNAL_TOKEN = ${INTERNAL_TOKEN}
SECRET_KEY     = ${SECRET_KEY}

[service]
REGISTER_EMAIL_CONFIRM = true
DISABLE_REGISTRATION   = ${DISABLE_REGISTRATION}
REQUIRE_SIGNIN_VIEW    = true
ENABLE_NOTIFY_MAIL     = true

[mailer]
ENABLED       = true
FROM          = git@${HOSTNAME}
MAILER_TYPE   = sendmail
SENDMAIL_PATH = /usr/sbin/sendmail

[oauth2]
JWT_SECRET = ${JWT_SECRET}

[other]
SHOW_FOOTER_VERSION = false
SHOW_FOOTER_TEMPLATE_LOAD_TIME = false
EOF

# Create admin user if it doesn't exists already
gitea admin create-user \
	--username admin \
	--password "${GITEA_ADMIN_INITIAL_PW}" \
	--email "${GITEA_ADMIN_EMAIL}" \
	--admin || true

# Enable gitea service
svcadm enable svc:/pkgsrc/gitea:default
