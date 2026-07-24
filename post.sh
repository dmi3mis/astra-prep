#!/bin/bash

# Download and create qcow2 images of Windows 2019eval and Windows 10eval
# https://github.com/dockur/windows/tree/master
mkdir -p ~/win2019-win10
cd ~/win2019-win10

cat <<EOF > compose.yml
name: win2019-win10
services:
  ws1:
    image: dockurr/windows
    container_name: windc-1.win.company.lan
    environment:
      VERSION: "windows2019"
      CPU_CORES: "2"
      RAM_SIZE: "4G"
      USERNAME: "localadmin"
      PASSWORD: "P@ssw0rd"
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
      - ${HOME}/storage-windc-1:/storage
    restart: always
    stop_grace_period: 2m
  w10:
    image: dockurr/windows
    container_name: winpc-1.win.company.lan
    environment:
      VERSION: "windows10e"
      CPU_CORES: "2"
      RAM_SIZE: "4G"
      USERNAME: "localadmin"
      PASSWORD: "P@ssw0rd"
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
      - ${HOME}/storage-winpc-1:/storage
    restart: always
    stop_grace_period: 2m
EOF

docker compose up -d

echo "ws1.msad.test on Windows Server 2019 is deploying. you can watch this process on "http://0.0.0.0:8006"
echo "w10.msad.test on Windows 10 is deploying. you can watch this process on "http://0.0.0.0:8007"
echo "you can watch container logs with docker compose logs -f"

sleep 30m

docker compose stop


cp ${HOME}/storage-windc-1/data.qcow2 /var/lib/libvirt/images/windc-1-data.qcow2
cp ${HOME}/storage-winpc-1/data.qcow2 /var/lib/libvirt/images/winpc-1-data.qcow2

sudo chgrp libvirt-qemu /var/lib/libvirt/images/win*.qcow2 
sudo chmod g+rwx /var/lib/libvirt/images/win*.qcow2 


virt-install \
 --name windc-1.win.company.lan \
 --ram 4096 \
 --vcpus 2 --cpu host-passthrough \
 --os-variant win2k19 \
 --install bootdev=hd,no_install=yes \
 --boot uefi \
 --disk path=/var/lib/libvirt/images/windc-1-data.qcow2,bus=virtio,format=qcow2 \
 --network network=ap301-net,model=virtio,mac="52:54:00:a8:65:d7" \
 --video virtio \
 --console pty,target.type=virtio \
 --graphics spice
 --noautoconsole

virt-install \
 --name winpc-1.win.company.lan \
 --ram 4096 \
 --vcpus 2 --cpu host-passthrough \
 --os-variant win10 \
 --install bootdev=hd,no_install=yes \
 --boot uefi \
 --disk path=/var/lib/libvirt/images/winpc-1-data.qcow2,bus=virtio,format=qcow2 \
 --network network=ap301-net,model=virtio,mac="52:54:00:a8:65:d8" \
 --video virtio \
 --console pty,target.type=virtio \
 --graphics spice
 --noautoconsole

# Create 2 new and empty vms for tests with pxe

virt-install \
 --name pxeboot-bios.ald.company.lan \
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
 --graphics spice
 --noautoconsole


# create UEFI PXE boot VM with secureboot bisabled
virt-install \
 --name pxeboot-uefi.ald.company.lan \
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




virsh shutdown windc-1.win.company.lan
virsh shutdown winpc-1.win.company.lan
virsh destroy pxeboot-bios.ald.company.lan
virsh destroy pxeboot-uefi.ald.company.lan



