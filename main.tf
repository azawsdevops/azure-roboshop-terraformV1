module "components" {
  for_each  = var.component
  source    = "./modules/vm"
  component = each.value["name"]
  vm_size   = "Standard_B2s"
  env       = var.env
  token     = var.token

}