resource "azurerm_virtual_network" "vnet" {
  for_each = var.vnets
  name                = each.key
  address_space       = each.value.address_space
  location            = data.terraform_remote_state.rg.outputs.resource_groups["my-rg"].location  
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_groups["my-rg"].name
  tags                = { ManagedBy = "Terraform", project = "Training" }
}

locals {
  vnet_subnets = flatten([
    for vnet_key, vnet in var.vnets : [
      for snet_key, snet in vnet.subnets : {
        vnet_name   = vnet_key
        snet_name = snet_key 
        prefixes = snet.address_prefixes
        service_endpoints= try(snet.service_endpoints, [])
      }
    ]
  ])
}

resource "azurerm_subnet" "subnet" {
  for_each = { for s in local.vnet_subnets : "${s.vnet_name}.${s.snet_name}" => s }
  name                 = each.value.snet_name
  resource_group_name  = data.terraform_remote_state.rg.outputs.resource_groups["my-rg"].name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_name].name
  address_prefixes     = each.value.prefixes
  service_endpoints    = each.value.service_endpoints
}


