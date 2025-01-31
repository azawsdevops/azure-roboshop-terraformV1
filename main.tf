module "database" {
  for_each  = var.database  # var.component is a map for all the components , if you want to deploy app with Terraform
  source    = "./modules/vm"
  database = each.value["name"]
  vm_size   = "Standard_B2s"
  env       = var.env
  vault_token = var.token
}
module "aks" {
  source = "./modules/aks"
    env    = var.env
}


