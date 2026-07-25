# Maxun on Railway

Railway template scaffolding for [Maxun](https://github.com/getmaxun/maxun), an
open-source no-code platform for web scraping, crawling, search, and AI data
extraction. The published Railway marketplace name is **maxun**.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/lNjLEn?referralCode=ToZEjF&utm_medium=integration&utm_source=template&utm_campaign=generic)

The template runs Maxun as six Railway services:

- `gateway` — public nginx entrypoint (UI + API on one origin)
- `frontend` — Maxun web UI (private)
- `backend` — API, workers, schedules, and WebSocket server (private)
- `browser` — isolated Playwright/Chromium service
- `postgres` — application and session data
- `minio` — screenshots and document storage

## Railway template

Follow [`docs/railway-wiring.md`](docs/railway-wiring.md) when creating or
updating the marketplace template. It contains the exact service names,
reference variables, generated secrets, ports, healthchecks, and volume mounts.

Only the **gateway** URL should be opened in a browser. Maxun auth depends on
an httpOnly cookie, which requires the UI and API to share one public origin.

The wrappers currently track Maxun `v0.0.44`. The frontend is built from that
git tag. Maxun has no versioned browser image for the release, so the browser
wrapper pins the corresponding `linux/amd64` image digest.

## Run locally

1. Copy `.env.example` to `.env`.
2. Replace `JWT_SECRET`, `SESSION_SECRET`, and `ENCRYPTION_KEY` with random
   values.
3. Start the stack:

```bash
docker compose up --build
```

Open `http://localhost:8080` (gateway). The MinIO console is at
`http://localhost:9001`.

## Updating Maxun

1. Bump `MAXUN_REF` / image tags in `services/*/Dockerfile`.
2. Resolve and pin the new browser image's `linux/amd64` digest.
3. Run `docker compose config` and smoke-test registration, login, recording,
   and a scheduled robot run through the gateway URL.

## License

This repository contains deployment configuration only. Maxun is distributed
under AGPL-3.0-or-later; see the
[upstream license](https://github.com/getmaxun/maxun/blob/develop/LICENSE).
