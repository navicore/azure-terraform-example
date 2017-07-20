resource "azurerm_resource_group" "mycloud" {
  name     = "${var.resource_base_name}${var.resource_suffix}"
  location = "${var.location}"
}

resource "azurerm_storage_account" "mycloud" {
  name                = "${var.resource_base_name}${var.resource_suffix}"
  resource_group_name = "${azurerm_resource_group.mycloud.name}"
  location            = "${azurerm_resource_group.mycloud.location}"
  account_type        = "Standard_LRS"
}

output "Primary Access Key" {
  value = "${azurerm_storage_account.mycloud.primary_access_key}"
}

resource "azurerm_storage_container" "state" {
  name                  = "terraform-state"
  resource_group_name   = "${azurerm_resource_group.mycloud.name}"
  storage_account_name  = "${azurerm_storage_account.mycloud.name}"
  container_access_type = "private"
}

resource "azurerm_storage_container" "mycloud" {
  name                  = "mycloudnet"
  resource_group_name   = "${azurerm_resource_group.mycloud.name}"
  storage_account_name  = "${azurerm_storage_account.mycloud.name}"
  container_access_type = "private"
}

resource "azurerm_storage_container" "logging" {
  name                  = "logging"
  resource_group_name   = "${azurerm_resource_group.mycloud.name}"
  storage_account_name  = "${azurerm_storage_account.mycloud.name}"
  container_access_type = "private"
}

