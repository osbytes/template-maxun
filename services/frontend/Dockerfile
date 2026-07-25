# Maxun replaces VITE_BACKEND_URL in the built assets when the container starts,
# so one image can be wired to the generated Railway backend domain.
# Railway routes and healthchecks $PORT; upstream uses FRONTEND_PORT — the
# entrypoint keeps them aligned and binds on 0.0.0.0.
FROM getmaxun/maxun-frontend:v0.0.44

COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
