FROM node:current-alpine as builder

ENV VUE_APP_BASE_URL ''

WORKDIR /app

COPY package.json package-lock.json /app/

RUN apk add --no-cache wget \
    gcc \
    g++ \
    make \
    zlib-dev \
    libffi-dev \
    openssl-dev \
    musl-dev \
    python3 && ln -sf python3 /usr/bin/python; npm install

COPY . /app

RUN VUE_APP_BASE_URL='' npm run build \
  && rm -rf /app/dist/index.html /app/node_modules

FROM scratch

COPY --from=builder /app /app
