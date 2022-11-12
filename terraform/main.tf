resource "azurerm_resource_group" "rg" {
  name     = "cross-cloud-vpn-firewall"
  location = "West Europe"
}

module "vnetA" {
  source              = "./vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_name           = "vnet-A"
  address_space       = ["10.100.0.0/16"]
  subnets = { "subnet-A1" = {
    name          = "subnet-A1"
    address_space = ["10.100.0.0/24"]
  } }
}

module "vmA" {
  source                   = "./ubuntu-ngnix-vm"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  name                     = "vm-A"
  subnet_id                = module.vnetA.subnets["subnet-A1"].id
  ssh_public_key_file_path = "${path.module}/../ssh-keys/mykey.pub"
}

module "vnetB" {
  source              = "./vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_name           = "vnet-B"
  address_space       = ["10.101.0.0/16"]
  subnets = { "subnet-B1" = {
    name          = "subnet-B1"
    address_space = ["10.101.0.0/24"]
  } }
}


module "vmB" {
  source                   = "./ubuntu-ngnix-vm"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  name                     = "vm-B"
  subnet_id                = module.vnetB.subnets["subnet-B1"].id
  ssh_public_key_file_path = "${path.module}/../ssh-keys/mykey.pub"
}

module "extra_vms_in_A" {
  count = 1
  source                   = "./ubuntu-ngnix-vm"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  name                     = "vm-A${count.index}"
  subnet_id                = module.vnetA.subnets["subnet-A1"].id
  ssh_public_key_file_path = "${path.module}/../ssh-keys/mykey.pub"
}


module "extra_vms_in_B" {
  count = 2
  source                   = "./ubuntu-ngnix-vm"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  name                     = "vm-B${count.index}"
  subnet_id                = module.vnetB.subnets["subnet-B1"].id
  ssh_public_key_file_path = "${path.module}/../ssh-keys/mykey.pub"
}

resource "azurerm_route" "atob" {
  name                = "atob"
  resource_group_name = azurerm_resource_group.rg.name
  route_table_name    = module.vnetA.default_route_table_name
  address_prefix      = module.vnetB.address_space[0]
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = module.vmA.private_ip
}

resource "azurerm_route" "btoa" {
  name                = "btoa"
  resource_group_name      = azurerm_resource_group.rg.name
  route_table_name    = module.vnetB.default_route_table_name
  address_prefix      = module.vnetA.address_space[0]
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = module.vmB.private_ip
}
