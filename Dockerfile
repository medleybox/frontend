FROM node:alpine as builder

ENV VUE_APP_BASE_URL ''

WORKDIR /app

COPY . /app

RUN npm install --silent \
  && npm run build \
  && rm -rf /app/dist/index.html

FROM scratch

COPY --from=builder /app/dist /app
