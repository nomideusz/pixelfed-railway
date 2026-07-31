FROM ghcr.io/jippi/docker-pixelfed:v0.12.7-nginx-8.4-bookworm

# Combined single-service image for Railway: nginx + php-fpm + horizon (queues)
# + scheduler in one container sharing one storage volume — Railway volumes
# can't be shared across services.
# Files are overwritten (not deleted): Railway's layer flattening resurrects
# whiteout'd files.
ENV DOCKER_APP_PHP_VERSION=8.4

COPY Procfile /docker/templates/var/www/Procfile
COPY 13-make-admin.sh /docker/entrypoint.d/13-make-admin.sh
COPY railway-entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh /docker/entrypoint.d/13-make-admin.sh

ENTRYPOINT ["/railway-entrypoint.sh"]
CMD ["forego", "start", "-r"]
