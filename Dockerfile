FROM alpine:3.16.0

RUN apk add --no-cache thttpd

RUN adduser -D static
USER static
WORKDIR /home/static

ADD start.sh /start.sh

EXPOSE 80
HEALTHCHECK --start-period=5s --interval=1m --timeout=1s CMD wget -O - http://localhost/healthcheck.json || exit 1

ENTRYPOINT /start.sh
