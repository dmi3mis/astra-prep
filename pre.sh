#!/usr/bin/env bash

############################
# intitial install section
# install and configure qemu-kvm xrdp
# install terraform and terragrunt
# install vscode  #
############################

# Switch to non-interactive mode (system will not ask for any confirmations)
export DEBIAN_FRONTEND="noninteractive"


# Мы будем использовать Astra Linux SE Орёл 1.8.4

cat  <<'EOF' |sudo tee /etc/apt/sources.list
deb https://download.astralinux.ru/astra/frozen/1.8_x86-64/1.8.4/repository-extended/ 1.8_x86-64 main contrib non-free non-free-firmware
deb https://download.astralinux.ru/astra/frozen/1.8_x86-64/1.8.4/repository-main/ 1.8_x86-64 main contrib non-free non-free-firmware
EOF

# Включаем режим Орёл. Возможности SE нам не понадобятся.

sudo astra-modeswitch set 0


#sudo systemctl stop ufw
#sudo apt-get purge -y ufw
#sudo systemctl stop ufw

# Виртуализация QEMU/KVM в Astra Linux
# https://wiki.astralinux.ru/pages/viewpage.action?pageId=3277425

sudo apt-get install -y astra-kvm virt-manager

sudo usermod -a -G libvirt-admin,libvirt-qemu,libvirt,disk,kvm,astra-admin,astra-console $USER

# Disable Apparmor security on libvirtd
# not applicable on Astra Linux SE
# sudo sh -c 'echo security_driver = \"none\" >> /etc/libvirt/qemu.conf'
# sudo systemctl restart libvirtd

# Установим xrdp и openssh-server разрешим к нему удалённые подключения
sudo apt-get install -y openssh-server fly-dm-rdp xrdp
sudo systemctl enable --now firewalld.service
sudo firewall-cmd --permanent --add-service=rdp
sudo firewall-cmd --permanent --add-service=ssh


# add this as workaround for older ssh clients and new openssh-server on ALSE 1.8.4
sudo bash -c 'cat << EOF > /etc/ssh/sshd_config.d/custom.conf
HostkeyAlgorithms +ssh-rsa
PubkeyAcceptedKeyTypes +ssh-rsa
EOF'
sudo systemctl restart ssh.service


# SSH ключ нам понадобится при развёртывании виртуальных машин.

ssh-keygen -t ecdsa -f ~/.ssh/id_ecdsa -N ""


# Мы будем использовать диаппазон портов 5900-6000/tcp для vnc подключения к виртуальным машинам.
# разрешим удалённые подключения через них
sudo firewall-cmd --permanent --add-port 5900-9000/tcp
sudo firewall-cmd --reload


# prepare $PATH
echo 'export PATH=${PATH}:${HOME}/.local/bin' >> ~/.bashrc
echo 'export LIBVIRT_DEFAULT_URI="qemu:///system"' >> ~/.bashrc

source ~/.bashrc

# download and install terraform
export TERRAFORM_LATEST="1.13.5"
curl -LO "https://hashicorp-releases.yandexcloud.net/terraform/1.13.5/terraform_${TERRAFORM_LATEST}_linux_amd64.zip"
mkdir -p ~/.local/bin/

unzip -o terraform_${TERRAFORM_LATEST}_linux_amd64.zip -d ~/.local/bin/
chmod +x ~/.local/bin/terraform
rm *.zip

terraform version

cat > ~/.terraformrc <<'EOF'
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
EOF

export TERRAGRUNT_LATEST="v0.93.8"
curl -LO "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_LATEST}/terragrunt_linux_amd64.zip"
unzip -o terragrunt_linux_amd64.zip -d ~/.local/bin/
mkdir -p ~/.local/bin/
mv ~/.local/bin/terragrunt_linux_amd64 ~/.local/bin/terragrunt
chmod +x ~/.local/bin/terragrunt
rm *.zip

terragrunt version

sudo apt-get install -y git mkisofs

# Pre-download qcow2 file.

sudo wget https://registry.astralinux.ru/artifactory/mg-generic/alse/cloudinit/alse-gui-1.7.10-max-cloudinit-mg16.2.0-amd64.qcow2 \
          -O /var/lib/libvirt/images/alse-gui-1.7.10-max-cloudinit-mg16.2.0-amd64.qcow2

sudo chgrp libvirt-qemu -R /var/lib/libvirt/images/


# install docker. we will need it in ./post.sh
sudo apt-get install -y docker.io docker-compose-v2
sudo usermod -a -G docker $USER



sudo bash -c 'cat << EOF >> /etc/hosts
192.168.101.201   dc01.ald.test     dc01
192.168.101.202   dc02.ald.test     dc02
10.11.0.201       dc03.ald.test     dc03
192.168.101.211   client1.ald.test  client1
10.11.0.202       dhcp.ald.test     dhcp
192.168.101.205   ps.ald.test       ps
192.168.101.210   monitor.ald.test  monitor
192.168.101.203   log.ald.test      log
192.168.101.206   fs.ald.test       fs
192.168.101.207   repo.ald.test     repo
10.11.0.203       os.ald.test       os
192.168.101.215   ws1.msad.test     ws1
192.168.101.216   w10.msad.test     w10
EOF'
