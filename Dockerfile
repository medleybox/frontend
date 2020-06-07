FROM node:alpine as builder

WORKDIR /app

COPY . /app

RUN npm install --silent \
  && npm run build \
  && rm -rf /app/dist/index.html

FROM scratch

COPY --from=builder /app/dist /app
