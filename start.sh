#!/bin/sh

if [ -f /proc/modules ]; then modules="true"; else modules="false"; fi

bios_version=$(cat /sys/devices/virtual/dmi/id/bios_version)
chassis_asset_tag=$(cat /sys/devices/virtual/dmi/id/chassis_asset_tag)
eth0_ip=$(ifconfig eth0 | grep 'inet ' | cut -d ':' -f 2 | cut -d ' ' -f 1)
eth0_hostname=$(hostname)
eth0_ntp_servers=$(cat /proc/net/ipconfig/ntp_servers)

disks=$(tail +3 /proc/partitions | awk '{ print "\"" $4 "\":" $3*1024 }' | sort | tr '\n' ',' | sed 's/.$//')
mounts=$(awk '{ print "\"" $2 "\":\"" $1 " " $3 " " $4 " " $5 " " $6 "\"" }' /proc/mounts | sort | tr '\n' ',' | sed 's/.$//')
swap_total=$(free | tail -1 | tr -s ' ' | cut -d ' ' -f 2)
envs=$(env | sort | sed 's/=/":"/' | awk '{print "\""$1"\""}' | tr '\n' ',' | sed 's/.$//')
psax=$(ps ax)
pss=$(echo "$psax" | tail +2 | head -n -1 | awk '{$2=$3=""; print $0}' | tr -s " " | sed 's/ /":"/' | awk '{print "\"" $0 "\""}' | tr '\n' ',' | sed 's/.$//')

mkdir http
cd http
cat > healthcheck.json<< EOF
{
  "healthcheck":true,
  "modules":$modules,
  "bios_version":"$bios_version",
  "chassis_asset_tag":"$chassis_asset_tag",
  "network":{
    "ip":"$eth0_ip",
    "hostname":"$eth0_hostname",
    "ntp_servers":"$eth0_ntp_servers"
  },
  "disks":{$disks},
  "mounts":{$mounts},
  "swap_total":$swap_total,
  "env":{$envs},
  "ps":{$pss}
}
EOF

echo "vmify-image-healthcheck starting ..."
cat healthcheck.json
httpd -f -vv
