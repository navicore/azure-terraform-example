variable "resource_base_name" {}

variable "resource_suffix" {}

variable "private_key_path" {}

variable "public_key_path" {}

variable "vm_user" {}

variable "location" {}

variable "image" {
  type = "map"

  default = {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "latest"
  }
}

/* Bastion */
variable "bastion_size" {
  default = "Standard_A2"
}

/* Scanner */
variable "scanner_size" {
  default = "Standard_D12_V2"
}

variable "bastion_private_ip_address_index" {
  default = "5"
}

variable "scanner_private_ip_address_index" {
  default = "6"
}

