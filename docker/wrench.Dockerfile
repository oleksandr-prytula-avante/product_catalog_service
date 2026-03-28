FROM ghcr.io/cloudspannerecosystem/wrench:1.13.2 AS wrench

FROM alpine:3

COPY --from=wrench /wrench /usr/local/bin/wrench
