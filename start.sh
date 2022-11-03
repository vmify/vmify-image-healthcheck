#!/bin/sh

eth0_ip=$(ifconfig eth0 | grep 'inet ' | cut -d ':' -f 2 | cut -d ' ' -f 1)
eth0_hostname=$(hostname)
if [ -f /proc/modules ]; then
  modules="true"
else
  modules="false"
fi
swap_total=$(free | tail -1 | tr -s ' ' | cut -d ' ' -f 2)

mkdir http
cd http
cat > healthcheck.json<< EOF
{
  "healthcheck":true,
  "ip":"$eth0_ip",
  "hostname":"$eth0_hostname",
  "modules":$modules,
  "swap_total":$swap_total
}
EOF

echo "vmify-image-healthcheck starting ..."
httpd -vv

# Auto-terminate after 60 seconds
sleep 60
