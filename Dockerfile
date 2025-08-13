FROM node:18

RUN apt-get update && apt-get install -y \
  python3 \
  make \
  g++ \
  libvips-dev

WORKDIR /usr/src/app

RUN git clone https://github.com/wppconnect-team/wppconnect-server.git .

RUN yarn install --production --pure-lockfile \
    && yarn add sharp --ignore-engines \
    && yarn cache clean

EXPOSE 21465
CMD ["node", "index.js"]