docker build -t healthcheck-test-image .
docker image inspect healthcheck-test-image
docker run -d -p 80:80 --name healthcheck-test-container healthcheck-test-image
curl localhost/healthcheck.json
rem docker kill healthcheck-test-container
rem docker container rm healthcheck-test-container
rem docker image rm healthcheck-test-image
