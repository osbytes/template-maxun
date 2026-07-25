#!/bin/sh
set -eu

BACKEND_UPSTREAM="${BACKEND_UPSTREAM:-backend:8080}"
FRONTEND_UPSTREAM="${FRONTEND_UPSTREAM:-frontend:5173}"
LISTEN_PORT="${PORT:-8080}"

# Strip accidental scheme prefixes from Railway template vars.
BACKEND_UPSTREAM="${BACKEND_UPSTREAM#http://}"
BACKEND_UPSTREAM="${BACKEND_UPSTREAM#https://}"
FRONTEND_UPSTREAM="${FRONTEND_UPSTREAM#http://}"
FRONTEND_UPSTREAM="${FRONTEND_UPSTREAM#https://}"

RESOLVER="$(awk '/^nameserver/ { print $2; exit }' /etc/resolv.conf)"
if [ -z "${RESOLVER}" ]; then
  RESOLVER="127.0.0.11"
fi

# nginx requires bracketed IPv6 literals in the resolver directive.
case "${RESOLVER}" in
  *:*)
    case "${RESOLVER}" in
      \[*\]) ;;
      *) RESOLVER="[${RESOLVER}]" ;;
    esac
    ;;
esac

echo "[maxun-gateway] listen=${LISTEN_PORT}"
echo "[maxun-gateway] backend=${BACKEND_UPSTREAM}"
echo "[maxun-gateway] frontend=${FRONTEND_UPSTREAM}"
echo "[maxun-gateway] resolver=${RESOLVER}"

sed \
  -e "s|__LISTEN_PORT__|${LISTEN_PORT}|g" \
  -e "s|__BACKEND_UPSTREAM__|${BACKEND_UPSTREAM}|g" \
  -e "s|__FRONTEND_UPSTREAM__|${FRONTEND_UPSTREAM}|g" \
  -e "s|__RESOLVER__|${RESOLVER}|g" \
  /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

nginx -t
exec nginx -g "daemon off;"
