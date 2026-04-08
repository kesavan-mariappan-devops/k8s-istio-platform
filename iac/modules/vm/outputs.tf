output "vm_ip" {
  description = "IP address of the provisioned VM"
  value       = libvirt_domain.vm.network_interface[0].addresses[0]
}

output "vm_name" {
  value = libvirt_domain.vm.name
}
