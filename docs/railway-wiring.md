# Railway template wiring

Publish this as a Railway template named `maxun` (not `template-maxun`).

Railway does not deploy `docker-compose.yml` directly. Recreate its topology in
the template composer with services named exactly `frontend`, `backend`,
`browser`, `postgres`, and `minio`.

## Application services

Use `https://github.com/osbytes/template-maxun` as the source for these three
services. Set each service's root directory as shown; its local `railway.toml`
sets the Dockerfile and healthcheck.

### frontend

- Root directory: `/services/frontend`
- Public networking: enabled
- Variables:

```text
PORT=5173
FRONTEND_PORT=5173
PUBLIC_URL=https://${{frontend.RAILWAY_PUBLIC_DOMAIN}}
VITE_PUBLIC_URL=https://${{frontend.RAILWAY_PUBLIC_DOMAIN}}
BACKEND_URL=https://${{backend.RAILWAY_PUBLIC_DOMAIN}}
VITE_BACKEND_URL=https://${{backend.RAILWAY_PUBLIC_DOMAIN}}
```

Keep the public domain target port at `5173`. The frontend Dockerfile builds
Maxun's Vite assets from the published source image, then serves them with a
Node process that binds `0.0.0.0:$PORT`, rewrites the backend URL at request
time, and exposes `/health` for Railway healthchecks.

### backend

- Root directory: `/services/backend`
- Public networking: enabled
- Recommended memory: at least 4 GB
- Variables:

```text
PORT=8080
BACKEND_PORT=8080
NODE_ENV=production
BACKEND_URL=https://${{backend.RAILWAY_PUBLIC_DOMAIN}}
PUBLIC_URL=https://${{frontend.RAILWAY_PUBLIC_DOMAIN}}
VITE_PUBLIC_URL=https://${{frontend.RAILWAY_PUBLIC_DOMAIN}}
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

## Deployment notes

- Keep all five services in one Railway environment so reference variables and
  private DNS resolve correctly.
- Do not add Redis: Maxun's current Compose file still documents Redis
  variables, but no Redis service or active runtime dependency is present.
- Frontend and backend public domains must exist before their reference
  variables resolve.
- Maxun creates its screenshot buckets and public-read object policy lazily on
  first use.
