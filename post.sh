#!/bin/bash

# allow routing between two NAT virtual networks
# https://serverfault.com/questions/1109903/libvirt-routing-between-two-nat-networks
sudo mkdir -p /etc/libvirt/hooks
sudo bash -c 'cat << EOF > /etc/libvirt/hooks/qemu
#!/bin/bash
/usr/sbin/iptables -F LIBVIRT_FWI
/usr/sbin/iptables -F LIBVIRT_FWO
/usr/sbin/iptables -A LIBVIRT_FWO -j ACCEPT
/usr/sbin/iptables -A LIBVIRT_FWI -j ACCEPT
EOF'

sudo chmod a+rx /etc/libvirt/hooks/qemu
sudo bash -c /etc/libvirt/hooks/qemu


# Download and create qcow2 images of Windows 2019eval and Windows 10eval
# https://github.com/dockur/windows/tree/master

cat <<EOF > compose.yml
name: win2019-win10
services:
  ws1:
    image: dockurr/windows
    container_name: ws1.msad.test
    environment:
      VERSION: "windows2019"
      CPU_CORES: "2"
      RAM_SIZE: "4G"
      USERNAME: "sa"
      PASSWORD: "password"
      REMOVE: "N"
      DISK_FMT: "qcow2"
      DISK_SIZE: "128G"
    devices:
      - /dev/kvm
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    ports:
      - 8006:8006
      - 3390:3389/tcp
      - 3390:3389/udp
    volumes:
      - ${HOME}/storage-ws1:/storage
    restart: always
    stop_grace_period: 2m
  w10:
    image: dockurr/windows
    container_name: w10.msad.test
    environment:
      VERSION: "windows10e"
      CPU_CORES: "2"
      RAM_SIZE: "4G"
      USERNAME: "sa"
      PASSWORD: "password"
      REMOVE: "N"
      DISK_FMT: "qcow2"
      DISK_SIZE: "128G"
    devices:
      - /dev/kvm
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    ports:
      - 8007:8006
      - 3391:3389/tcp
      - 3391:3389/udp
    volumes:
      - ${HOME}/storage-w10:/storage
    restart: always
    stop_grace_period: 2m
EOF

docker compose up -d

echo "ws1.msad.test on Windows Server 2019 is deploying. you can watch this process on "http://0.0.0.0:8006"
echo "w10.msad.test on Windows 10 is deploying. you can watch this process on "http://0.0.0.0:8007"
echo "you can watch container logs with docker compose logs -f"

sleep 30m

docker compose stop

sudo chgrp libvirt-qemu -R /var/lib/libvirt/images/
sudo chmod g+rwx -R /var/lib/libvirt/images

virt-install \
 --name ws1.msad.test \
 --ram 4096 \
 --vcpus 2 --cpu host-passthrough \
 --os-variant win2k22 \
 --install bootdev=hd,no_install=yes \
 --boot uefi \
 --disk path=${HOME}/storage-ws1/win2019-data.qcow2,bus=virtio,format=qcow2 \
 --network network=headoffice,model=virtio,mac="52:54:00:a8:65:d7" \
 --video virtio \
 --console pty,target.type=virtio \
 --graphics spice,port=5961,listen="0.0.0.0" \
 --noautoconsole

virt-install \
 --name w10.msad.test \
 --ram 4096 \
 --vcpus 2 --cpu host-passthrough \
 --os-variant win10 \
 --install bootdev=hd,no_install=yes \
 --boot uefi \
 --disk path=${HOME}/storage-w10/win10-data.qcow2,bus=virtio,format=qcow2 \
 --network network=headoffice,model=virtio,mac="52:54:00:a8:65:d8" \
 --video virtio \
 --console pty,target.type=virtio \
 --graphics spice,port=5962,listen="0.0.0.0" \
 --noautoconsole

# Create 2 new and empty vms for tests with pxe

virt-install \
 --name pxeboot-bios.ald.test \
 --ram 2046 \
 --vcpus 2 --cpu host-passthrough \
 --os-variant debian12 \
 --install bootdev=net,no_install=yes \
 --pxe \
 --boot bootmenu.enable=on,hd,network \
 --disk path=/var/lib/libvirt/images/pxeboot-bios.qcow2,size=50,bus=virtio,format=qcow2 \
 --network network=branch,model=virtio,mac="52:54:00:a8:65:01" \
 --video virtio \
 --console pty,target.type=virtio \
 --graphics spice,port=5971,listen="0.0.0.0" \
 --noautoconsole


# create UEFI PXE boot VM with secureboot bisabled
virt-install \
 --name pxeboot-uefi.ald.test \
 --ram 2046 \
 --vcpus 2 --cpu host-passthrough \
 --os-variant debian12 \
 --boot bootmenu.enable=on,uefi,hd,network  \
 --pxe \
 --install bootdev=net,no_install=yes \
 --disk path=/var/lib/libvirt/images/pxeboot-uefi.qcow2,size=50,bus=virtio,format=qcow2 \
 --network network=branch,model=virtio,mac="52:54:00:a8:65:02" \
 --video virtio \
 --console pty,target.type=virtio \
 --noautoconsole --print-xml > /tmp/pxeboot-uefi.xml

sed -i 's/secure=yes/secure=no/g' /tmp/pxeboot-uefi.xml
virsh define /tmp/pxeboot-uefi.xml
rm /tmp/pxeboot-uefi.xml




virsh shutdown ws1.msad.test
virsh shutdown w10.msad.test
virsh destroy pxeboot-bios.ald.test
virsh destroy pxeboot-uefi.ald.test



