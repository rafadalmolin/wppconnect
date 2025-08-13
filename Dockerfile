FROM node:20

WORKDIR /app
COPY . .

# Use o gerenciador que tiver lockfile; senão, npm
RUN corepack enable && \
    if [ -f yarn.lock ]; then yarn install; \
    elif [ -f pnpm-lock.yaml ]; then pnpm install; \
    else npm install; fi && \
    # compila só se existir "build"
    node -e "const p=require('./package.json');process.exit(p.scripts&&p.scripts.build?0:1)" && \
      ( [ -f yarn.lock ] && yarn build || [ -f pnpm-lock.yaml ] && pnpm build || npm run build ) || true

ENV NODE_ENV=production \
    PORT=21465 \
    SESSIONS_DIR=/tokens \
    STORE_SESSION=true

EXPOSE 21465
CMD ["npx","tsx","src/index.ts"]
