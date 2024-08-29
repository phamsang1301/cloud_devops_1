# resource "azurerm_linux_virtual_machine" "uda_vm" {
#   name                = "uda-vm"
#   resource_group_name = data.azurerm_resource_group.udacity_rg.name
#   location            = data.azurerm_resource_group.udacity_rg.location
#   size                = "Standard_F2"
#   admin_username      = "adminuser"
#   network_interface_ids = [
#     azurerm_network_interface.uda_nic.id,
#   ]

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

# #   source_image_reference {
# #     publisher = "Canonical"
# #     offer     = "0001-com-ubuntu-server-jammy"
# #     sku       = "22_04-lts"
# #     version   = "latest"
# #   }
#   source_image_id = "/subscriptions/b0882eda-bd5f-4992-98d9-8ea4727eeb53/resourceGroups/udacity/providers/Microsoft.Compute/images/idacityImage"
#   tags = var.tags
# }

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
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

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