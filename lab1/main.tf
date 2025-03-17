# This is a line comment

/* This is a block comment */

resource "azurerm_resource_group" "rg" {
  location = "eastus2"
  name     = "tf-workshop-rg"
}