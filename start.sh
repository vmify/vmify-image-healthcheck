#!/bin/sh

eth0_ip=$(ifconfig eth0 | grep 'inet ' | cut -d ':' -f 2 | cut -d ' ' -f 1)
eth0_hostname=$(hostname)
if [ -f /proc/modules ]; then modules="true"; else modules="false"; fi
swap_total=$(free | tail -1 | tr -s ' ' | cut -d ' ' -f 2)
disks=$(tail +3 /proc/partitions | awk '{ print "\"" $4 "\":" $3*1024 }' | tr '\n' ',' | sed 's/.$//')
envs=$(env | sort | sed 's/=/":"/' | awk '{print "\""$1"\""}'  | tr '\n' ',' | sed 's/.$//')

mkdir http
cd http
cat > healthcheck.json<< EOF
{
  "healthcheck":true,
  "modules":$modules,
  "ip":"$eth0_ip",
  "hostname":"$eth0_hostname",
  "disks": { $disks },
  "swap_total":$swap_total,
  "env": { $envs }
}
EOF

echo "vmify-image-healthcheck starting ..."
cat healthcheck.json
httpd -f -vv
