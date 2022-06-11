FROM alpine:3.16.0

RUN apk add --no-cache thttpd

RUN adduser -D static
USER static
WORKDIR /home/static

ADD start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT /start.sh
