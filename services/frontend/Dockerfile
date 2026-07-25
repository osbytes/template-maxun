# The published maxun-frontend image is a Vite source tree (not a static
# production build). Compile assets here, then serve with a small Node server
# that binds Railway's $PORT and exposes /health.
FROM getmaxun/maxun-frontend:v0.0.44 AS builder

WORKDIR /app
ENV VITE_BACKEND_URL=__VITE_BACKEND_URL__
RUN npm run build

FROM node:22-alpine

WORKDIR /app
COPY --from=builder /app/build ./build
COPY server.mjs ./server.mjs

ENV NODE_ENV=production
EXPOSE 5173

CMD ["node", "server.mjs"]
