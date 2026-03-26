FROM golang:1.26-alpine

WORKDIR /usr/src/app

COPY go.mod go.sum* ./
RUN [ -f go.sum ] && go mod download || true

COPY . .
RUN CGO_ENABLED=0 go build -trimpath -o /usr/src/app/build .

CMD ["/usr/src/app/build"]