FROM node:18-alpine3.17 as builder

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
  && rm -rf /app/dist/index.html /app/node_modules \
  && sha256sum /app/dist/app.js | awk '{ print $1 }' > /app/dist/hash.txt \
  && cat /app/dist/hash.txt

FROM scratch

COPY --from=builder /app /app