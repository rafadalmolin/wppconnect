FROM node:20

WORKDIR /app
COPY . .

# Habilita corepack para gerenciar yarn/pnpm se precisar
RUN corepack enable && \
    if [ -f yarn.lock ]; then yarn install; \
    elif [ -f pnpm-lock.yaml ]; then pnpm install; \
    else npm install; fi && \
    # Garante que tsx esteja disponível no container
    npm install -g tsx

ENV NODE_ENV=production \
    PORT=21465 \
    SESSIONS_DIR=/tokens \
    STORE_SESSION=true

EXPOSE 21465

CMD ["tsx","src/index.ts"]
