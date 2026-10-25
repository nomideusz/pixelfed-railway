FROM ghcr.io/jippi/docker-pixelfed:v0.15.0-nginx-8.4-bookworm

# Combined single-service image for Railway: nginx + php-fpm + horizon (queues)
# + scheduler in one container sharing one storage volume — Railway volumes
# can't be shared across services.
# Files are overwritten (not deleted): Railway's layer flattening resurrects
# whiteout'd files.
ENV DOCKER_APP_PHP_VERSION=8.4

# Horizon runs a master, one supervisor per pool and the pool workers, each a
# ~100 MB PHP process: 10+ processes (~1 GB) on Pixelfed 0.15's five pools, so
# the app OOMs on the 0.5 GB Free plan. The Procfile runs one `queue:work` over
# every Horizon queue in priority order instead, and the scheduler as a
# `schedule:run` loop rather than a resident `schedule:work` process.
# ponytail: one queue worker; set PF_HORIZON=1 on a busy instance to get the
# full Horizon pools back (HORIZON_*_MAX_PROCESSES below then apply).
ENV HORIZON_BALANCE_STRATEGY=false \
    HORIZON_MAX_PROCESSES=1 \
    HORIZON_FANOUT_MAX_PROCESSES=1 \
    HORIZON_DELIVER_MAX_PROCESSES=1 \
    HORIZON_MEDIA_MAX_PROCESSES=1 \
    HORIZON_BACKGROUND_MAX_PROCESSES=1

# Template updates bump the image; without this the new code runs against the
# old schema until someone runs `artisan migrate` by hand.
ENV DB_APPLY_NEW_MIGRATIONS_AUTOMATICALLY=1

# nginx `worker_processes auto` counts host cores, not the container's CPU
# quota: Railway Metal hosts show 48, so nginx forks 48 workers (~30 MB each,
# ~1.5 GB idle) and the container is OOM-killed on the Trial (1 GB) and Free
# (0.5 GB) plans before the health check passes. The image renders nginx.conf
# from this template at boot, so patch the template.
RUN sed -i -E 's/^worker_processes[[:space:]]+auto;/worker_processes 2;/' /docker/templates/etc/nginx/nginx.conf \
    && grep -q '^worker_processes 2;' /docker/templates/etc/nginx/nginx.conf

COPY Procfile /docker/templates/var/www/Procfile
COPY 13-make-admin.sh /docker/entrypoint.d/13-make-admin.sh
COPY railway-entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh /docker/entrypoint.d/13-make-admin.sh

ENTRYPOINT ["/railway-entrypoint.sh"]
CMD ["forego", "start", "-r"]
