FROM golang:1.26-alpine

WORKDIR /usr/src/app

COPY go.mod go.sum* ./
RUN [ -f go.sum ] && go mod download || true

COPY . .
RUN go build -v -o /usr/local/bin/app ./...

CMD ["/usr/local/bin/app"]