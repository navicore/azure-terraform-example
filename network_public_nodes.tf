resource "azurerm_network_security_group" "public_nodes_nsg" {
  name                = "${azurerm_resource_group.mycloud.name}-public-nodes-nsg"
  location            = "${azurerm_resource_group.mycloud.location}"
  resource_group_name = "${azurerm_resource_group.mycloud.name}"

  security_rule {
    name                       = "allow_internal"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http_inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "INTERNET"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_https_inbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "INTERNET"
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

resource "azurerm_subnet" "public_nodes_subnet" {
  name                      = "${azurerm_resource_group.mycloud.name}-public-nodes"
  resource_group_name       = "${azurerm_resource_group.mycloud.name}"
  virtual_network_name      = "${azurerm_virtual_network.mycloud.name}"
  address_prefix            = "10.0.5.0/24"
  network_security_group_id = "${azurerm_network_security_group.public_nodes_nsg.id}"
}

