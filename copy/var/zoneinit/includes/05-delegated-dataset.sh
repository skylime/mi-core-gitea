#!/bin/bash
UUID=$(mdata-get sdc:uuid)
DDS=zones/${UUID}/data

if zfs list ${DDS} 1>/dev/null 2>&1; then
	zfs create ${DDS}/git-db           || true

	zfs set mountpoint=/var/db/gitea ${DDS}/git-db

	# znapzend for backup
	znapzendzetup create --recursive --tsformat='%Y-%m-%d-%H%M%S' --donotask \
		SRC '7day=>8hour,30day=>1day,1year=>1week,10year=>1month' ${DDS}
	/usr/sbin/svcadm enable svc:/pkgsrc/znapzend:default
fi

# update permissions for git usage
chown git:git /var/db/gitea
