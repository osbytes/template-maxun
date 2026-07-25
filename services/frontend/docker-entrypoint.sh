#!/bin/sh
set -eu

# Railway healthchecks and public routing use $PORT. Upstream Maxun listens on
# FRONTEND_PORT, so keep them aligned and bind on all interfaces.
PORT="${PORT:-${FRONTEND_PORT:-5173}}"
FRONTEND_PORT="${PORT}"
export PORT FRONTEND_PORT

BACKEND="${VITE_BACKEND_URL:-${BACKEND_URL:-http://localhost:8080}}"
export VITE_BACKEND_URL="${BACKEND}"

if [ -d build ]; then
  echo "[maxun-frontend] rewriting __VITE_BACKEND_URL__ -> ${BACKEND}"
  find build -type f \( -name '*.js' -o -name '*.html' -o -name '*.css' \) \
    -exec sed -i "s|__VITE_BACKEND_URL__|${BACKEND}|g" {} +
fi

echo "[maxun-frontend] listening on 0.0.0.0:${FRONTEND_PORT}"
exec serve -s build -l "tcp://0.0.0.0:${FRONTEND_PORT}"
