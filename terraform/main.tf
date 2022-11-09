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