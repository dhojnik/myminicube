#!/bin/sh
set -e

WEBROOT="/var/www/app"

if [ -z "$GIT_REPO_URL" ]; then
    echo "[error] GIT_REPO_URL environment variable is missing!"
    exit 1
fi

echo "[info] Using repository: $GIT_REPO_URL"
echo "[info] Using branch: $GIT_BRANCH"

mkdir -p "$WEBROOT"
mkdir -p /var/www/cgi-bin

if [ ! -d "$WEBROOT/.git" ]; then
    echo "[info] Cloning website from repo"
    git clone --depth 1 --branch "$GIT_BRANCH" "$GIT_REPO_URL" "$WEBROOT"
else
    echo "[info] Updating existing repository"
    cd "$WEBROOT"
    git fetch origin "$GIT_BRANCH" || true
    git pull --ff-only origin "$GIT_BRANCH" || true
fi

chmod -R +x /var/www/cgi-bin || true

echo "[info] Starting Lighttpd"
exec /usr/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf

