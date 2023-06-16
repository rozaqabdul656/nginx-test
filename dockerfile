FROM golang:1.19-alpine AS builder
RUN apk update && apk add --no-cache ca-certificates git gcc libc-dev

WORKDIR $GOPATH/src/test-nginx


ENV GOSUMDB=off
ENV GO111MODULE=on GOOS=linux GOARCH=amd64

COPY go.mod go.sum ./

RUN go mod download

COPY . ./

RUN CGO_ENABLED=0 go build -ldflags '-s -w' -o /go/bin/test-nginx main.go

FROM alpine:3.17
RUN apk add --no-cache tzdata ca-certificates libc6-compat

COPY --from=builder /go/bin/test-nginx /go/bin/bountie/test-nginx
COPY --from=builder /go/src/test-nginx/.env /go/src/test-nginx/.env
COPY --from=builder /go/src/test-nginx/assets /assets

ENTRYPOINT ["/go/bin/test-nginx"]
