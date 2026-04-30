terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.1.0"
    }
  }

    backend "azurerm" {
        resource_group_name   = "prod-tfstate-rg"
        storage_account_name  = "prodtfstate123"
        container_name        = "tfstate"
        key                   = "00_resource_groups/terraform.tfstate"
    }
}

provider "azurerm" {
  features {
    
    
  }
}