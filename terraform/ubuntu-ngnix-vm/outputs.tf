output "vm_id" {
  value = azurerm_linux_virtual_machine.nginx.id
}

output "private_ip" {
  value = azurerm_network_interface.nic.private_ip_address
}

output "public_ip" {
    value = azurerm_public_ip.ip.ip_address
}