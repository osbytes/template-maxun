# Build Maxun frontend from the git tag so package.frontend.json version
# (shown in the UI) matches the release, then serve with a Railway-aware
# Node static server.
FROM node:22-alpine AS builder

RUN apk add --no-cache git

ARG MAXUN_REF=v0.0.44
WORKDIR /src
RUN git clone --depth 1 --branch "${MAXUN_REF}" https://github.com/getmaxun/maxun.git .

WORKDIR /app
RUN cp /src/package.frontend.json ./package.json \
 && cp /src/index.html ./ \
 && cp /src/vite.config.js ./ \
 && cp /src/tsconfig.json ./ \
 && cp -R /src/src ./src \
 && cp -R /src/public ./public

RUN npm install --legacy-peer-deps

ENV VITE_BACKEND_URL=__VITE_BACKEND_URL__
RUN npm run build

FROM node:22-alpine

WORKDIR /app
COPY --from=builder /app/build ./build
COPY server.mjs ./server.mjs

ENV NODE_ENV=production
EXPOSE 5173

CMD ["node", "server.mjs"]
