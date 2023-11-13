resource "random_string" "random_key_gen" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}
# Create a virtual network
resource "azurerm_virtual_network" "this" {
  name                = "vnet-eus-${random_string.random_key_gen.result}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.rg_name
}

# Create a subnet
resource "azurerm_subnet" "this" {
  name                 = "subnet-eus-${random_string.random_key_gen.result}"
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP address
resource "azurerm_public_ip" "this" {
  name                = "pip-eus-${random_string.random_key_gen.result}"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Dynamic"
}

# Create a network security group
resource "azurerm_network_security_group" "this" {
  name                = "nsg-eus-${random_string.random_key_gen.result}"
  location            = var.location
  resource_group_name = var.rg_name
}

# Create a network security group rule to allow RDP traffic
resource "azurerm_network_security_rule" "this" {
  name                        = "Allow-RDP"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.this.name
}

# Create a network interface
resource "azurerm_network_interface" "this" {
  name                = "nic-eus-${random_string.random_key_gen.result}"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "nic-config-eus-${random_string.random_key_gen.result}"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.this.id
  }
}

# Create a Windows virtual machine
resource "azurerm_virtual_machine" "this" {
  name                  = "vm-eus-win-${random_string.random_key_gen.result}"
  location              = var.location
  resource_group_name   = var.rg_name
  # network_interface_ids = [azurerm_network_interface.kt_bu_resource.id]
  network_interface_ids = [azurerm_network_interface.this.id]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "win-os-disk-${random_string.random_key_gen.result}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "vm-eus-win-shir"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd1234!"
  }

  # os_profile_linux_config {
  #   disable_password_authentication = false
  # }
  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent        = true
  }
}

resource "azurerm_virtual_machine_extension" "shir-cs" {
  name = "vm-shir-script"
  virtual_machine_id = azurerm_virtual_machine.this.id
  publisher = "Microsoft.Compute"
  type = "CustomScriptExtension"
  type_handler_version = "1.9"
  # settings = <<SETTINGS
  # {
  #   "fileUris": ["${var.copy_script_url}${var.sas_token}&sr=b"],
	#   "commandToExecute": "powershell -executionPolicy bypass -file gatewayInstall.ps1 ${var.primary_authorization_key}"
  # }
  # SETTINGS
  settings = <<SETTINGS
  {
    "fileUris": ["https://raw.githubusercontent.com/Azure/azure-quickstart-templates/00b79d2102c88b56502a63041936ef4dd62cf725/101-vms-with-selfhost-integration-runtime/gatewayInstall.ps1"],
	  "commandToExecute": "powershell -executionPolicy bypass -file gatewayInstall.ps1 ${var.primary_authorization_key}"
  }
  SETTINGS
}