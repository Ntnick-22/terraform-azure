resource "azurerm_virtual_network" "prod_vnet" {
  for_each = var.vnets
    name                = each.key
    location            = "West Europe"
    resource_group_name = data.terraform_remote_state.rg.outputs.resource_groups["prod-rg"].name
    address_space       = each.value.address_space
    tags                = data.terraform_remote_state.rg.outputs.resource_groups["prod-rg"].tags

}

locals {
  vnet_subnets = flatten([
    for vnet_key, vnet in var.vnets : [
      for snet_key, snet in vnet.subnets : {
        vnet_name   = vnet_key
        snet_name   = snet_key 
        prefixes    = snet.address_prefixes
        service_endpoints= try(snet.service_endpoints, [])
      }
    ]
  ])
}

resource "azurerm_subnet" "prod_subnet" {
  for_each = { for s in local.vnet_subnets : "${s.vnet_name}.${s.snet_name}" => s }
    name                 = each.value.snet_name
    resource_group_name  = data.terraform_remote_state.rg.outputs.resource_groups["prod-rg"].name
    virtual_network_name = azurerm_virtual_network.prod_vnet[each.value.vnet_name].name
    address_prefixes     = each.value.prefixes
    service_endpoints    = each.value.service_endpoints
  
}