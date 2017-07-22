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
        azurerm_network_security_group: {
            [sn + "_nsg"]: [{
                name: env.resourceGroup + "-" + sn + "-nsg",
                location: env.location,
                resource_group_name: env.resourceGroup,
                security_rule: specs[sn].allowIn,
            }] for sn in subnets
        },
        azurerm_subnet: {
            [sn + "_nsg"]: [{
                name: env.resourceGroup + "-" + sn + "-subnet",
                resource_group_name: env.resourceGroup,
                virtual_network_name: env.vnetName,
                address_prefix: specs[sn].addressPrefix,
                network_security_group_id: "/subscriptions/" + env.subscriptionId + "/resourceGroups/" + env.resourceGroup + "/providers/Microsoft.Network/networkSecurityGroups/" + env.resourceGroup + "-" + sn + "-nsg",
            }] for sn in subnets
        },
        azurerm_virtual_network: {
            [env.vnetName]: {
                name: env.resourceGroup,
                resource_group_name: env.resourceGroup,
                location: env.location,
                address_space: ["10.0.0.0/8"],
            },
        },

    },

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
