# Конфигурация для стендов курсов Astra
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../terraform"
  # https://notes.kodekloud.com/docs/Terragrunt-for-Beginners/Terragrunt-Modules/Sourcing-a-Module-From-a-Git-Repository
  # Prerequisites
  #   - A Terraform module stored in a private Git repository
  #   - Credentials configured in your local environment (HTTPS token or SSH key)
  #   - Terraform CLI installed on your workstation
  #
  #  source = "https://github.com/dmi3mis/astra-prep.git//terraform"
}

locals {

  
  # terraform будет загружать образы ALSE отсюда https://registry.astralinux.ru/ui/native/mg-generic/alse/
  
  # Выбирайте образы, совместимые с версиями ALD Pro согласно таблице по ссылке: 
  # https://www.aldpro.ru/professional/ALD_Pro_Module_02/ALD_Pro_deployment.html#aldpro-compatibility

  image_urls = {
    debian12_local         = "/var/lib/libvirt/images/debian-12-genericcloud-amd64.qcow2"
    debian12_link          = "https://cdimage.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
     
    alse178_local          = "/var/lib/libvirt/images/alse-1.7.8-max-cloudinit-mg15.8.2-amd64.qcow2"
    alse178_link           = "https://registry.astralinux.ru/artifactory/mg-generic/alse/cloudinit/alse-1.7.8-max-cloudinit-mg15.8.2-amd64.qcow2"
    alse178_gui_local      = "/var/lib/libvirt/images/alse-gui-1.7.8-max-cloudinit-mg15.8.2-amd64.qcow2"
    alse178_gui_link       = "https://registry.astralinux.ru/artifactory/mg-generic/alse/cloudinit/alse-gui-1.7.8-max-cloudinit-mg15.8.2-amd64.qcow2"
    alse1710_gui_local      = "/var/lib/libvirt/images/alse-gui-1.7.10-max-cloudinit-mg16.2.0-amd64.qcow2"
    alse1710_gui_link      = "https://registry.astralinux.ru/artifactory/mg-generic/alse/cloudinit/alse-gui-1.7.10-max-cloudinit-mg16.2.0-amd64.qcow2"
    }
  

}

# Параметры для local
inputs = {

  # Название для создаваемого пула виртуальных машин.
  pool_name           = "pool"
  
  # Каталог пула виртуальных машин
  pool_path           = "/var/lib/libvirt/images/pool"
  
  ssh_public_key      = "~/.ssh/id_ecdsa.pub"


  # Образ ОС DC замените на путь к вашему образу, список приведён выше
  # образ должен быть в формате qcow2 и включать поддержку cloud-init
  dcimage_url        = "${local.image_urls["alse1710_gui_local"]}"
  roleimage_url      = "${local.image_urls["alse1710_gui_local"]}"
  clientimage_url    = "${local.image_urls["alse1710_gui_local"]}"

  # Enviroment name
  environment         = "local"
  libvirt_uri         = "qemu:///system"
  
  # uncomment this block when computer not local
  # nessesary preparations
  #  1. ssh-keygen -t ecdsa -f ~/.ssh/id_ecdsa -N ""
  #  2. ssh-copy-id -i ~/.ssh/id_ecdsa.pub
  # environment        = "remote"
  # libvirt_uri = "qemu+ssh://<remote-user-here>@remote-host-here:<ssh-port>/system?known_hosts=~/.ssh/known_hosts&sshauth=privkey&keyfile=~/.ssh/id_ecdsa&no_verify=1"
  
  # environment = "remote"
  # libvirt_uri = "qemu+ssh://user@192.168.50.211:22/system?known_hosts=~/.ssh/known_hosts&sshauth=privkey&keyfile=~/.ssh/id_ecdsa&no_verify=1"





  # Список имен и конфигураций контрорллеров домена
  dc_vm_config = {
    "dc-1.ald.company.com"  = { 
       vcpus            = 4          # 1 is default value
       memory           = 8192       # 2048 is default value
       ip               = "10.0.1.11"
       gateway          = "10.0.1.1"
       mac              = "52:54:00:00:01:0b"
       network_name     = "exam-net"
       disk_size        = 50 * pow(2, 30)
       adminlogin       = "localadmin"
       adminpassword    = "P@ssw0rd"
       vncport          = 5921
       }
  }

  # Список имен и конфигураций подсистем домена
  role_vm_config = {
    "dhcp-1.ald.company.com"  = { 
       vcpus            = 4          # 1 is default value
       memory           = 4092       # 2048 is default value
       ip               = "10.0.1.30"
       gateway          = "10.0.1.1"
       mac              = "52:54:00:00:01:1e"
       network_name     = "exam-net"
       disk_size        = 50 * pow(2, 30)
       adminlogin       = "localadmin"
       adminpassword    = "P@ssw0rd"
       vncport          = 5930
       }
    "file-1.ald.company.com"  = { 
       vcpus            = 4          # 1 is default value
       memory           = 4092       # 2048 is default value
       ip               = "10.0.1.24"
       gateway          = "10.0.1.1"
       mac              = "52:54:00:00:01:18"
       network_name     = "exam-net"
       disk_size        = 50 * pow(2, 30)
       adminlogin       = "localadmin"
       adminpassword    = "P@ssw0rd"
       vncport          = 5931
       }
    "audit-1.ald.company.com"  = { 
       vcpus            = 4          # 1 is default value
       memory           = 4092       # 2048 is default value
       ip               = "10.0.1.22"
       gateway          = "10.0.1.1"
       mac              = "52:54:00:00:01:16"
       network_name     = "exam-net"
       disk_size        = 50 * pow(2, 30)
       adminlogin       = "localadmin"
       adminpassword    = "P@ssw0rd"
       vncport          = 5932
       }
  }

  # Список имен и конфигураций клиентских систем
  client_vm_config = {
    "exam-client.ald.company.lan"  = { 
       ip               = "10.0.1.99"
       gateway          = "10.0.1.1"
       mac              = "08:00:27:47:b9:27"
       disk_size        = 50 * pow(2, 30)
       network_name     = "exam-net"
       adminlogin       = "localadmin"
       adminpassword    = "P@ssw0rd"
       vncport          = 5941
       }
   }
  
  # Список имен и конфигураций виртуальных сетей
  net_config = {
    "exam-net" = {
      address         = "10.0.1.1"
      prefix          = 24
      
      dhcprange_start = "10.0.1.50"
      dhcprange_end   = "10.0.1.198"
    }
  }

}
