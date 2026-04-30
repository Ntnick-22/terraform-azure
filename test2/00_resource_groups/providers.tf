terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.1.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "my-tfstate-rg"
    storage_account_name = "mytfstate123"
    container_name       = "mytfcontainer"
    key                  = "00_resource_groups/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "df03e5ee-3b97-4f29-8a7b-0c1a55015171"
}

