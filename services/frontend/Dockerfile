# Serve Maxun's prebuilt frontend with an explicit Railway-aware Node server.
# This avoids relying on the upstream shell command or globally installed
# `serve` binary and provides a dedicated health endpoint.
FROM getmaxun/maxun-frontend:v0.0.44

COPY server.mjs /usr/local/lib/maxun-frontend-server.mjs

CMD ["node", "/usr/local/lib/maxun-frontend-server.mjs"]
