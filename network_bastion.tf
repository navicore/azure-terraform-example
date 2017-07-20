resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "${azurerm_resource_group.mycloud.name}-bastion-nsg"
  location            = "${azurerm_resource_group.mycloud.location}"
  resource_group_name = "${azurerm_resource_group.mycloud.name}"

  security_rule {
    name                       = "allow_ssh_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny_internet_inbound"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "INTERNET"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet" "bastion_subnet" {
  name                      = "${azurerm_resource_group.mycloud.name}-bastion"
  resource_group_name       = "${azurerm_resource_group.mycloud.name}"
  virtual_network_name      = "${azurerm_virtual_network.mycloud.name}"
  address_prefix            = "10.0.1.0/24"
  network_security_group_id = "${azurerm_network_security_group.bastion_nsg.id}"
}

