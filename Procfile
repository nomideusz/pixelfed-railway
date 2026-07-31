fpm: php-fpm{{ getenv "DOCKER_APP_PHP_VERSION" }}
nginx: nginx -g "daemon off;"
horizon: gosu www-data php artisan horizon
scheduler: gosu www-data php artisan schedule:work
