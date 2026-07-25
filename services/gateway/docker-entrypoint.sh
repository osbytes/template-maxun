#!/bin/sh
set -eu

BACKEND_UPSTREAM="${BACKEND_UPSTREAM:-backend:8080}"
FRONTEND_UPSTREAM="${FRONTEND_UPSTREAM:-frontend:5173}"
LISTEN_PORT="${PORT:-8080}"

sed \
  -e "s|listen 8080;|listen ${LISTEN_PORT};|g" \
  -e "s|http://backend:8080|http://${BACKEND_UPSTREAM}|g" \
  -e "s|http://frontend:5173|http://${FRONTEND_UPSTREAM}|g" \
  /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

exec nginx -g "daemon off;"
