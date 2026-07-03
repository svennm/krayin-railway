# Deploy Krayin CRM (REST API bundled) on Railway.
#
# webkul/krayin:2.2.0 is the prebuilt app image: Nginx + PHP-FPM + Supervisord,
# Krayin source + krayin/rest-api baked in, and an internal MySQL that seeds
# itself on first boot (verified: empty /var/lib/mysql -> 57 tables + admin user).
#
# We add nothing but the port hint — the image's own entrypoint.sh applies the
# APP_URL/APP_KEY/DB_* env vars, starts MySQL, and hands off to supervisord.
# (Do NOT override CMD: the entrypoint execs the CMD, i.e. supervisord.)
FROM webkul/krayin:2.2.0

EXPOSE 80
