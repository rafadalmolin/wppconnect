# Multi-stage build para otimizar o tamanho final
FROM node:20-alpine AS base

# Instalar dependências necessárias para Puppeteer
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    curl \
    && rm -rf /var/cache/apk/*

# Configurar Puppeteer para usar Chromium do sistema
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /app

# Copiar package.json e yarn.lock/package-lock.json se existir
COPY package*.json ./
COPY yarn.lock* ./

# Instalar dependências
RUN if [ -f yarn.lock ]; then \
    yarn install --production --frozen-lockfile; \
    elif [ -f package-lock.json ]; then \
    npm ci --only=production; \
    else \
    npm install --production; \
    fi

# Instalar tsx globalmente para executar TypeScript
RUN npm install -g tsx

# Stage para desenvolvimento (com devDependencies)
FROM base AS dev
RUN if [ -f yarn.lock ]; then \
    yarn install --frozen-lockfile; \
    elif [ -f package-lock.json ]; then \
    npm ci; \
    else \
    npm install; \
    fi

# Stage de produção
FROM base AS production

# Copiar código fonte
COPY . .

# Criar diretório para tokens
RUN mkdir -p /tokens && chmod 755 /tokens

# Configurar variáveis de ambiente
ENV NODE_ENV=production \
    PORT=21465 \
    SESSIONS_DIR=/tokens \
    STORE_SESSION=true

# Expor porta
EXPOSE 21465

# Criar usuário não-root para segurança
RUN addgroup -g 1001 -S nodejs && \
    adduser -S wppconnect -u 1001 -G nodejs

# Alterar proprietário dos arquivos
RUN chown -R wppconnect:nodejs /app /tokens

# Mudar para usuário não-root
USER wppconnect

# Comando para iniciar a aplicação
CMD ["tsx", "src/index.ts"]
