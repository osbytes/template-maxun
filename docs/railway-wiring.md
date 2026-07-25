# Railway template wiring

Publish this as a Railway template named `maxun` (not `template-maxun`).

Railway does not deploy `docker-compose.yml` directly. Recreate its topology in
the template composer with services named exactly `gateway`, `frontend`,
`backend`, `browser`, `postgres`, and `minio`.

Maxun auth uses an httpOnly cookie. That only works when the browser UI and
API share one public origin, so **only `gateway` (and MinIO) should be public**.

## Application services

Use `https://github.com/osbytes/template-maxun` as the source for these services.
Set each service's root directory as shown; its local `railway.toml` sets the
Dockerfile and healthcheck.

### gateway

- Root directory: `/services/gateway`
- Public networking: enabled (this is the only app URL users open)
- Variables:

```text
PORT=8080
BACKEND_UPSTREAM=${{backend.RAILWAY_PRIVATE_DOMAIN}}:8080
FRONTEND_UPSTREAM=${{frontend.RAILWAY_PRIVATE_DOMAIN}}:5173
```

Use `host:port` only (no `http://`). Keep the public domain target port at `8080`.

### frontend

- Root directory: `/services/frontend`
- Public networking: **disabled** (reached only via gateway)
- Variables:

```text
PORT=5173
FRONTEND_PORT=5173
PUBLIC_URL=https://${{gateway.RAILWAY_PUBLIC_DOMAIN}}
VITE_PUBLIC_URL=https://${{gateway.RAILWAY_PUBLIC_DOMAIN}}
BACKEND_URL=https://${{gateway.RAILWAY_PUBLIC_DOMAIN}}
VITE_BACKEND_URL=https://${{gateway.RAILWAY_PUBLIC_DOMAIN}}
```

Built from Maxun git tag `v0.0.44` so the UI version chip matches the release.
The Node server rewrites `__VITE_BACKEND_URL__` at request time and exposes
`/health`.

### backend

- Root directory: `/services/backend`
- Public networking: **disabled** (reached only via gateway)
- Recommended memory: at least 4 GB
- Variables:

```text
PORT=8080
BACKEND_PORT=8080
NODE_ENV=production
BACKEND_URL=https://${{gateway.RAILWAY_PUBLIC_DOMAIN}}
PUBLIC_URL=https://${{gateway.RAILWAY_PUBLIC_DOMAIN}}
VITE_PUBLIC_URL=https://${{gateway.RAILWAY_PUBLIC_DOMAIN}}
JWT_SECRET=${{secret(64)}}
SESSION_SECRET=${{secret(64)}}
ENCRYPTION_KEY=${{secret(64, "abcdef0123456789")}}
DB_NAME=${{postgres.POSTGRES_DB}}
DB_USER=${{postgres.POSTGRES_USER}}
DB_PASSWORD=${{postgres.POSTGRES_PASSWORD}}
DB_HOST=${{postgres.RAILWAY_PRIVATE_DOMAIN}}
DB_PORT=5432
DB_SSL=false
MINIO_ENDPOINT=${{minio.RAILWAY_PRIVATE_DOMAIN}}
MINIO_PORT=9000
MINIO_ACCESS_KEY=${{minio.MINIO_ROOT_USER}}
MINIO_SECRET_KEY=${{minio.MINIO_ROOT_PASSWORD}}
MINIO_PUBLIC_URL=https://${{minio.RAILWAY_PUBLIC_DOMAIN}}
BROWSER_WS_HOST=${{browser.RAILWAY_PRIVATE_DOMAIN}}
BROWSER_WS_PORT=3001
BROWSER_HEALTH_PORT=3002
MAXUN_TELEMETRY=true
```

Expose optional `ANTHROPIC_API_KEY` and `OPENAI_API_KEY` variables to deployers
who want Maxun's AI mode. OAuth integrations require the optional variables
listed in Maxun's environment-variable documentation.

### browser

- Root directory: `/services/browser`
- Public networking: disabled
- Recommended memory: at least 2 GB
- Variables:

```text
PORT=3002
NODE_ENV=production
BROWSER_WS_PORT=3001
BROWSER_HEALTH_PORT=3002
BROWSER_WS_HOST=${{browser.RAILWAY_PRIVATE_DOMAIN}}
PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
```

The health server listens on `3002`; the backend connects to Chromium over
private-network port `3001`. Chromium is launched with `--no-sandbox`, so the
Docker Compose `SYS_ADMIN` capability is not required on Railway.

## Data services

### postgres

- Image: `postgres:13-alpine`
- Public networking: disabled
- Volume: mount at `/var/lib/postgresql/data`
- Variables:

```text
POSTGRES_DB=maxun
POSTGRES_USER=maxun
POSTGRES_PASSWORD=${{secret(32)}}
```

### minio

- Image: `minio/minio:RELEASE.2025-09-07T16-13-09Z`
- Start command: `minio server /data --console-address :9001`
- Public networking: enabled on port `9000`
- Volume: mount at `/data`
- Variables:

```text
PORT=9000
MINIO_ROOT_USER=maxun
MINIO_ROOT_PASSWORD=${{secret(32)}}
```

MinIO must have a public domain because Maxun stores browser-facing screenshot
URLs. Its console on port `9001` should remain private.

## Auth notes

- Open the **gateway** URL only (not the old frontend/backend domains).
- Register once at `/register`, then log in at `/login`.
- Maxun has no built-in “disable registration” flag. After creating your
  account, block `POST /auth/register` at an edge proxy if you need lockdown.
- JWT is stored in an httpOnly `token` cookie (not a response body field or
  `Authorization` header). Same-origin via the gateway is required for that
  cookie to stick.

## Deployment notes

- Keep all six services in one Railway environment so reference variables and
  private DNS resolve correctly.
- Do not add Redis: Maxun's current Compose file still documents Redis
  variables, but no Redis service or active runtime dependency is present.
- Gateway, frontend, and backend must exist before their reference variables
  resolve.
- Maxun creates its screenshot buckets and public-read object policy lazily on
  first use.
