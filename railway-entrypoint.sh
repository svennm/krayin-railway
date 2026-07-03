#!/bin/bash
set -e

# Railway mounts the persistent volume at /var/lib/mysql owned by root:root and
# containing a `lost+found` directory. The image's internal MySQL runs as the
# `mysql` user and treats a non-empty datadir as "already initialized", so with a
# raw Railway volume it can neither write nor seed -> crash loop -> 502.
#
# Normalize the volume before handing off to the image's real entrypoint:
#   - drop lost+found so a first-boot datadir looks empty (triggers init + seed)
#   - chown to mysql so mysqld can write (harmless on later boots with real data)
if [ -d /var/lib/mysql ]; then
    rm -rf /var/lib/mysql/lost+found 2>/dev/null || true
    chown -R mysql:mysql /var/lib/mysql 2>/dev/null || true
fi

# Hand off to Krayin's own entrypoint (applies env -> .env, starts MySQL, then
# execs the CMD, i.e. supervisord).
exec /usr/local/bin/entrypoint.sh "$@"
