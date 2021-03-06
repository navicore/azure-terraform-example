resource "azurerm_network_security_group" "private_nodes_nsg" {
  name                = "${azurerm_resource_group.mycloud.name}-private-nodes-nsg"
  location            = "${azurerm_resource_group.mycloud.location}"
  resource_group_name = "${azurerm_resource_group.mycloud.name}"

  security_rule {
    name                       = "allow_bastion_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_internal_8080"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "10.0.5.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny_all_inbound"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet" "private_nodes_subnet" {
  name                      = "${azurerm_resource_group.mycloud.name}-private-nodes"
  resource_group_name       = "${azurerm_resource_group.mycloud.name}"
  virtual_network_name      = "${azurerm_virtual_network.mycloud.name}"
  address_prefix            = "10.0.4.0/24"
  network_security_group_id = "${azurerm_network_security_group.private_nodes_nsg.id}"
}

