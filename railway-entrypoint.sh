#!/bin/bash
set -e

# The webkul/krayin image ships a PRE-SEEDED internal MySQL datadir baked into
# /var/lib/mysql (57 tables + admin user; the image does NOT run --initialize at
# runtime, it just starts mysqld against that baked data).
#
# Railway mounts the persistent volume at /var/lib/mysql EMPTY (root-owned, with a
# lost+found), which masks the baked data. Result: empty datadir -> mysqld can't
# start -> crash loop -> 502. (Local Docker named volumes don't hit this because
# Docker pre-copies the image dir into a fresh named volume; Railway does not.)
#
# So at build time we snapshot the baked datadir to /opt/mysql-seed (unmounted),
# and here we restore it into the volume the first time it's empty. On subsequent
# boots the volume already holds the (now persistent) MySQL data and we skip it.
if [ -d /var/lib/mysql ]; then
    rm -rf /var/lib/mysql/lost+found 2>/dev/null || true

    if [ ! -d /var/lib/mysql/mysql ]; then
        # Fresh/empty volume: clear partial files from failed boots and restore
        # the baked, pre-seeded datadir.
        rm -rf /var/lib/mysql/* 2>/dev/null || true
        cp -a /opt/mysql-seed/. /var/lib/mysql/ 2>/dev/null || true
    fi

    chown -R mysql:mysql /var/lib/mysql 2>/dev/null || true
fi

# Hand off to Krayin's own entrypoint (applies env -> .env, starts MySQL, then
# execs the CMD, i.e. supervisord).
exec /usr/local/bin/entrypoint.sh "$@"
