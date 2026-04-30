resource "azurerm_public_ip" "pip" {
  name                = "my-pip"
  location            = data.terraform_remote_state.rg.outputs.resource_groups["my-rg"].location
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_groups["my-rg"].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = { ManagedBy = "Terraform", project = "Training1" }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "my-nsg"
  location            = data.terraform_remote_state.rg.outputs.resource_groups["my-rg"].location
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_groups["my-rg"].name
  tags                = { ManagedBy = "Terraform", project = "Training1" }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  dynamic "security_rule" {
    for_each = var.vms["MYVPN_SERVER"].additional_inbound_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = security_rule.value.protocol
      source_port_range          = "*"
      destination_port_range     = security_rule.value.port
      source_address_prefix      = security_rule.value.source
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_network_interface" "nic" {
  name                  = "my-nic"
  location              = data.terraform_remote_state.rg.outputs.resource_groups["my-rg"].location
  resource_group_name   = data.terraform_remote_state.rg.outputs.resource_groups["my-rg"].name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networking.outputs.subnet_ids[var.vms["MYVPN_SERVER"].subnet_key]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vms["MYVPN_SERVER"].name
  location            = data.terraform_remote_state.rg.outputs.resource_groups["my-rg"].location
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_groups["my-rg"].name
  size                = var.vms["MYVPN_SERVER"].size
  admin_username      = var.vms["MYVPN_SERVER"].admin_username

  network_interface_ids = [azurerm_network_interface.nic.id]

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


  admin_ssh_key {
    username   = var.vms["MYVPN_SERVER"].admin_username
    public_key = file(pathexpand("~/.ssh/azure_vm_key.pub"))
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
