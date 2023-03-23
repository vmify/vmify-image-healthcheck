docker build -t healthcheck-test-image .
docker image inspect healthcheck-test-image
docker run -d -p 80:80 --name healthcheck-test-container healthcheck-test-image
curl localhost/healthcheck.json
curl localhost/cgi-bin/kill.sh
docker container rm healthcheck-test-container
docker image rm healthcheck-test-image
