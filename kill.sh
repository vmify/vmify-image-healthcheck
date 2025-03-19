#!/bin/sh

echo "Content-type: text/plain"
echo ""
echo "Server Shutdown Initiated"

(
  sleep 1
  kill "$(pidof httpd)"
) &
