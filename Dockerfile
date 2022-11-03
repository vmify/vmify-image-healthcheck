FROM busybox:1.34.1

ADD start.sh /start.sh

EXPOSE 80
HEALTHCHECK --start-period=5s --interval=1m --timeout=1s CMD wget -O - http://localhost/healthcheck.json || exit 1

ENTRYPOINT /start.sh
