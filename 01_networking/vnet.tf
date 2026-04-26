resource "azurerm_virtual_network" "core" {
  name                = "core-vnet"
  location            = "West Europe"
  resource_group_name = "my-rg"
  address_space       = ["10.0.0.0/16"]

  
}

resource "azurerm_virtual_network" "vpn" {
  name                = "vpn-vnet"
  location            = "West Europe"
  resource_group_name = "my-rg"
  address_space       = ["10.1.0.0/16"]

  
}