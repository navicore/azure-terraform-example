resource "azurerm_public_ip" "bastion" {
  name                         = "${azurerm_resource_group.mycloud.name}-bastion-pip"
  location                     = "${azurerm_resource_group.mycloud.location}"
  resource_group_name          = "${azurerm_resource_group.mycloud.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${azurerm_resource_group.mycloud.name}-bastion"
}

resource "azurerm_network_interface" "bastion" {
  name                      = "${azurerm_resource_group.mycloud.name}-bastion"
  location                  = "${azurerm_resource_group.mycloud.location}"
  resource_group_name       = "${azurerm_resource_group.mycloud.name}"
  network_security_group_id = "${azurerm_network_security_group.bastion_nsg.id}"

  ip_configuration {
    name                          = "${azurerm_resource_group.mycloud.name}-bastion"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.0.1.${var.bastion_private_ip_address_index}"
    subnet_id                     = "${azurerm_subnet.bastion_subnet.id}"
    public_ip_address_id          = "${azurerm_public_ip.bastion.id}"
  }
}

data "template_file" "bastion" {
  template = "${file("files/install.sh")}"
  vars {
  }
}


resource "azurerm_virtual_machine" "bastion" {
  name                          = "${azurerm_resource_group.mycloud.name}-bastion"
  location                      = "${azurerm_resource_group.mycloud.location}"
  resource_group_name           = "${azurerm_resource_group.mycloud.name}"
  network_interface_ids         = ["${azurerm_network_interface.bastion.id}"]
  vm_size                       = "${var.bastion_size}"
  delete_os_disk_on_termination = true

  lifecycle {
    ignore_changes = ["admin_password"]
  }

  storage_image_reference {
    publisher = "${var.image["publisher"]}"
    offer     = "${var.image["offer"]}"
    sku       = "${var.image["sku"]}"
    version   = "${var.image["version"]}"
  }

  storage_os_disk {
    name          = "${azurerm_resource_group.mycloud.name}-bastion"
    vhd_uri       = "${azurerm_storage_account.mycloud.primary_blob_endpoint}${azurerm_storage_container.mycloud.name}/bastion_os_disk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${azurerm_resource_group.mycloud.name}-bastion"
    admin_username = "${var.vm_user}"
    admin_password = "${uuid()}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.vm_user}/.ssh/authorized_keys"
      key_data = "${file(var.public_key_path)}"
    }
  }

  connection {
    host        = "${azurerm_public_ip.bastion.fqdn}"
    user        = "${var.vm_user}"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "${data.template_file.bastion.rendered}",
    ]
  }

}

