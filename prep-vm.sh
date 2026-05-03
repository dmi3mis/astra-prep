#!/bin/bash
set -euo pipefail

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -q aldpro-client

ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

sudo sed -i "s/127.0.1.1/${ip4}/g" /etc/hosts
sudo rm /etc/resolv.conf

sudo bash -c 'cat << EOF > /etc/resolv.conf 2>/dev/null
nameserver 192.168.101.201
nameserver 192.168.101.202
nameserver 10.11.0.201
search ald.test
EOF'

set +o history
sudo /opt/rbta/aldpro/client/bin/aldpro-client-installer --domain ald.test --account admin --password password --host $(hostname)  --gui --force
set -o history

sudo reboot

