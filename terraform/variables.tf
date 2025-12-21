variable "libvirt_uri" {
  description = "URI для подключения к libvirt хосту"
  type        = string
  default     = "qemu:///system"
}

variable "dc_vm_config" {
  description = "Конфигурация виртуальных машин контроллеров домена"
  type = map(object({
    vcpus            = optional(number, 3)                 # default vcpus   = 3
    memory           = optional(number, 5120)              # default memoryu = 5120
    ip               = string
    prefix           = optional(number, 24 )               # default prefix  = 24
    gateway          = string
    mac              = string
    adminlogin       = optional(string, "sa")              # default adminlogin    = "sa"
    adminpassword    = string                              # default adminpassword = "password"
    network_name     = string
    disk_size        = optional(number, 10737418240 )      # default disk_size     = 10GB
    vncport          = number
    image_url        = optional(string, "https://registry.astralinux.ru/artifactory/mg-generic/alse/cloudinit/alse-1.7.8-max-cloudinit-mg15.8.2-amd64.qcow2")  # default is ALSE 1.7.8
    }))
  default = {
    "dc.ald.test" = {
      vcpus            = 3
      memory           = 5120
      ip               = "192.168.101.202"
      prefix           = 24
      gateway          = "192.168.101.1"
      mac              = "52:54:C0:A8:65:C9"
      adminlogin       = "sa"
      adminpassword    = "password"
      network_name     = "headoffice"
      disk_size        = 10737418240 # 10GB
      vncport          = 5952
      image_url        = "https://registry.astralinux.ru/artifactory/mg-generic/alse/cloudinit/alse-1.7.8-max-cloudinit-mg15.8.2-amd64.qcow2"
    }
  }
}

variable "role_vm_config" {
  description = "Конфигурация виртуальных машин role_vm"
  type = map(object({
    vcpus            = optional(number, 1)
    memory           = optional(number, 2048)
    ip               = string
    prefix           = optional(number, 24 ) 
    gateway          = string
    mac              = string
    adminlogin       = optional(string, "sa")
    adminpassword    = optional(string, "password")
    network_name     = string
    disk_size        = optional(number, 10737418240 )  # default disk_size = 10GB
    vncport          = number
    image_url        = optional(string, "https://registry.astralinux.ru/artifactory/mg-generic/alse/cloudinit/alse-1.7.8-max-cloudinit-mg15.8.2-amd64.qcow2" )  # default is ALSE 1.7.8
  }))
}

variable "client_vm_config" {
  description = "Конфигурация клиентских виртуальных машин"
  type = map(object({
    vcpus            = optional(number, 1)
    memory           = optional(number, 2048)
    ip               = string
    prefix           = optional(number, 24 ) 
    gateway          = string
    mac              = string
    adminlogin       = optional(string, "sa")
    adminpassword    = optional(string, "password")
    network_name     = string
    disk_size        = optional(number, 10737418240 )  # default disk_size = 10GB
    vncport          = number
    image_url        = optional(string, "https://registry.astralinux.ru/artifactory/mg-generic/alse/cloudinit/alse-gui-1.7.8-max-cloudinit-mg15.8.2-amd64.qcow2" )  # default is ALSE 1.7.8 with Fly DE
    }))
}


variable "pool_name" {
  description = "vm pool name"
  type        = string
  default     = "vms-pool"
}

variable "pool_path" {
  description = "vm disk pool path"
  type        = string
  default     = "/var/lib/libvirt/images/vms/"
}

variable "net_config" {
  description = "net_config"
  type = map(object({
    address         = string
    prefix          = number
    dhcprange_start = string
    dhcprange_end   = string
   }))
}

variable "ssh_public_key" {
  description = "Публичный SSH ключ"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "default"
}

variable "dcimage_url" {
  description = ""
  type        = string
}

variable "roleimage_url" {
  description = ""
  type        = string
}
variable "clientimage_url" {
  description = ""
  type        = string
}
