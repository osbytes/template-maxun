# Maxun on Railway

Railway template scaffolding for [Maxun](https://github.com/getmaxun/maxun), an
open-source no-code platform for web scraping, crawling, search, and AI data
extraction. The published Railway marketplace name is **maxun**.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/lNjLEn?referralCode=ToZEjF&utm_medium=integration&utm_source=template&utm_campaign=generic)

The template runs Maxun as five Railway services:

- `frontend` — Maxun web UI
- `backend` — API, workers, schedules, and WebSocket server
- `browser` — isolated Playwright/Chromium service
- `postgres` — application and session data
- `minio` — screenshots and document storage

## Railway template

Follow [`docs/railway-wiring.md`](docs/railway-wiring.md) when creating or
updating the marketplace template. It contains the exact service names,
reference variables, generated secrets, ports, healthchecks, and volume mounts.

The application wrappers currently track Maxun `v0.0.44`. Maxun has no
versioned browser image for that release, so the browser wrapper pins the
corresponding `linux/amd64` image digest.

## Run locally

1. Copy `.env.example` to `.env`.
2. Replace `JWT_SECRET`, `SESSION_SECRET`, and `ENCRYPTION_KEY` with random
   values.
3. Start the stack:

```bash
docker compose up --build
```

Open `http://localhost:5173`. The backend API is available at
`http://localhost:8080`, and the MinIO console is at
`http://localhost:9001`.

## Updating Maxun

1. Confirm matching backend and frontend tags exist on Docker Hub.
2. Update the image tags in `services/backend/Dockerfile`,
   `services/frontend/Dockerfile`, and `docker-compose.yml` if applicable.
3. Resolve and pin the new browser image's `linux/amd64` digest.
4. Run `docker compose config` and smoke-test registration, recording, and a
   scheduled robot run.

## License

This repository contains deployment configuration only. Maxun is distributed
under AGPL-3.0-or-later; see the
[upstream license](https://github.com/getmaxun/maxun/blob/develop/LICENSE).
