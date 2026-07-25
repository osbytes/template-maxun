import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const BUILD_DIR = fs.existsSync("/app/build")
  ? "/app/build"
  : path.join(__dirname, "build");

const PORT = Number(process.env.PORT || process.env.FRONTEND_PORT || 5173);
const BACKEND =
  process.env.VITE_BACKEND_URL ||
  process.env.BACKEND_URL ||
  "http://localhost:8080";

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".ico": "image/x-icon",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
  ".map": "application/json; charset=utf-8",
};

function rewriteBackendPlaceholder(content) {
  return content.split("__VITE_BACKEND_URL__").join(BACKEND);
}

function send(res, status, body, headers = {}) {
  res.writeHead(status, headers);
  res.end(body);
}

function resolveFile(urlPath) {
  const clean = decodeURIComponent(urlPath.split("?")[0].split("#")[0]);
  const relative = clean === "/" ? "index.html" : clean.replace(/^\/+/, "");
  const candidate = path.normalize(path.join(BUILD_DIR, relative));

  if (!candidate.startsWith(BUILD_DIR)) {
    return null;
  }

  if (fs.existsSync(candidate) && fs.statSync(candidate).isFile()) {
    return candidate;
  }

  // SPA fallback
  const index = path.join(BUILD_DIR, "index.html");
  return fs.existsSync(index) ? index : null;
}

if (!fs.existsSync(BUILD_DIR)) {
  console.error(`[maxun-frontend] build directory missing: ${BUILD_DIR}`);
  process.exit(1);
}

console.log(`[maxun-frontend] backend URL -> ${BACKEND}`);
console.log(`[maxun-frontend] serving ${BUILD_DIR} on 0.0.0.0:${PORT}`);

const server = http.createServer((req, res) => {
  const url = req.url || "/";

  if (url === "/health" || url.startsWith("/health?")) {
    send(res, 200, "ok", { "Content-Type": "text/plain; charset=utf-8" });
    return;
  }

  const filePath = resolveFile(url);
  if (!filePath) {
    send(res, 404, "Not Found", { "Content-Type": "text/plain; charset=utf-8" });
    return;
  }

  const ext = path.extname(filePath).toLowerCase();
  const type = MIME[ext] || "application/octet-stream";
  let body = fs.readFileSync(filePath);

  if (ext === ".js" || ext === ".html" || ext === ".css" || ext === ".map") {
    body = Buffer.from(rewriteBackendPlaceholder(body.toString("utf8")), "utf8");
  }

  send(res, 200, body, {
    "Content-Type": type,
    "Cache-Control": ext === ".html" ? "no-cache" : "public, max-age=31536000, immutable",
  });
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`[maxun-frontend] ready on http://0.0.0.0:${PORT}`);
});
