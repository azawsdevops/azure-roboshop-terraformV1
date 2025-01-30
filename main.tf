module "components" {
  for_each  = var.component  # var.component is a map for all the components , if you want to deploy app with Terraform
  source    = "./modules/vm"
  component = each.value["name"]
  vm_size   = "Standard_B2s"
  env       = var.env
  vault_token = var.token
}


