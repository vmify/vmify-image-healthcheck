#!/usr/bin/env sh

eth0_ip=$(ifconfig eth0 | grep 'inet ' | cut -d ':' -f 2 | cut -d ' ' -f 1)
eth0_hostname=$(hostname)

cat > /home/static/healthcheck.json<< EOF
{
  "healthcheck":true,
  "ip":"$eth0_ip",
  "hostname":"$eth0_hostname"
}
EOF

log_file=/home/static/thttpd.log
pid_file=/home/static/thttpd.pid

# Ensure log file gets created first, so there is no race between thttpd and grep
touch $log_file
thttpd -D -h 0.0.0.0 -p 80 -d /home/static -u static -l $log_file -i $pid_file -M 60 &

while [ "$(grep 'GET /healthcheck.json HTTP/1.1' $log_file)" = "" ]
do
  sleep 1
done

kill "$(cat $pid_file)"
