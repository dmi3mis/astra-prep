# instance the provider
provider "libvirt" {
  uri = var.libvirt_uri
}

# Чтение публичного SSH ключа
locals {
  ssh_key = file(var.ssh_public_key)
}



# Пул для томов
resource "libvirt_pool" "vmspool" {
  name = var.pool_name
  type = "dir"
  target = {
    path = var.pool_path
  }
}

# Объем для базового образа dc
resource "libvirt_volume" "dc_baseimage" {
  name      = "dc_baseimage.qcow2"
  pool      = libvirt_pool.vmspool.name
  target    = { format = { type = "qcow2" } }
  create    = {
    content = {
      url = var.dcimage_url
    }
  }
}

resource "libvirt_volume" "role_baseimage" {
  name       = "role_baseimage.qcow2"
  pool       = libvirt_pool.vmspool.name
  target     = { format = { type = "qcow2" } }
  depends_on = [libvirt_volume.dc_baseimage]
  create = {
    content = {
      url = var.roleimage_url
    }
  }
}


resource "libvirt_volume" "client_baseimage" {
  name      = "client_baseimage.qcow2"
  pool      = libvirt_pool.vmspool.name
  target    = { format = { type = "qcow2" } }
  create = {
    content = {
      url = var.clientimage_url
    }
  }
  depends_on = [libvirt_volume.role_baseimage]
}

resource "libvirt_network" "networks" {
  for_each    = var.net_config
  name        = each.key
  autostart   = true
  forward     = {
    mode      = "nat"
  }
  ips = [{
    address   = each.value.address
    prefix    = each.value.prefix
    dhcp = {
      ranges  = [{
        start = each.value.dhcprange_start
        end   = each.value.dhcprange_end
      }]
    }
  }]
}

module "dc_vms" {
  for_each        = var.dc_vm_config
  source          = "./modules/libvirt-vm"
  pool_name       = libvirt_pool.vmspool.name
  basevolume_path = libvirt_volume.dc_baseimage.path
  vm_name         = each.key
  vcpus           = each.value.vcpus
  memory          = each.value.memory
  disk_size       = each.value.disk_size
  ip              = each.value.ip
  prefix          = each.value.prefix
  gateway         = each.value.gateway
  mac             = each.value.mac
  adminlogin      = each.value.adminlogin
  adminpassword   = each.value.adminpassword
  network_name    = each.value.network_name
  vncport         = each.value.vncport
  ssh_public_key  = local.ssh_key

}

module "role_vms" {
  for_each        = var.role_vm_config
  source          = "./modules/libvirt-vm"
  pool_name       = libvirt_pool.vmspool.name
  basevolume_path = libvirt_volume.role_baseimage.path
  vm_name         = each.key
  vcpus           = each.value.vcpus
  memory          = each.value.memory
  disk_size       = each.value.disk_size
  ip              = each.value.ip
  prefix          = each.value.prefix
  gateway         = each.value.gateway
  mac             = each.value.mac
  adminlogin      = each.value.adminlogin
  adminpassword   = each.value.adminpassword
  network_name    = each.value.network_name
  vncport         = each.value.vncport
  ssh_public_key  = local.ssh_key
  depends_on      = [module.dc_vms]
}

module "client_vms" {
  for_each        = var.client_vm_config
  source          = "./modules/libvirt-vm"
  pool_name       = libvirt_pool.vmspool.name
  basevolume_path = libvirt_volume.client_baseimage.path
  vm_name         = each.key
  vcpus           = each.value.vcpus
  memory          = each.value.memory
  disk_size       = each.value.disk_size
  ip              = each.value.ip
  prefix          = each.value.prefix
  gateway         = each.value.gateway
  mac             = each.value.mac
  adminlogin      = each.value.adminlogin
  adminpassword   = each.value.adminpassword
  network_name    = each.value.network_name
  vncport         = each.value.vncport
  ssh_public_key  = local.ssh_key  
  depends_on      = [module.role_vms]
}

