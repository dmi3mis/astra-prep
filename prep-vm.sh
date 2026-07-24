#!/bin/bash
set -euo pipefail

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -q aldpro-client

ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

sudo sed -i "s/127.0.1.1/${ip4}/g" /etc/hosts
sudo rm /etc/resolv.conf

sudo bash -c 'cat << EOF > /etc/resolv.conf 2>/dev/null
nameserver 10.0.1.11
nameserver 10.0.1.12
search ald.company.lan
EOF'

set +o history
sudo /opt/rbta/aldpro/client/bin/aldpro-client-installer --domain ald.company.lan \
                                                         --account admin \
                                                         --password 'P@ssw0rd' \
                                                         --host $(hostname --short)  \
                                                         --gui --force
set -o history


# small fix for aldpro-client 3.2.1
sudo rm /etc/domains.list.d/astra-freeipa-domains

sudo reboot
