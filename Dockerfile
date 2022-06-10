FROM alpine:3.16.0

RUN apk add --no-cache thttpd

RUN adduser -D static
USER static
WORKDIR /home/static

ADD --chmod=+x start.sh /start.sh

ENTRYPOINT /start.sh
