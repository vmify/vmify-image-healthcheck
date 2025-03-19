docker build -t healthcheck-test-image .
docker image inspect healthcheck-test-image
docker run -d -p 80:8000 --privileged --name healthcheck-test-container healthcheck-test-image
start /b docker container logs -f healthcheck-test-container
docker stop healthcheck-test-container
docker container rm -f -v healthcheck-test-container
docker image rm healthcheck-test-image
