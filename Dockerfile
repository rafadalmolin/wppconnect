# ---------- Build ----------
FROM node:20-bookworm-slim AS build

ENV NODE_ENV=production \
    PUPPETEER_PRODUCT=chrome \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=0

# deps para puppeteer e build nativo
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git python3 make g++ \
    fonts-liberation fonts-noto-color-emoji dumb-init \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN corepack enable

# cache de deps
COPY package.json ./
COPY package-lock.json* . 2>/dev/null || true
COPY yarn.lock* . 2>/dev/null || true
COPY pnpm-lock.yaml* . 2>/dev/null || true

# instala conforme lock encontrado
RUN /bin/sh -lc '\
  set -eux; \
  if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
  elif [ -f pnpm-lock.yaml ]; then pnpm install --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci --omit=dev=false; \
  else npm install; fi'

# copia o resto do código
COPY . .

# compila se houver script build
RUN /bin/sh -lc '\
  if node -e "const p=require(\"./package.json\");process.exit(p.scripts&&p.scripts.build?0:1)"; then \
    echo ">> build"; \
    if [ -f yarn.lock ]; then yarn build; \
    elif [ -f pnpm-lock.yaml ]; then pnpm build; \
    else npm run build; fi; \
  else \
    echo ">> sem script build"; \
  fi'

# ---------- Runtime ----------
FROM node:20-bookworm-slim AS runtime

ENV NODE_ENV=production \
    PORT=21465 \
    PUPPETEER_PRODUCT=chrome

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    fonts-liberation fonts-noto-color-emoji dumb-init \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# traz deps e artefatos
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist 2>/dev/null || true
COPY --from=build /app/src ./src
COPY --from=build /app/package.json ./package.json

# copia o entrypoint (arquivo separado no repo)
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

EXPOSE 21465

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=5 \
  CMD node -e "require('http').get('http://127.0.0.1:'+(process.env.PORT||21465)+'/',r=>process.exit(r.statusCode<500?0:1)).on('error',()=>process.exit(1))"

ENTRYPOINT ["/app/docker-entrypoint.sh"]
