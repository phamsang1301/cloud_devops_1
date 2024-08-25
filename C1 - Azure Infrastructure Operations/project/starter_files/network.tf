resource "azurerm_network_security_group" "uda_nsg" {
  name                = "uda-security-group-01"
  location            = data.azurerm_resource_group.udacity_rg.location
  resource_group_name = data.azurerm_resource_group.udacity_rg.name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "uda_rule_1" {
  name                        = "uda_outbound_rule"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.udacity_rg.name
  network_security_group_name = azurerm_network_security_group.uda_nsg.name
}

resource "azurerm_network_security_rule" "uda_rule_2" {
  name                        = "uda_inbound_rule"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.udacity_rg.name
  network_security_group_name = azurerm_network_security_group.uda_nsg.name
}

resource "azurerm_virtual_network" "udacity_vnet" {
  name                = "udacity-vnet"
  location            = data.azurerm_resource_group.udacity_rg.location
  resource_group_name = data.azurerm_resource_group.udacity_rg.name
  address_space       = ["10.0.0.0/16"]
  #   dns_servers         = ["10.0.0.4", "10.0.0.5"]

  #   subnet {
  #     name           = "uda-subnet-02"
  #     address_prefix = "10.0.1.0/24"
  #   }

  #   subnet {
  #     name           = "uda-subnet-02"
  #     address_prefix = "10.0.2.0/24"
  #     security_group = azurerm_network_security_group.uda_nsg.id
  #   }

  tags = {
    environment = "Production"
    Project     = "Udacity"
  }
}

resource "azurerm_subnet" "uda_subnet" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.udacity_rg.name
  virtual_network_name = azurerm_virtual_network.udacity_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

}

resource "azurerm_network_interface" "uda_nic" {
  name                = "uda-nic"
  location            = data.azurerm_resource_group.udacity_rg.location
  resource_group_name = data.azurerm_resource_group.udacity_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.uda_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

resource "azurerm_public_ip" "uda_pub_ip" {
  name                = "uda-pub-ip"
  resource_group_name = data.azurerm_resource_group.udacity_rg.name
  location            = data.azurerm_resource_group.udacity_rg.location
  allocation_method   = "Static"

  tags = var.tags
}
resource "azurerm_lb" "uda_lb" {
  name                = "uda-lb"
  resource_group_name = data.azurerm_resource_group.udacity_rg.name
  location            = data.azurerm_resource_group.udacity_rg.location

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.uda_pub_ip.id
  }
  tags = var.tags

}
resource "azurerm_lb_backend_address_pool" "uda_backend_address_pool" {
  loadbalancer_id = azurerm_lb.uda_lb.id
  name            = "BackEndAddressPool"
}
# resource "azurerm_lb_backend_address_pool_address" "uda_backend_address_pool_add" {
#   name                                = "address1"
#   backend_address_pool_id             = azurerm_lb_backend_address_pool.uda_backend_address_pool.id
#   backend_address_ip_configuration_id = azurerm_lb.uda_lb.frontend_ip_configuration[0].id
# }


resource "azurerm_lb_backend_address_pool_address" "uda_backend_address_pool_add" {
  name                    = "uda_backend_address_pool_add"
  backend_address_pool_id = azurerm_lb_backend_address_pool.uda_backend_address_pool.id
  virtual_network_id      = azurerm_virtual_network.udacity_vnet.id
  ip_address              = "10.0.0.1"
}