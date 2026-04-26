resource "azurerm_public_ip" "nat" {
  name                = "nat-gw-pip"
  location            = "West Europe"
  resource_group_name = "my-rg"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "core" {
  name                = "core-nat-gw"
  location            = "West Europe"
  resource_group_name = "my-rg"
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "core" {
  nat_gateway_id       = azurerm_nat_gateway.core.id
  public_ip_address_id = azurerm_public_ip.nat.id
}