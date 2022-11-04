FROM node:18-alpine3.16 as builder

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

RUN npm run build \
  && rm -rf /app/dist/index.html /app/node_modules

FROM scratch

COPY --from=builder /app /app
