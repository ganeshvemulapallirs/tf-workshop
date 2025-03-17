terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "2f28adf4-5b31-4131-8c53-300a1fcf7407"
}
