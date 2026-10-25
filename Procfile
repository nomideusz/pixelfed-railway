fpm: php-fpm{{ getenv "DOCKER_APP_PHP_VERSION" }}
nginx: nginx -g "daemon off;"
queue: sh -c 'if [ "$PF_HORIZON" = 1 ]; then exec gosu www-data php artisan horizon; fi; exec gosu www-data php artisan queue:work redis --queue=high,inbox,pushnotify,follow,deliver,default,shared,feed,story,groups,mmo,low,delete,adelete,move,intbg --sleep=3 --tries=3 --max-time=3600'
scheduler: sh -c 'while :; do gosu www-data php artisan schedule:run --no-interaction; sleep 60; done'
