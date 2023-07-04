terraform {
      backend "azurerm" {
            resource_group_name  = "POCSignature-SEM-DEV"
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
  default     = ${{ secrets.AZURE_SUBSCRIPTION_ID }}
}

variable "azure_client_id" {
  description = "ID del cliente de Azure"
  default     = ${{ secrets.AZURE_CLIENT_ID }}
}

variable "azure_client_secret" {
  description = "Secreto del cliente de Azure"
  default     = ${{ secrets.AZURE_CLIENT_SECRET }}
}

variable "azure_tenant_id" {
  description = "ID del inquilino de Azure"
  default     = ${{ secrets.AZURE_TENANT_ID }}
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  default     = "POCSignature-SEM-DEV"
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

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "my-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "example" {
  name                = "my-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "my-nic-cfg"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_virtual_machine" "example" {
  name                  = var.vm_name
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = var.vm_size

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
