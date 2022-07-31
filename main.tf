terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "laurence-rg" {
  name     = "laurence-rg"
  location = "UK South"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "laurence-vn" {
  name                = "laurence-vn"
  location            = azurerm_resource_group.laurence-rg.location
  resource_group_name = azurerm_resource_group.laurence-rg.name
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "laurence-subnet" {
  name                 = "laurence-subnet"
  resource_group_name  = azurerm_resource_group.laurence-rg.name
  virtual_network_name = azurerm_virtual_network.laurence-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "laurence-nsg" {
  name                = "laurence-nsg"
  location            = azurerm_resource_group.laurence-rg.location
  resource_group_name = azurerm_resource_group.laurence-rg.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "laurence-dev-nsr" {
  name                        = "laurence-dev-nsr"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.laurence-rg.name
  network_security_group_name = azurerm_network_security_group.laurence-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "laurence-ssga" {
  subnet_id                 = azurerm_subnet.laurence-subnet.id
  network_security_group_id = azurerm_network_security_group.laurence-nsg.id
}

resource "azurerm_public_ip" "laurence-ip" {
  name                = "laurence-ip"
  resource_group_name = azurerm_resource_group.laurence-rg.name
  location            = azurerm_resource_group.laurence-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "laurence-nic" {
  name                = "laurence-nic"
  location            = azurerm_resource_group.laurence-rg.location
  resource_group_name = azurerm_resource_group.laurence-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.laurence-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.laurence-ip.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "laurence-vm" {
  name                  = "laurence-vm"
  resource_group_name   = azurerm_resource_group.laurence-rg.name
  location              = azurerm_resource_group.laurence-rg.location
  size                  = "Standard_B1s"
  admin_username        = "laurence.nairne"
  network_interface_ids = [azurerm_network_interface.laurence-nic.id]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "laurence.nairne"
    public_key = file("~/.ssh/azure-vm-key_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}