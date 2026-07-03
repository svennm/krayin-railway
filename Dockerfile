# Deploy Krayin CRM (REST API bundled) on Railway.
#
# webkul/krayin:2.2.0 is the prebuilt app image: Nginx + PHP-FPM + Supervisord,
# Krayin source + krayin/rest-api baked in, and an internal MySQL that seeds
# itself on first boot.
#
# On Railway the persistent volume mounts /var/lib/mysql as root:root with a
# lost+found dir, which breaks the internal MySQL. We wrap the image's entrypoint
# to normalize the volume first, then hand off unchanged.
FROM webkul/krayin:2.2.0

EXPOSE 80

COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

# Setting ENTRYPOINT resets the base image's CMD, so re-declare it (supervisord).
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
