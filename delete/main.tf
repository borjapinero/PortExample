terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "7667bfd6-4676-4837-8d8c-f6f1bf9bc870"
  tenant_id       = "ba351225-3ca4-45f4-b7cc-ff5556c74a3e"
  client_id       = "aa586f5a-a9b9-43cc-9255-9728dfccad47"
  client_secret   = "AT98Q~TtiLmv3SUGyR7bAEyL0AYQbBZGNixgucb~"
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  default     = "POCSignature-SEM-DEV"
}

variable "location" {
  description = "Ubicación de Azure"
  default     = "westeurope"
}
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.example.name
  location = var.location
}

resource "azurerm_subnet" "example" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_public_ip" "example" {
  name                = "my-public-ip"
  resource_group_name = azurerm_resource_group.example.name
  location = var.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "example" {
  name                = "my-nic"
  resource_group_name = azurerm_resource_group.example.name
  location = var.location

  ip_configuration {
    name                          = "my-nic-cfg"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_virtual_machine" "example" {
  name                = "my-vm-PORT"
  resource_group_name = azurerm_resource_group.example.name

  depends_on = [
    azurerm_network_interface.example
  ]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "my-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "my-vm-PORT"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
