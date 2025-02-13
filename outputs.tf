# Add locals block at the beginning
locals {
  vm_resource = var.vm_config.os_type == "Windows" ? azurerm_windows_virtual_machine.vm[0] : azurerm_linux_virtual_machine.vm[0]
}

# NIC Outputs
output "nic_id" {
  description = "Network interface ID"
  value       = azurerm_network_interface.nic.id
}

output "nic_name" {
  description = "Network interface name"
  value       = azurerm_network_interface.nic.name
}

output "nic_location" {
  description = "Network interface location"
  value       = azurerm_network_interface.nic.location
}

output "nic_resource_group_name" {
  description = "Network interface resource group name"
  value       = azurerm_network_interface.nic.resource_group_name
}

output "nic_ip_configuration" {
  description = "Network interface IP configuration"
  value       = azurerm_network_interface.nic.ip_configuration
}

output "nic_private_ip_address" {
  description = "Network interface private IP address"
  value       = azurerm_network_interface.nic.private_ip_address
}

output "nic_mac_address" {
  description = "Network interface MAC address"
  value       = azurerm_network_interface.nic.mac_address
}

# VM Outputs
output "vm_id" {
  description = "Virtual machine ID"
  value       = local.vm_resource.id
}

output "vm_name" {
  description = "Virtual machine name"
  value       = local.vm_resource.name
}

output "vm_location" {
  description = "Virtual machine location"
  value       = local.vm_resource.location
}

output "vm_resource_group_name" {
  description = "Virtual machine resource group name"
  value       = local.vm_resource.resource_group_name
}

output "vm_size" {
  description = "Virtual machine size"
  value       = local.vm_resource.size
}

output "vm_computer_name" {
  description = "Virtual machine computer name"
  value       = local.vm_resource.computer_name
}

output "vm_admin_username" {
  description = "Virtual machine admin username"
  value       = local.vm_resource.admin_username
}

output "vm_private_ip_address" {
  description = "Virtual machine private IP address"
  value       = azurerm_network_interface.nic.private_ip_address
}

output "vm_os_type" {
  description = "Operating system type of the virtual machine"
  value       = var.vm_config.os_type
}

output "vm_source_image_id" {
  description = "Virtual machine source image ID"
  value       = try(local.vm_resource.source_image_id, null)
}