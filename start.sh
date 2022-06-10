#!/usr/bin/env sh

eth0_ip=$(ifconfig eth0 | grep 'inet ' | cut -d ':' -f 2 | cut -d ' ' -f 1)
eth0_hostname=$(hostname)

cat > /home/static/healthcheck.json<< EOF
{
  "ip":"$eth0_ip",
  "hostname":"$eth0_hostname"
}
EOF

thttpd -D -h 0.0.0.0 -p 80 -d /home/static -u static -l - -M 60
