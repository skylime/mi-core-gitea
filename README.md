# mi-core-gitea

This repository is based on [Joyent mibe](https://github.com/joyent/mibe). Please note this repository should be build with the [mi-core-base](https://github.com/skylime/mi-core-base) mibe image.

## description

Minimal mibe image for [Gitea - Git with a cup of tea](https://gitea.io).


## mdata variables

- `gitea_admin_initial_pw`: password of the admin user for gitea (auto generated)
- `gitea_admin_email`: email address used for the admin user (if not set `mail_adminaddr` is used)

## services

- `22/tcp`: ssh connections
- `80/tcp`: http webserver
- `443/tcp`: https webserver
