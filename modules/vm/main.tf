resource "azurerm_public_ip" "main" {
  name                = "${var.component}-${var.env}-ip"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"

  tags = {
	component = "${var.component}-${var.env}-ip"
  }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.component}-${var.env}-nic"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
	name                          = "internal"
	subnet_id                     = data.azurerm_subnet.main.id
	private_ip_address_allocation = "Dynamic"
	public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.component}-${var.env}-nsg"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  security_rule {
	name                       = "main"
	priority                   = 100
	direction                  = "Inbound"
	access                     = "Allow"
	protocol                   = "Tcp"
	source_port_range          = "*"
	destination_port_range     = "*"
	source_address_prefix      = "*"
	destination_address_prefix = "*"
  }

  tags = {
	component = "${var.component}-${var.env}-nsg"
  }
}


resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_dns_a_record" "main" {
  name                = "${var.component}-${var.env}"
  zone_name           = "cloudaws.shop"
  resource_group_name = data.azurerm_resource_group.main.name
  ttl                 = 10
  records = [azurerm_network_interface.main.private_ip_address]
}


resource "azurerm_virtual_machine" "main" {
  depends_on = [azurerm_network_interface_security_group_association.main, azurerm_dns_a_record.main]
  name                = "${var.component}-${var.env}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size = var.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  storage_image_reference {
	id = "/subscriptions/4b236e6d-2c9a-4cb2-90a2-30a5377d8eb2/resourceGroups/azuredevops/providers/Microsoft.Compute/galleries/azawsdevops/images/azawsdevops/versions/1.0.0"  
  }

  storage_os_disk {
	name              = "${var.component}-${var.env}"
	caching           = "ReadWrite"
	create_option     = "FromImage"
	managed_disk_type = "Standard_LRS"
  }
  os_profile {
	computer_name  = var.component
	admin_username = "testadmin"
	admin_password = "Password1234!"
  }
  os_profile_linux_config {
	disable_password_authentication = false
  }
  tags = {
	component = "${var.component}-${var.env}"
  }
}


resource "null_resource" "ansible" {

  depends_on = [azurerm_virtual_machine.main]

  provisioner "remote-exec" {

	connection {
	  type     = "ssh"
	  user     = replace(replace(jsonencode(data.vault_generic_secret.secret_data.data["admin_username"]), "\"", ""), ":", "=")
	  password = replace(replace(jsonencode(data.vault_generic_secret.secret_data.data["admin_password"]), "\"", ""), ":", "=")
	  host     = azurerm_public_ip.main.ip_address
	}

	inline = [
	  "sudo dnf install python3.12-pip -y",
	  "sudo pip3.12 install ansible",
	  "ansible-pull -i localhost, -U https://github.com/kp3073/az-roboshop-ansible roboshop.yml -e app_name=${var.component} -e env=${var.env}"
	]
  }
}
