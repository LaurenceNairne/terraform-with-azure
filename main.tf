terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  cloud {
    organization = "laurence"
    workspaces {
      name = "terraform-gh-actions"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  client_id var.client_id
  subscription_id var.subscription_id
  tenant_id var.tenant_id
  client_secret var.client_secret
}

data "azurerm_client_config" "current" {}

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
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDosoCASr7Zy+KPZntem3vMcdYgshVeLleDXjpvGmRIqCP4lqGesr9OUYN/9kIdUZy7buBS/7YPEZkA86R40PU3JqtqMfT1TVm0NKuWY9Q7RjHDmQ8w3L62rXUYaOpV66FEBdGAPJ+OmS3FjEnAXuV+TzX81ZGiRf8edxEfZ7foJXc8+Gtl0i1/TYLL+CjVMmjBhPTa4/C7rpXe+Fei8gx/Q3tZ9sZGit9G8iVNnY37u0UbzAlOog2NvLshZq+dvoeEyfYqq8GZEkn3kEHEbMlfWKZ9ARQGm7Cwx7PI1kAHnycRZm+z0eCkOJ3jVD6bPUIS9WI4Qhi+QPgxo44fqQ4EYEwLdMLJ+KE40EIQ0vq6ZX2lUfMvonbs9SdGApk79p86by3tXWwaCL5sS2h1WinnS+9pk3ep626K2xv/lWRHAlO7AGpmuj+NKHeZ+GywvvdsSnApsEyiGCO/Xer0oQeyMBKZOLcjF4fmY77Le80eRi5HhYeHOKvfVDSkarJwRHgP6e2/whRKz6EQmhkkQSJZhKn5YRYDp1C+k7OG/PZE0WewRKpqJ94dmldd1Ur00Umvc6WOLvKQxCODWvfRlYzF4T+lJpArZbkcsPN+9Z8M04Hhm4r6B6d+W7i7Ry+TAjCturMYBMZn16cE4c1fsfUYUJaZNYeE7gMtSzDnS9hXqw== Azure Linux VM"
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

  tags = {
    environment = "dev"
  }
}