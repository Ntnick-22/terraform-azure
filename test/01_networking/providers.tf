terraform{
    required_providers {
      azurerm = {
        source  = "hashicorp/azurerm"
        version = "~> 4.0"
      }
}

  backend "azurerm" {
    resource_group_name   = "prod-tfstate-rg"
    storage_account_name  = "prodtfstate123"
    container_name        = "tfstate"
    key                   = "01_networking/terraform.tfstate"
  }
}
provider "azurerm" {
    features {
    } 
}


data "terraform_remote_state" "rg" {
  backend = "azurerm"
  config = {
    resource_group_name  = "prod-tfstate-rg"
    storage_account_name = "prodtfstate123"
    container_name       = "tfstate"
    key                  = "00_resource_groups/terraform.tfstate"
  }
}