terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.0.1"
    }
    
  }
}

provider "azurerm" {
  # Configuration options
    features {}
    subscription_id = "b0882eda-bd5f-4992-98d9-8ea4727eeb53"
}
data "azurerm_resource_group" "udacity_rg" {
  name = "udacity"
}
resource "azurerm_availability_set" "uda_avaiset" {
  name                = "uda-aset"
  location            = data.azurerm_resource_group.udacity_rg.location
  resource_group_name = data.azurerm_resource_group.udacity_rg.name
  platform_update_domain_count  = 1
  platform_fault_domain_count =  1
  tags = var.tags
}

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
  count = var.number_vms
  name                = "uda-nic${count.index}"
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

resource "azurerm_managed_disk" "uda_disk" {
  count = var.number_vms
  name                 = "acctestmd-${count.index}"
  location             = data.azurerm_resource_group.udacity_rg.location
  resource_group_name  = data.azurerm_resource_group.udacity_rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "50"

  tags = var.tags
}

resource "azurerm_virtual_machine" "uda_vm" {
  count = var.number_vms
  name                  = "uda-vm-${count.index}"
  location              = data.azurerm_resource_group.udacity_rg.location
  resource_group_name   = data.azurerm_resource_group.udacity_rg.name
  network_interface_ids = [azurerm_network_interface.uda_nic[count.index].id]
  vm_size               = "Standard_DS1_v2"
  availability_set_id = azurerm_availability_set.uda_avaiset.id
  delete_os_disk_on_termination = true

  storage_image_reference {
    id = "/subscriptions/b0882eda-bd5f-4992-98d9-8ea4727eeb53/resourceGroups/udacity/providers/Microsoft.Compute/images/idacityImage"
  }
  storage_os_disk {
    name              = "myosdisk1${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  storage_data_disk {
    create_option = "Attach"
    name =  azurerm_managed_disk.uda_disk[count.index].name
    lun = 1
    managed_disk_id = azurerm_managed_disk.uda_disk[count.index].id
    disk_size_gb = 50
  }
  os_profile {
    computer_name  = "hostname${count.index}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = var.tags
}