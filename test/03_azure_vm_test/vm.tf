
resource "azurerm_public_ip" "prod_pip" {
  name                = "pip-OPENVPN"
  location            = data.terraform_remote_state.rg.outputs.resource_groups["prod-rg"].location
  #                     ↑ Reading from RG remote state
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_groups["prod-rg"].name
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_network_security_group" "prod_nsg" {
  name                = "nsg-OPENVPN"
  location            = data.terraform_remote_state.rg.outputs.resource_groups["prod-rg"].location
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_groups["prod-rg"].name


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

  # Dynamic rules from tfvars
  dynamic "security_rule" {
    for_each = var.vms["OPENVPN-SERVER"].additional_inbound_rules
   
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

resource "azurerm_network_interface" "prod_nic" {
  name                = "nic-OPENVPN"
  location            = data.terraform_remote_state.rg.outputs.resource_groups["prod-rg"].location
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_groups["prod-rg"].name

  ip_configuration {
    name      = "internal"
    
  
    subnet_id = data.terraform_remote_state.network.outputs.subnet_ids[var.vms["OPENVPN-SERVER"].subnet_key]
  
    
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.prod_pip.id
  }
}


resource "azurerm_network_interface_security_group_association" "prod_assoc" {
  network_interface_id      = azurerm_network_interface.prod_nic.id
  network_security_group_id = azurerm_network_security_group.prod_nsg.id
}


resource "azurerm_linux_virtual_machine" "prod_vm" {
  name                = "OPENVPN-SERVER"
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_groups["prod-rg"].name
  location            = data.terraform_remote_state.rg.outputs.resource_groups["prod-rg"].location
  size                = var.vms["OPENVPN-SERVER"].size          
  admin_username      = var.vms["OPENVPN-SERVER"].admin_username 

  network_interface_ids = [
    azurerm_network_interface.prod_nic.id,
  ]

  admin_ssh_key {
    username   = var.vms["OPENVPN-SERVER"].admin_username
    public_key = file("${pathexpand("~")}/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}