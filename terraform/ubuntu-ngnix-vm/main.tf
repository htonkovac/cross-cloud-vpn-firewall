resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  enable_ip_forwarding = true
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.ip.id
  }
}

resource "azurerm_public_ip" "ip" {
  name = "${var.name}-ip"
    resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method = "Static"

  lifecycle {
    create_before_destroy = true
  }
}
resource "azurerm_linux_virtual_machine" "nginx" {
  size                = "Standard_B1ls"
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  custom_data         = base64encode(file("${path.module}/scripts/init.sh"))
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.ssh_public_key_file_path)
  }

  computer_name                   = "${var.name}.azure.lab"
  admin_username                  = "adminuser"
  disable_password_authentication = true

  os_disk {
    name                 = "${var.name}-nginxdisk01" #this needs to be unique per location
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

/* resource "azurerm_private_dns_a_record" "a_record" {
  name                = var.name
  zone_name           = "azure.lab"
  resource_group_name = var.resource_group_name
  ttl                 = 30
  records             = [azurerm_network_interface.nic.private_ip_address]
} */