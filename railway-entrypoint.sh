#!/bin/bash
set -e
# The upstream first-time setup writes the generated APP_KEY into /var/www/.env,
# which lives outside the volume — keep the real file inside the storage volume
# so the key (and thus sessions + encrypted data) survives redeploys.
mkdir -p /var/www/storage/docker
# key:generate only replaces an existing "APP_KEY=" line — seed it or the
# generated key is silently dropped.
if [ ! -s /var/www/storage/docker/.env ]; then
  echo "APP_KEY=" > /var/www/storage/docker/.env
fi
ln -sf storage/docker/.env /var/www/.env

exec /docker/entrypoint.sh "$@"
