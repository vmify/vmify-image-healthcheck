FROM busybox:1.36.0-uclibc

ENV TEST_VAR_IMAGE_IMAGE=image
ENV TEST_VAR_IMAGE_INSTANCE=image
ENV TEST_VAR_IMAGE_ARGUMENT=image
ADD start.sh /start.sh
ADD kill.sh /http/cgi-bin/kill.sh

EXPOSE 80
HEALTHCHECK --start-period=5s --interval=1m --timeout=1s CMD wget -O - http://localhost/healthcheck.json || exit 1

ENTRYPOINT /start.sh
