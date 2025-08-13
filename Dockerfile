# Etapa base
FROM node:18-alpine

# Diretório de trabalho no container
WORKDIR /usr/src/app

# Copia os arquivos para o container
COPY . .

# Instala dependências (ignora engines e lida com o sharp)
RUN yarn install --production --ignore-engines \
 && yarn add sharp --ignore-engines \
 && yarn cache clean

# Expõe a porta usada pelo servidor
EXPOSE 21465

# Comando de inicialização
CMD ["yarn", "start"]
