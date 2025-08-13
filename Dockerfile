# Etapa 1: Build
FROM node:18-slim AS build

WORKDIR /usr/src/app

# Adiciona dependências nativas necessárias
RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*

COPY package.json yarn.lock ./
RUN yarn install --production --ignore-engines

# Copia os arquivos da aplicação
COPY . .

# Compila o TypeScript
RUN yarn build

# Etapa 2: Runtime
FROM node:18-slim

WORKDIR /usr/src/app

COPY --from=build /usr/src/app /usr/src/app

EXPOSE 21465

CMD ["node", "dist/index.js"]


