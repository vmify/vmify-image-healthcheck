#!/usr/bin/env sh

eth0_ip=$(ifconfig eth0 | grep 'inet ' | cut -d ':' -f 2 | cut -d ' ' -f 1)
eth0_hostname=$(hostname)
if [ -f /proc/modules ]; then
  modules="true"
else
  modules="false"
fi
swap_total=$(free | tail -1 | tr -s ' ' | cut -d ' ' -f 2)

cat > /home/static/healthcheck.json<< EOF
{
  "healthcheck":true,
  "ip":"$eth0_ip",
  "hostname":"$eth0_hostname",
  "modules":$modules,
  "swap_total":$swap_total
}
EOF

echo "vmify-image-healthcheck starting ..."
thttpd -D -h 0.0.0.0 -p 80 -d /home/static -u static -l - -M 60
