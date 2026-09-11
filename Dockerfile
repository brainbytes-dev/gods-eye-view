FROM node:24-slim

WORKDIR /app

# Skip Puppeteer's Chromium download (devDependency, only used by local QA
# scripts, not by build or by the served app).
ENV PUPPETEER_SKIP_DOWNLOAD=true \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# python3/build-essential: fallback toolchain in case sharp has no prebuilt
# binary for this platform/arch.
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 build-essential ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# All of the app's live-data endpoints (AIS, OpenSky, FIRMS, TomTom, OpenAI
# realtime, ...) are Vite server middleware registered via
# configurePreviewServer, so the production server IS `vite preview`, not a
# static file server. vite/vite-plugin-cesium stay in node_modules on purpose.
ENV HOST=0.0.0.0
ENV PORT=4173
EXPOSE 4173

CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "4173"]
