FROM busybox:1.36.1-uclibc

ENV TEST_VAR_IMAGE_IMAGE=image
ENV TEST_VAR_IMAGE_INSTANCE=image
ENV TEST_VAR_IMAGE_ARGUMENT=image
ADD start.sh /start.sh
ADD kill.sh /http/cgi-bin/kill.sh
RUN addgroup -S testgroup && adduser -S -H -G testgroup testuser && chmod 777 /http
USER testuser
WORKDIR /http

EXPOSE 8000
HEALTHCHECK --start-period=5s --interval=1m --timeout=1s CMD wget -O - http://localhost:8000/healthcheck.json || exit 1

ENTRYPOINT /start.sh
