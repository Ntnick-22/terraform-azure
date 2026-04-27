terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.65"
    }
  }
  
  # Store THIS module's state
  backend "azurerm" {
    resource_group_name  = "prod-tfstate-rg"
    storage_account_name = "prodtfstate123"
    container_name       = "tfstate"
    key                  = "03_azure_vm.tfstate"  # ← Different key
  }
}

provider "azurerm" {
  features {}
}


data "terraform_remote_state" "rg" {
    backend = "azurerm"
    config = {
    resource_group_name  = "prod-tfstate-rg"
    storage_account_name = "prodtfstate123"
    container_name       = "tfstate"
    key                  =  "00_resource_groups/terraform.tfstate" # from the RG module
  }
}

# 🔗 READ NETWORKING DATA
data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "prod-tfstate-rg"
    storage_account_name = "prodtfstate123"
    container_name       = "tfstate"
    key                  = "01-networking/terraform.tfstate"  # from the networking module
  }
}