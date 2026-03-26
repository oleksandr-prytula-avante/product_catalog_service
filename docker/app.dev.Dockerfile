FROM golang:1.26-alpine

WORKDIR /usr/src/app

RUN apk add --no-cache docker-cli docker-compose
RUN apk add --no-cache git bash curl

COPY go.mod go.sum* ./
RUN [ -f go.sum ] && go mod download || true

RUN go install github.com/air-verse/air@latest

CMD ["air"]