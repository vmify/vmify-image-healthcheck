#!/bin/sh

echo "vmify-image-healthcheck collecting info ..."

echo "-> kernel"
if [ -f /proc/modules ]; then readonly modules="true"; else readonly modules="false"; fi
readonly sysctls=$(sysctl -a | sed 's/ = /":"/' | awk '{print "\""$1"\""}' | tr '\n' ',' | sed 's/.$//')
readonly binfmt_misc=$(cat /proc/sys/fs/binfmt_misc/status || echo "unsupported")
caps=$(setpriv -d | grep "Ambient capabilities:" | cut -d':' -f2 | xargs | tr a-z A-Z | tr ',' '\n' | sort | awk '{print "\""$1"\""}' | tr '\n' ',' | sed 's/.$//')
if [ "$caps" = '"[NONE]"' ]; then
  readonly caps=''
fi
readonly no_new_privs=$(if [ "$(setpriv -d | grep "no_new_privs:" | cut -d': ' -f2)" = " 0" ]; then echo "false"; else echo "true"; fi)
readonly elf32=$(if [ "$(/elf32)" = "Hello world" ]; then echo "true"; else echo "false"; fi)

touch test-xattr
setfattr -n user.testattr -v "success" test-xattr
readonly xattr_user=$( (getfattr -n user.testattr test-xattr | grep "success" > /dev/null) && echo "true" || echo "false")
setfattr -n security.smack -v 0 test-xattr
readonly xattr_security=$( (getfattr -n security.smack test-xattr > /dev/null) && echo "true" || echo "false")

readonly fd=$( (echo "true"> >(tee test-tee.log)) || echo "false")

readonly dev_mqueue=$(ls -ld /dev/mqueue | awk '{$2=$5=$6=$7=$8=""; print $1, $3, $4, $9}')
readonly dev_shm=$(ls -ld /dev/shm | awk '{$2=$5=$6=$7=$8=""; print $1, $3, $4, $9}')

dd if=/dev/zero of=test-loop.img bs=1M count=10
readonly loop_device=$(losetup -f)
readonly loop=$( (losetup "$loop_device" test-loop.img) && echo "true" || echo "false")
losetup -d "$loop_device"

echo "-> hardware"
readonly bios_version=$(cat /sys/devices/virtual/dmi/id/bios_version)
readonly chassis_asset_tag=$(cat /sys/devices/virtual/dmi/id/chassis_asset_tag)

echo "-> network"
readonly eth0_ip=$(ifconfig eth0 | grep 'inet ' | cut -d ':' -f 2 | cut -d ' ' -f 1)
readonly eth0_hostname=$(hostname)
readonly eth0_ntp_servers=$(cat /proc/net/ipconfig/ntp_servers)
readonly etc_hosts=$(awk '{ printf "\"" $1 "\":\"";for (i=2; i<NF; i++) printf $i " "; printf $NF "\"," }' /etc/hosts | sed 's/.$//')

echo "-> disks"
readonly disks=$(tail +3 /proc/partitions | awk '{ print "\"" $4 "\":" $3*1024 }' | sort | tr '\n' ',' | sed 's/.$//')
readonly mounts=$(awk '{ print "\"" $2 "\":\"" $1 " " $3 " " $4 " " $5 " " $6 "\"" }' /proc/mounts | sort | tr '\n' ',' | sed 's/.$//')

echo "-> swap"
get_swap_total() {
  free | tail -1 | tr -s ' ' | cut -d ' ' -f 2
}

# Wait for swap to come online
swap_kib=$(get_swap_total)
if [ "$SWAP" != "0" ]; then
  while [ "$swap_kib" = "0" ] ; do
    sleep 1
    swap_kib=$(get_swap_total)
  done
fi

echo "-> tmp"
if [ -d "/tmp" ]; then
  readonly temp_kib=$(df /tmp | tail -1 | awk '{print $2}')
else
  readonly temp_kib=0
fi

echo "-> environment"
readonly user=$(whoami)
readonly envs=$(env | sort | sed 's/=/":"/' | awk '{print "\""$1"\""}' | tr '\n' ',' | sed 's/.$//')
readonly psax=$(ps ax)
readonly pss=$(echo "$psax" | tail +2 | head -n -1 | awk '{$2=$3=""; print $0}' | tr -s " " | sed 's/ /":"/' | awk '{print "\"" $0 "\""}' | tr '\n' ',' | sed 's/.$//')
readonly boot_timestamp=$(uptime -s)

echo "vmify-image-healthcheck writing json ..."

cat > healthcheck.json<< EOF
{
  "healthcheck":true,
  "boot_timestamp":"$boot_timestamp",
  "modules":$modules,
  "binfmt_misc":"$binfmt_misc",
  "elf32":$elf32,
  "xattr_user":$xattr_user,
  "xattr_security":$xattr_security,
  "fd":$fd,
  "dev_mqueue":"$dev_mqueue",
  "dev_shm":"$dev_shm",
  "loop":$loop,
  "bios_version":"$bios_version",
  "chassis_asset_tag":"$chassis_asset_tag",
  "network":{
    "ip":"$eth0_ip",
    "hostname":"$eth0_hostname",
    "ntp_servers":"$eth0_ntp_servers",
    "hosts":{$etc_hosts}
  },
  "disks":{$disks},
  "mounts":{$mounts},
  "swap_kib":$swap_kib,
  "temp_kib":$temp_kib,
  "sysctl":{$sysctls},
  "env":{$envs},
  "user":"$user",
  "caps":[$caps],
  "no_new_privs":$no_new_privs,
  "ps":{$pss}
}
EOF
cat healthcheck.json

readonly kill_timeout=300
echo "vmify-image-healthcheck starting httpd (auto-terminates after ${kill_timeout}s) ..."
nohup sh -c "sleep $kill_timeout ; /http/cgi-bin/kill.sh" &
httpd -f -vv -p "$PORT"

echo "vmify-image-healthcheck terminating ..."
