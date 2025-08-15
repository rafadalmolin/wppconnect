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

# Copiar tudo primeiro
COPY . .

# Debug e instalação das dependências
RUN echo "=== Estrutura do projeto ===" && \
    ls -la && \
    echo "=== Verificando package.json ===" && \
    if [ -f package.json ]; then \
        echo "package.json encontrado:" && \
        cat package.json; \
    else \
        echo "ERRO: package.json não encontrado!"; \
        echo "Arquivos disponíveis:"; \
        find . -name "*.json" | head -10; \
        exit 1; \
    fi && \
    echo "=== Limpando cache npm ===" && \
    npm cache clean --force && \
    echo "=== Instalando dependências ===" && \
    npm install --verbose

# Instalar tsx globalmente
RUN npm install -g tsx

# Criar diretório para tokens
RUN mkdir -p /tokens

# Variáveis de ambiente
ENV NODE_ENV=production \
    PORT=21465 \
    SESSIONS_DIR=/tokens \
    STORE_SESSION=true \
    PUPPETEER_ARGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage"

EXPOSE 21465

# Verificar arquivo de entrada e definir comando
RUN echo "=== Verificando arquivos de entrada ===" && \
    if [ -f src/index.ts ]; then \
        echo "Encontrado: src/index.ts" && \
        echo 'tsx src/index.ts' > /start.sh; \
    elif [ -f index.ts ]; then \
        echo "Encontrado: index.ts" && \
        echo 'tsx index.ts' > /start.sh; \
    elif [ -f src/index.js ]; then \
        echo "Encontrado: src/index.js" && \
        echo 'node src/index.js' > /start.sh; \
    elif [ -f index.js ]; then \
        echo "Encontrado: index.js" && \
        echo 'node index.js' > /start.sh; \
    elif [ -f package.json ] && grep -q '"start"' package.json; then \
        echo "Usando npm start do package.json" && \
        echo 'npm start' > /start.sh; \
    else \
        echo "ERRO: Nenhum ponto de entrada encontrado!"; \
        echo "Arquivos TypeScript/JavaScript disponíveis:"; \
        find . -name "*.ts" -o -name "*.js" | head -20; \
        exit 1; \
    fi && \
    chmod +x /start.sh

CMD echo "=== INICIANDO APLICAÇÃO ===" && \
    echo "Comando que será executado:" && \
    cat /start.sh && \
    echo "=== EXECUTANDO ===" && \
    /bin/bash /start.sh || (echo "=== ERRO NA EXECUÇÃO ===" && tail -f /dev/null)
