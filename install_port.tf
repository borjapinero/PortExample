terraform {
  required_providers {
    port-labs = {
      source  = "port-labs/port-labs"
      version = "~> 0.9.6"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id   = "7667bfd6-4676-4837-8d8c-f6f1bf9bc870"
  tenant_id         = "ba351225-3ca4-45f4-b7cc-ff5556c74a3e"
  client_id         = "59e11571-feaa-4193-a550-d36a70c9ad7a"
  client_secret     = "L2-8Q~51bJoRlKszPKllHsy67N-RWojcIfPeoclt"
  skip_provider_registration = "true"
}


provider "port-labs" {
  client_id = "MlE0ycnsT2qByn36hf6Ms8DfkZNAC4Ex"     # or set the environment variable PORT_CLIENT_ID
  secret    = "W5oTt3elGIHi1lSWieE1DHLwKjPpTj5m1E4GL3cvIdoL85LeC8YX3gJovQjDA9Rc" # or set the environment variable PORT_CLIENT_SECRET
}

# Create a Resource Group if it doesn’t exist
resource "azurerm_resource_group" "tfexample" {
  name     = "Port"
  location = "West Europe"
}

# Create a Virtual Network
resource "azurerm_virtual_network" "tfexample" {
  name                = "my-terraform-vnet"
  location            = azurerm_resource_group.tfexample.location
  resource_group_name = azurerm_resource_group.tfexample.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "my-terraform-env"
  }
}

# Create a Subnet in the Virtual Network
resource "azurerm_subnet" "tfexample" {
  name                 = "my-terraform-subnet"
  resource_group_name  = azurerm_resource_group.tfexample.name
  virtual_network_name = azurerm_virtual_network.tfexample.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a Network Interface
resource "azurerm_network_interface" "tfexample" {
  name                = "my-terraform-nic"
  location            = azurerm_resource_group.tfexample.location
  resource_group_name = azurerm_resource_group.tfexample.name

  ip_configuration {
    name                          = "my-terraform-nic-ip-config"
    subnet_id                     = azurerm_subnet.tfexample.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "my-terraform-env"
  }
}

# Create a Virtual Machine
resource "azurerm_linux_virtual_machine" "tfexample" {
  name                            = "my-terraform-vm"
  location                        = azurerm_resource_group.tfexample.location
  resource_group_name             = azurerm_resource_group.tfexample.name
  network_interface_ids           = [azurerm_network_interface.tfexample.id]
  size                            = "Standard_DS1_v2"
  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = "Password1234!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "my-terraform-os-disk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    environment = "my-terraform-env"
  }
}
