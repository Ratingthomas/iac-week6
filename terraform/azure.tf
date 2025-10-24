provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
  subscription_id                 = var.subscription_id
}

data "azurerm_resource_group" "main" {
  name = "S1501041"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
  count               = 2
  name                = "${var.name}-pip-${count.index + 1}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "main" {
  count               = 2
  name                = "${var.name}-nic-${count.index + 1}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "db" {
  name                = "week6-db"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.main[0].id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/azure.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  custom_data = filebase64("../cloudinit/userdata.yaml")
}

resource "azurerm_linux_virtual_machine" "web" {
  name                = "week6-web"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.main[1].id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/azure.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  custom_data = filebase64("../cloudinit/userdata.yaml")
}
