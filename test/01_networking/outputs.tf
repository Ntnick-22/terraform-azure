output "vnet_ids" {
  value = {
    for k, v in azurerm_virtual_network.prod_vnet : k => v.id
  }
}

output "subnet_ids" {
  value = {
    for k, v in azurerm_subnet.prod_subnet : k => v.id
  }
}

output "subnets" {
  value = azurerm_subnet.prod_subnet
}