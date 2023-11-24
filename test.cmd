docker build -t healthcheck-test-image .
docker image inspect healthcheck-test-image
docker run -d -p 80:8000 --name healthcheck-test-container healthcheck-test-image
curl localhost/healthcheck.json
REM curl localhost/cgi-bin/kill.sh
REM docker container logs healthcheck-test-container
REM docker container rm -f -v healthcheck-test-container
REM docker image rm healthcheck-test-image
