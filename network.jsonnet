{
    /**
      dependencies: brew install jsonnet

      to generate terraform subnets.tf.json run:

      jsonnet -V ARM_SUBSCRIPTION_ID -V rg=mycloud -V location=eastus network.jsonnet > network.tf.json
    */

    //
    // PARAMS BEGIN
    //
    local env = {
        location: std.extVar("location"),
        resourceGroup: std.extVar("rg"),
        vnetName: std.extVar("rg"),
        subscriptionId: std.extVar("ARM_SUBSCRIPTION_ID"),
    },

    // list all subnet names here
    local subnets = [
        "bastion",
        "private_nodes",
        "public_nodes",
        "database",
        "cicd",
    ],

    // use subnet names above as keys for params below
    local specs = {
        bastion: {
            addressPrefix: "10.241.0.0/16",
            allowIn: [
                rule_allow_ssh_inet("bastion"),
                rule_deny_all,
            ],
            allowOut: [
            ],
        },
        private_nodes: {
            addressPrefix: "10.240.0.0/16",
            allowIn: [
                rule_allow_ssh_bastion("private_nodes"),
                rule_deny_all,
            ],
            allowOut: [
            ],
        },
        public_nodes: {
            addressPrefix: "10.246.0.0/16",
            allowIn: [
                rule_allow_ssh_bastion("public_nodes"),
                rule_deny_all,
            ],
            allowOut: [
            ],
        },
        database: {
            addressPrefix: "10.245.0.0/16",
            allowIn: [
                rule_allow_ssh_bastion("database"),
                rule_deny_all,
            ],
            allowOut: [
            ],
        },
        cicd: {
            addressPrefix: "10.242.0.0/16",
            allowIn: [
                rule_allow_ssh_bastion("cicd"),
                rule_deny_all,
            ],
            allowOut: [
            ],
        },

    },
    //
    // PARAMS END
    //

    //
    // PROCESSING BEGINS
    //
    resource: {
        // create network
        azurerm_network_security_group: [{
            [sn + "_nsg"]: [{
                name: env.resourceGroup + "-" + sn + "-nsg",
                location: env.location,
                resource_group_name: env.resourceGroup,
                security_rule: specs[sn].allowIn,
            }] for sn in subnets
        }],
        azurerm_subnet: [{
            [sn + "_subnet"]: [{
                name: env.resourceGroup + "-" + sn + "-subnet",
                resource_group_name: env.resourceGroup,
                virtual_network_name: env.vnetName,
                address_prefix: specs[sn].addressPrefix,
                network_security_group_id: "/subscriptions/" + env.subscriptionId + "/resourceGroups/" + env.resourceGroup + "/providers/Microsoft.Network/networkSecurityGroups/" + env.resourceGroup + "-" + sn + "-nsg",
            }] for sn in subnets
        }],
        azurerm_virtual_network: [{
            [env.vnetName]: {
                name: env.resourceGroup,
                resource_group_name: env.resourceGroup,
                location: env.location,
                address_space: ["10.0.0.0/8"],
            },
        }],

        // create bastion host
        azurerm_public_ip: [{
            bastion: {
                name: env.resourceGroup + "-bastion-pip",
                location: env.location,
                resource_group_name: env.resourceGroup,
                public_ip_address_allocation: "static",
                domain_name_label: env.resourceGroup + "-bastion",
            },
        }],

        azurerm_network_interface: [{
            name: env.resourceGroup + "-bastion",
            location: env.location,
            resource_group_name: env.resourceGroup,
            network_security_group_id: "/subscriptions/" + env.subscriptionId + "/resourceGroups/" + env.resourceGroup + "/providers/Microsoft.Network/networkSecurityGroups/s00159test-bastion-nsg",
            ip_configuration: [{
                name: env.resourceGroup + "-bastion",
                private_ip_address_allocation: "static",
                private_ip_address: "10.0.1.5",
                subnet_id: "/subscriptions/" + env.subscriptionId + "/resourceGroups/" + env.resourceGroup + "/providers/Microsoft.Network/virtualNetworks/" + env.resourceGroup + "-bastion",
                public_ip_address_id: "/subscriptions/" + env.subscriptionId + "/resourceGroups/" + env.resourceGroup + "/providers/Microsoft.Network/publicIPAddresses/" + env.resourceGroup + "-bastion-pip",
            }],

        }],
        azurerm_resource_group: [{
            mycloud: {
                name: env.resourceGroup,
                location: env.location,
            },
        }],


        /* data "template_file" "bastion" { */
        /*   template = "${file("files/install.sh")}" */
        /*   vars { */
        /*   } */
        /* } */
        /*  */
        /*  */
        /* resource "azurerm_virtual_machine" "bastion" { */
        /*   name                          = "${azurerm_resource_group.mycloud.name}-bastion" */
        /*   location                      = "${azurerm_resource_group.mycloud.location}" */
        /*   resource_group_name           = "${azurerm_resource_group.mycloud.name}" */
        /*   network_interface_ids         = ["${azurerm_network_interface.bastion.id}"] */
        /*   vm_size                       = "${var.bastion_size}" */
        /*   delete_os_disk_on_termination = true */
        /*  */
        /*   lifecycle { */
        /*     ignore_changes = ["admin_password"] */
        /*   } */
        /*  */
        /*   storage_image_reference { */
        /*     publisher = "${var.image["publisher"]}" */
        /*     offer     = "${var.image["offer"]}" */
        /*     sku       = "${var.image["sku"]}" */
        /*     version   = "${var.image["version"]}" */
        /*   } */
        /*  */
        /*   storage_os_disk { */
        /*     name          = "${azurerm_resource_group.mycloud.name}-bastion" */
        /*     vhd_uri       = "${azurerm_storage_account.mycloud.primary_blob_endpoint}${azurerm_storage_container.mycloud.name}/bastion_os_disk.vhd" */
        /*     caching       = "ReadWrite" */
        /*     create_option = "FromImage" */
        /*   } */
        /*  */
        /*   os_profile { */
        /*     computer_name  = "${azurerm_resource_group.mycloud.name}-bastion" */
        /*     admin_username = "${var.vm_user}" */
        /*     admin_password = "${uuid()}" */
        /*   } */
        /*  */
        /*   os_profile_linux_config { */
        /*     disable_password_authentication = true */
        /*  */
        /*     ssh_keys { */
        /*       path     = "/home/${var.vm_user}/.ssh/authorized_keys" */
        /*       key_data = "${file(var.public_key_path)}" */
        /*     } */
        /*   } */
        /*  */
        /*   connection { */
        /*     host        = "${azurerm_public_ip.bastion.fqdn}" */
        /*     user        = "${var.vm_user}" */
        /*     private_key = "${file(var.private_key_path)}" */
        /*   } */
        /*  */
        /*   provisioner "remote-exec" { */
        /*     inline = [ */
        /*       "${data.template_file.bastion.rendered}", */
        /*     ] */
        /*   } */
        /*  */
        /* } */

    },
    output: [{
        rgname: {
            value: env.resourceGroup,
        },

        location: {
            value: env.location,
        },

        publicNodesSubnet: {
            value: "/subscriptions/71387571-4c0f-4bd4-81b8-2a2c63169be1/resourceGroups/mycloudexample/providers/Microsoft.Network/virtualNetworks/mycloudexample/subnets/mycloudexample-public_nodes",
        },

        privateNodesSubnet: {
            value: "/subscriptions/71387571-4c0f-4bd4-81b8-2a2c63169be1/resourceGroups/mycloudexample/providers/Microsoft.Network/virtualNetworks/mycloudexample/subnets/mycloudexample-private_nodes",
        },

        databaseSubnet: {
            value: "/subscriptions/71387571-4c0f-4bd4-81b8-2a2c63169be1/resourceGroups/mycloudexample/providers/Microsoft.Network/virtualNetworks/mycloudexample/subnets/mycloudexample-database",
        },

        cicdSubnet: {
            value: "/subscriptions/71387571-4c0f-4bd4-81b8-2a2c63169be1/resourceGroups/mycloudexample/providers/Microsoft.Network/virtualNetworks/mycloudexample/subnets/mycloudexample-cicd",
        },

        fqdn: {
            value: "${azurerm_public_ip.bastion.fqdn}",
            //value: "/subscriptions/" + env.subscriptionId + "/resourceGroups/" + env.resourceGroup + "/providers/Microsoft.Network/publicIPAddresses/" + env.resourceGroup + "-bastion-pip/fqdn",
        },
    }],

    //
    // PROCESSING ENDS
    //

    //
    // RULES BEGIN
    //
    local rule_allow_ssh_inet(sn) = {
        name: "allow_ssh_in_from_inet",
        priority: 100,
        direction: "Inbound",
        access: "Allow",
        protocol: "Tcp",
        source_port_range: "*",
        destination_port_range: "22",
        source_address_prefix: "INTERNET",
        destination_address_prefix: specs[sn].addressPrefix,
    },
    local rule_allow_ssh_bastion(sn) = {
        name: "allow_ssh_in_from_bastion",
        priority: 110,
        direction: "Inbound",
        access: "Allow",
        protocol: "Tcp",
        source_port_range: "*",
        destination_port_range: "22",
        source_address_prefix: specs.bastion.addressPrefix,
        destination_address_prefix: specs[sn].addressPrefix,
    },
    local rule_deny_all = {
        name: "deny_all_inbound",
        priority: 300,
        direction: "Inbound",
        access: "Deny",
        protocol: "*",
        source_port_range: "*",
        destination_port_range: "*",
        source_address_prefix: "*",
        destination_address_prefix: "*",
    },
    //
    // RULES END
    //

}
