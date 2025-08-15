FROM node:20

# Instalar dependências do sistema
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
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clonar o repositório diretamente
RUN git clone https://github.com/rafadalmolin/wppconnect.git . && \
    echo "=== Arquivos clonados ===" && \
    ls -la && \
    echo "=== Verificando package.json ===" && \
    if [ -f package.json ]; then \
        cat package.json; \
    else \
        echo "package.json não encontrado!"; \
        exit 1; \
    fi

# Instalar dependências
RUN npm cache clean --force && \
    npm install

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

# Verificar se o arquivo de entrada existe
RUN if [ -f src/index.ts ]; then \
        echo "Arquivo src/index.ts encontrado"; \
    elif [ -f index.ts ]; then \
        echo "Arquivo index.ts encontrado no root"; \
    elif [ -f src/index.js ]; then \
        echo "Arquivo src/index.js encontrado"; \
    elif [ -f index.js ]; then \
        echo "Arquivo index.js encontrado no root"; \
    else \
        echo "Nenhum arquivo de entrada encontrado!"; \
        echo "Estrutura do projeto:"; \
        find . -name "*.ts" -o -name "*.js" | head -20; \
        exit 1; \
    fi

# Comando flexível - vai tentar diferentes pontos de entrada
CMD if [ -f src/index.ts ]; then \
        tsx src/index.ts; \
    elif [ -f index.ts ]; then \
        tsx index.ts; \
    elif [ -f src/index.js ]; then \
        node src/index.js; \
    elif [ -f index.js ]; then \
        node index.js; \
    else \
        npm start; \
    fi
