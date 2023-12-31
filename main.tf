terraform {
      backend "azurerm" {
            resource_group_name  = "Port"
            storage_account_name = "saport"
            container_name       = "tfstate"
            key                  = "terraform.tfstate"
        }
        required_providers {
            azurerm = {
                  source  = "hashicorp/azurerm"
                  version = "2.42.0"
            }
        }
}

provider "azurerm" {
  features {}
}

variable "azure_subscription_id" {
  description = "ID de la suscripción de Azure"
  default     = "7667bfd6-4676-4837-8d8c-f6f1bf9bc870"
}

variable "azure_client_id" {
  description = "ID del cliente de Azure"
  default     = "2fff09bd-b095-47e5-af11-56113f31d7ca"
}

variable "azure_client_secret" {
  description = "Secreto del cliente de Azure"
  default     = "Zb28Q~79PIAVFrKJnIlzn3LVCCeE~T62FyG-3bVe"
}

variable "azure_tenant_id" {
  description = "ID del inquilino de Azure"
  default     = "ba351225-3ca4-45f4-b7cc-ff5556c74a3e"
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  default     = "Port"
}

variable "location" {
  description = "Ubicación de Azure"
  default     = "westeurope"
}

variable "vm_name" {
  description = "Nombre de la máquina virtual"
  default     = "my-vm-PORT"
}

variable "vm_size" {
  description = "Tamaño de la máquina virtual"
  default     = "Standard_DS1_v2"
}

variable "admin_username" {
  description = "Nombre de usuario del administrador"
  default     = "adminuser"
}

variable "admin_password" {
  description = "Contraseña del administrador"
  default     = "P@ssw0rd123!"
}

resource "azurerm_virtual_network" "example" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "example" {
  name                 = "my-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "my-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "example" {
  name                = "my-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "my-nic-cfg"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_virtual_machine" "example" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = var.vm_size
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

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
    computer_name  = var.vm_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "staging"
  }
}
