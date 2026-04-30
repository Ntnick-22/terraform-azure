
resource "azurerm_virtual_network_peering" "core_to_vpn" {
  name                      = "core-to-vpn"
  resource_group_name       = "my-rg"
  virtual_network_name      = azurerm_virtual_network.vnet["core-vnet"].name
  remote_virtual_network_id = azurerm_virtual_network.vnet["vpn-vnet"].id
}

resource "azurerm_virtual_network_peering" "vpn_to_core" {
  name                      = "vpn-to-core"
  resource_group_name       = "my-rg"
  virtual_network_name      = azurerm_virtual_network.vnet["vpn-vnet"].name
  remote_virtual_network_id = azurerm_virtual_network.vnet["core-vnet"].id
}