output "resource_groups" {
    description = "The resource groups created in this module"
    value = {
      for k, v in azurerm_resource_group.mbr_rg : k => {
        name     = v.name
        location = v.location
        tags     = v.tags
      }
    }
}