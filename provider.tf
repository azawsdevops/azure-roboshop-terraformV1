provider "azurerm" {
  features {}
  subscription_id = "4b236e6d-2c9a-4cb2-90a2-30a5377d8eb2"
}

terraform {
  backend "azurerm" {}
}

provider "vault" {
  address = "http://vault-internal.cloudaws.shop:8200"
  token   = var.token
}