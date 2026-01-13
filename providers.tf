terraform {  
  required_version = ">= 1.8.5"
    required_providers {
    azurerm = {
       source                = "hashicorp/azurerm"
       configuration_aliases = [azurerm]
    }
  }
}
provider "azurerm" {
  version = "=3.110.0"
  subscription_id = var.subscription_id
  features {}
  skip_provider_registration = "true"
  storage_use_azuread        = true
  use_msi = true  # Solo descomenta si ejecutas en Azure con Managed Identity habilitada  
}  
