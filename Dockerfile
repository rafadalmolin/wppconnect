FROM node:18-alpine

# Diretório de trabalho
WORKDIR /app

# Copiar arquivos para dentro da imagem
COPY . .

# Instalar dependências e evitar problemas com engines
RUN yarn install --production --ignore-engines && yarn add sharp && yarn cache clean

# Compilar o TypeScript
RUN yarn build

# Expor a porta padrão do servidor
EXPOSE 21465

# Comando para rodar o servidor
CMD ["node", "dist/index.js"]


