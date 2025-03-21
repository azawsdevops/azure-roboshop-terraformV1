data "azurerm_resource_group" "main" {
  name = "azuredevops"
}

data "azurerm_subnet" "main" {
  name                 = "default"
  virtual_network_name = "azure-network"
  resource_group_name  = data.azurerm_resource_group.main.name
}

data "azurerm_container_registry" "acr" {
  name                = "cloudaws"
  resource_group_name = data.azurerm_resource_group.main.name
}

data "vault_generic_secret" "az" {
  path = "github-action/azure_sp"
}