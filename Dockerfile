FROM node:16-alpine as builder

ENV VUE_APP_BASE_URL ''

WORKDIR /app

COPY package.json package-lock.json /app/

RUN npm install

COPY . /app

RUN VUE_APP_BASE_URL='' npm run build \
  && rm -rf /app/dist/index.html

FROM scratch

COPY --from=builder /app /app
