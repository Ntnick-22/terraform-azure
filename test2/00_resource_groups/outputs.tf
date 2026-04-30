output "resource_groups" {
  value = {
    for k, v in azurerm_resource_group.my_rg : k => {
      name     = v.name
      location = v.location
      tags     = v.tags
    }
  }
}