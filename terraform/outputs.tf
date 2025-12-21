# You can connect to vm with this command
# 
# ssh -oStrictHostKeyChecking=no  ubuntu@$(terraform output -no-color  -json virtual_machines |jq -r '.fs1.ip')

output "dc_vms" {
  description = "Информация о созданных виртуальных машинах dc"
  value = {
    for dc_name, vm_module in module.dc_vms :
    dc_name => {
      #id      = vm_module.vm_id
      #name    = vm_module.vm_name
      #ip      = vm_module.ip
      #vm_disk = vm_module.vm_disk
      all = vm_module
    }
  }
}

output "role_vms" {
  description = "Информация о созданных виртуальных машинах role"
  value = {
    for role_names, vm_module in module.role_vms :
    role_names => {
      #id      = vm_module.vm_id
      #name    = vm_module.vm_name
      #ip      = vm_module.ip
      #vm_disk = vm_module.vm_disk
      all = vm_module
    }
  }
}

output "client_vms" {
  description = "Информация о созданных виртуальных машинах"
  value = {
    for client_names, vm_module in module.client_vms :
    client_names => {
      #id      = vm_module.vm_id
      #name    = vm_module.vm_name
      #ip      = vm_module.ip
      #vm_disk = vm_module.vm_disk
      all = vm_module
    }
  }
}

output "libvirt_networks" {
  description = "Информация о созданных виртуальных сетях"
  value       = libvirt_network.networks
}
