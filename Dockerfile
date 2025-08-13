# Etapa de build
FROM node:18-slim AS build

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*

# Copia apenas o package.json inicialmente (sem yarn.lock)
COPY package.json ./

# Instala dependências
RUN yarn install --production --ignore-engines

# Copia todo o restante do código-fonte
COPY . .

# Compila
RUN yarn build

# Etapa de runtime
FROM node:18-slim

WORKDIR /usr/src/app

COPY --from=build /usr/src/app /usr/src/app

EXPOSE 21465

CMD ["node", "dist/index.js"]
