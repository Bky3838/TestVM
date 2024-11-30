resource "azurerm_resource_group" "test-rg" {
  name     = "test-resourcegroup"
  location = "central India"
}

resource "azurerm_virtual_network" "test-vnet" {
  name                = "test-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name
}

resource "azurerm_subnet" "test-sub" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test-rg.name
  virtual_network_name = azurerm_virtual_network.test-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "test-nic" {
  name                = "test-nic1"
  location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test-sub.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "test-vm" {
  name                = "test-machine"
  resource_group_name = azurerm_resource_group.test-rg.name
  location            = azurerm_resource_group.test-rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.test-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}