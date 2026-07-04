# Deploy Krayin CRM (REST API bundled) on Railway.
#
# webkul/krayin:2.2.0 is the prebuilt app image: Nginx + PHP-FPM + Supervisord,
# Krayin source + krayin/rest-api baked in, and an internal MySQL whose datadir
# ships PRE-SEEDED at /var/lib/mysql (the image does not run --initialize).
#
# Railway mounts the persistent volume at /var/lib/mysql EMPTY, masking that baked
# data. We snapshot the seed to /opt/mysql-seed at build, and a wrapper entrypoint
# restores it into the volume on first boot (see railway-entrypoint.sh).
FROM webkul/krayin:2.2.0

# The amd64 image ships BOTH the stock Debian nginx default site
# (sites-enabled/default) and Krayin's own server (conf.d/krayin.conf), each
# declaring `listen 80 default_server` -> "duplicate default server" -> nginx
# refuses to start -> 502. Drop the stock default; keep Krayin's.
RUN rm -f /etc/nginx/sites-enabled/default

# Snapshot the baked, pre-seeded MySQL datadir to a path the volume won't mask.
RUN cp -a /var/lib/mysql /opt/mysql-seed

# Railway routes to $PORT (default 8080); the wrapper repoints nginx to it.
EXPOSE 8080

COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

# Setting ENTRYPOINT resets the base image's CMD, so re-declare it (supervisord).
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
