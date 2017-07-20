resource "azurerm_virtual_network" "mycloud" {
  name                = "${azurerm_resource_group.mycloud.name}"
  resource_group_name = "${azurerm_resource_group.mycloud.name}"
  location            = "${azurerm_resource_group.mycloud.location}"
  address_space       = ["10.0.0.0/8"]
}

