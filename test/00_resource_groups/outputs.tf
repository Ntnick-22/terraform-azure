output "resource_groups" {
  value = {
    for k, v in azurerm_resource_group.prod_rg : k => {
      name     = v.name
      location = v.location
      tags     = v.tags
    }
  }
}