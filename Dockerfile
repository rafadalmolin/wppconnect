FROM node:18-slim

# Instala dependências do sistema para o sharp funcionar
RUN apt-get update && apt-get install -y \
  build-essential \
  libcairo2-dev \
  libjpeg-dev \
  libpango1.0-dev \
  libgif-dev \
  librsvg2-dev \
  libvips-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY package.json yarn.lock ./

# Agora sim, instala as libs
RUN yarn install --production --pure-lockfile

# Adiciona sharp após dependências do sistema estarem ok
RUN yarn add sharp --ignore-engines && yarn cache clean

COPY . .

EXPOSE 21465

CMD ["yarn", "start"]
