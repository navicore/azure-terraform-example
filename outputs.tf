output "Resource Group Name" {
  value = "${azurerm_resource_group.mycloud.name}"
}

output "Resource Group Location" {
  value = "${azurerm_resource_group.mycloud.location}"
}

output "Public Nodes Subnet" {
  value = "${azurerm_subnet.public_nodes_subnet.id}"
}

output "Private Nodes Subnet" {
  value = "${azurerm_subnet.private_nodes_subnet.id}"
}

output "Database Subnet" {
  value = "${azurerm_subnet.database_subnet.id}"
}

output "CI/CD Subnet" {
  value = "${azurerm_subnet.cicd_subnet.id}"
}

output "bastion_fqdn" {
  value = "${azurerm_public_ip.bastion.fqdn}"
}

