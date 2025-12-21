# Конфигурация для стендов курсов Astra
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../terraform"
  # source = "git://git@github.com/dmi3mis/astra-prep.git/terraform"

}

locals {
  # Enviroment name
  environment         = "local"
  libvirt_uri         = "qemu:///system"

  # uncomment this block when computer not local
  # nessesary preparations
  #  1. ssh-keygen -t ecdsa -f ~/.ssh/id_ecdsa -N ""
  #  2. ssh-copy-id -i ~/.ssh/id_ecdsa.pub
  # environment        = "remote"
  # libvirt_uri = "qemu+ssh://<remote-user-here>@remote-host-here:<ssh-port>/system?known_hosts=~/.ssh/known_hosts&sshauth=privkey&keyfile=~/.ssh/id_ecdsa&no_verify=1"

  
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
    }
  

}

# Параметры для local
inputs = {

  # Название для создаваемого пула виртуальных машин.
  pool_name           = "pool"
  
  # Каталог пула виртуальных машин
  pool_path           = "/var/lib/libvirt/images/pool"
  

  # Образ ОС DC замените на путь к вашему образу, список приведён выше
  # образ должен быть в формате qcow2 и включать поддержку cloud-init

  dcimage_url        = "${local.image_urls["alse178_gui_local"]}"
  roleimage_url      = "${local.image_urls["alse178_gui_local"]}"
  clientimage_url    = "${local.image_urls["alse178_gui_local"]}"

  # Список имен и конфигураций контрорллеров домена
  dc_vm_config = {
    "dc01.ald.test"  = { 
       vcpus            = 3          # 1 is default value
       memory           = 5120       # 2048 is default value
       ip               = "192.168.101.201"
       gateway          = "192.168.101.1"
       mac              = "52:54:00:a8:65:c9"
       network_name     = "headoffice"
       disk_size        = 50 * pow(2, 30)
       adminlogin       = "sa"
       adminpassword    = "password"
       vncport          = 5921
       }
    "dc02.ald.test"  = { 
       vcpus            = 3
       memory           = 5120
       ip               = "192.168.101.202"
       gateway          = "192.168.101.1"
       mac              = "52:54:00:a8:65:ca"
       network_name     = "headoffice"
       adminpassword    = "password"
       disk_size        = 50 * pow(2, 30)
       adminlogin       = "sa"
       adminpassword    = "password"
       vncport          = 5922
       }
    "dc03.ald.test"  = { 
       vcpus            = 3
       memory           = 5120
       ip               = "10.11.0.201"
       gateway          = "10.11.0.1"
       mac              = "52:54:00:0b:00:c9"
       network_name     = "branch"
       adminpassword    = "password"
       disk_size        = 50 * pow(2, 30)
       adminlogin       = "sa"
       adminpassword    = "password"
       vncport          = 5923
       }
  }

  # Список имен и конфигураций подсистем домена
  role_vm_config = {
    "dhcp.ald.test"     = { 
       vcpus            = 1
       memory           = 2048  
       ip               = "10.11.0.202"
       gateway          = "10.11.0.1"
       mac              = "52:54:00:0b:00:ca"
       disk_size        = 50 * pow(2, 30)
       network_name     = "branch"
       adminpassword    = "password"
       vncport          = 5931
       }
    "ps.ald.test"       = { 
       ip               = "192.168.101.205"
       gateway          = "192.168.101.1"
       mac              = "52:54:00:a8:65:cd"
       disk_size        = 50 * pow(2, 30)
       network_name     = "headoffice"
       vncport          = 5932
       }
    "monitor.ald.test"  = { 
       ip               = "192.168.101.210"
       gateway          = "192.168.101.1"
       mac              = "52:54:00:a8:65:d2"
       disk_size        = 50 * pow(2, 30)
       network_name     = "headoffice"
       adminpassword    = "password"
       vncport          = 5933
       }
    "log.ald.test"      = { 
       ip               = "192.168.101.203"
       gateway          = "192.168.101.1"
       mac              = "52:54:00:a8:65:cb"
       disk_size        = 50 * pow(2, 30)
       network_name     = "headoffice"
       adminpassword    = "password"
       vncport          = 5934
       }
    "fs.ald.test"      = { 
       ip               = "192.168.101.206"
       gateway          = "192.168.101.1"
       mac              = "52:54:00:a8:65:ce"
       disk_size        = 50 * pow(2, 30)
       network_name     = "headoffice"
       adminpassword    = "password"
       vncport          = 5935
       }
    "repo.ald.test"      = { 
       ip               = "192.168.101.207"
       gateway          = "192.168.101.1"
       mac              = "52:54:00:a8:65:cf"
       disk_size        = 50 * pow(2, 30)
       network_name     = "headoffice"
       adminpassword    = "password"
       vncport          = 5936
       }
    "os.ald.test"      = { 
       ip               = "10.11.0.203"
       gateway          = "10.11.0.1"
       mac              = "52:54:00:0b:00:cb"
       disk_size        = 50 * pow(2, 30)
       network_name     = "branch"
       adminpassword    = "password"
       vncport          = 5937
       }
  }

  # Список имен и конфигураций клиентских систем
  client_vm_config = {
    "client1.ald.test"  = { 
       ip               = "192.168.101.202"
       gateway          = "192.168.101.1"
       mac              = "52:54:00:a8:65:cb"
       disk_size        = 50 * pow(2, 30)
       network_name     = "headoffice"
       adminpassword    = "password"
       vncport          = 5941

       }
    "client2.ald.test"  = { 
       ip               = "10.11.0.123"
       gateway          = "10.11.0.1"
       mac              = "52:54:00:a8:65:ca"
       disk_size        = 50 * pow(2, 30)
       network_name     = "branch"
       adminpassword    = "password"
       vncport          = 5942
       }
  }
  
  # Список имен и конфигураций виртуальных сетей
  net_config = {
    "headoffice" = {
      address         = "192.168.101.1"
      prefix          = 24
      dhcprange_start = "192.168.101.128"
      dhcprange_end   = "192.168.101.198"
    }
    "branch" = {
      address         = "10.11.0.1"
      prefix          = 24
      dhcprange_start = "10.11.0.128"
      dhcprange_end   = "10.11.0.198"
    }
  }

}
