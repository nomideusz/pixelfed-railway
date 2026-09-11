FROM ghcr.io/jippi/docker-pixelfed:v0.12.7-nginx-8.4-bookworm

# Combined single-service image for Railway: nginx + php-fpm + horizon (queues)
# + scheduler in one container sharing one storage volume — Railway volumes
# can't be shared across services.
# Files are overwritten (not deleted): Railway's layer flattening resurrects
# whiteout'd files.
ENV DOCKER_APP_PHP_VERSION=8.4

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
