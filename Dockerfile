FROM alpine:3.16.0

RUN apk add --no-cache thttpd

RUN adduser -D static
USER static
WORKDIR /home/static

ADD start.sh /start.sh

EXPOSE 80
ENTRYPOINT /start.sh
