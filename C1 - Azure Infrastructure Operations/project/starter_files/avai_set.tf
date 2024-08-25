resource "azurerm_availability_set" "uda_avaiset" {
  name                = "uda-aset"
  location            = data.azurerm_resource_group.udacity_rg.location
  resource_group_name = data.azurerm_resource_group.udacity_rg.name
  platform_update_domain_count  = 1
  platform_fault_domain_count =  1
  tags = var.tags
}

