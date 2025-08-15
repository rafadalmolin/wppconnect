FROM node:20

# Instalar dependências do sistema para Puppeteer
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgdk-pixbuf2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxss1 \
    libxtst6 \
    lsb-release \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar e instalar dependências
COPY package*.json ./
RUN npm install

# Instalar tsx globalmente
RUN npm install -g tsx

# Copiar código fonte
COPY . .

# Criar diretório para tokens
RUN mkdir -p /tokens

# Variáveis de ambiente
ENV NODE_ENV=production \
    PORT=21465 \
    SESSIONS_DIR=/tokens \
    STORE_SESSION=true \
    PUPPETEER_ARGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage"

EXPOSE 21465

CMD ["tsx", "src/index.ts"]
