FROM alpine:3.19

RUN apk add --no-cache bash curl

RUN curl -sSf https://atlasgo.sh | sh

WORKDIR /scripts