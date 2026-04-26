
resource "azurerm_virtual_network_peering" "core_to_vpn" {
  name                      = "core-to-vpn"
  resource_group_name       = "my-rg"
  virtual_network_name      = azurerm_virtual_network.core.name
  remote_virtual_network_id = azurerm_virtual_network.vpn.id
}

resource "azurerm_virtual_network_peering" "vpn_to_core" {
  name                      = "vpn-to-core"
  resource_group_name       = "my-rg"
  virtual_network_name      = azurerm_virtual_network.vpn.name
  remote_virtual_network_id = azurerm_virtual_network.core.id
}