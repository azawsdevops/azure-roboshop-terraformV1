resource "azurerm_kubernetes_cluster" "main" {
  name                = "roboshop-aks"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = "dev"

  default_node_pool {
	name       = "default"
	node_count = 1
	vm_size    = "Standard_D2_v2"
	auto_scaling_enabled = true
    min_count = 1
	max_count = 5
	vnet_subnet_id = "/subscriptions/4b236e6d-2c9a-4cb2-90a2-30a5377d8eb2/resourceGroups/azuredevops/providers/Microsoft.Network/virtualNetworks/azure-network/subnets/default"
  }
  aci_connector_linux {
	subnet_name = "/subscriptions/4b236e6d-2c9a-4cb2-90a2-30a5377d8eb2/resourceGroups/azuredevops/providers/Microsoft.Network/virtualNetworks/azure-network/subnets/default"
  }
  network_profile {
	network_plugin = "azure"
	service_cidr   = "10.100.0.0/24"
	dns_service_ip = "10.100.0.100"
	
  }
  identity {
	type = "SystemAssigned" 
	
  }

  tags = {
	Environment = "${var.env}-aks-roboshop"
  }
}

# resource "azurerm_role_assignment" "example" {
#   principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
#   role_definition_name             = "AcrPull"
#   scope                            = data.azurerm_container_registry.acr.name
#   skip_service_principal_aad_check = true
# }