#!/bin/bash
: "${ENTRYPOINT_ROOT:="/docker"}"

# shellcheck source=SCRIPTDIR/../helpers.sh
source "${ENTRYPOINT_ROOT}/helpers.sh"

entrypoint-set-script-name "$0"

# Promote the account named in PF_MAKE_ADMIN to admin (idempotent, no toggle —
# the stock `artisan user:admin` flips the flag and prompts interactively).
if [ -z "${PF_MAKE_ADMIN:-}" ]; then
    exit 0
fi

PHP='$u=App\User::whereUsername(getenv("PF_MAKE_ADMIN"))->first(); if(!$u){echo "PF_MAKE_ADMIN: no such user\n";}elseif($u->is_admin){echo "PF_MAKE_ADMIN: already admin\n";}else{$u->is_admin=true;$u->save();echo "PF_MAKE_ADMIN: promoted\n";}'

XDG_CONFIG_HOME=/tmp gosu www-data php artisan tinker --execute "$PHP" \
    || log-warning "PF_MAKE_ADMIN promotion failed"
