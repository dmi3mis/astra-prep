output "vm_id" {
  description = "ID созданной виртуальной машины"
  value       = libvirt_domain.vm.id
}

# output "vm" {
#  description = " Виртуальная машина со всеми свойствами"
#  value       = try(libvirt_domain.vm, null)
# }

output "vm_name" {
  description = "Имя виртуальной машины"
  value       = libvirt_domain.vm.name
}

output "ip" {
  description = "IP адрес виртуальной машины"
  value       = try(libvirt_domain.vm.devices.interfaces[0].address, null)
}

output "vm_disk" {
  description = "Информация о созданных виртуальных дисках"
  value       = libvirt_volume.vm_disk
}