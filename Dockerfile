FROM node:alpine

WORKDIR /app

COPY . /app

RUN npm install --silent

RUN npm run build

RUN rm -rf /app/dist/index.html
