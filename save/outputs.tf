output "Resource Group Name" {
  value = "${azurerm_resource_group.mycloud.name}"
}

output "Resource Group Location" {
  value = "${azurerm_resource_group.mycloud.location}"
}

output "Public Nodes Subnet" {
  value = "/subscriptions/71387571-4c0f-4bd4-81b8-2a2c63169be1/resourceGroups/mycloudexample/providers/Microsoft.Network/virtualNetworks/mycloudexample/subnets/mycloudexample-public_nodes"
}

output "Private Nodes Subnet" {
  value = "/subscriptions/71387571-4c0f-4bd4-81b8-2a2c63169be1/resourceGroups/mycloudexample/providers/Microsoft.Network/virtualNetworks/mycloudexample/subnets/mycloudexample-private_nodes"
}

output "Database Subnet" {
  value = "/subscriptions/71387571-4c0f-4bd4-81b8-2a2c63169be1/resourceGroups/mycloudexample/providers/Microsoft.Network/virtualNetworks/mycloudexample/subnets/mycloudexample-database"
}

output "CI/CD Subnet" {
  value = "/subscriptions/71387571-4c0f-4bd4-81b8-2a2c63169be1/resourceGroups/mycloudexample/providers/Microsoft.Network/virtualNetworks/mycloudexample/subnets/mycloudexample-cicd"
}

output "bastion_fqdn" {
  value = "${azurerm_public_ip.bastion.fqdn}"
}

