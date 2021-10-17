FROM node:alpine as build

ENV NODE_ENV=production

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci --only=production

COPY postgraphile.js .

USER node

EXPOSE 3000

CMD ["node", "postgraphile.js"]