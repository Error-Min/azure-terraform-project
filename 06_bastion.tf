resource "azurerm_public_ip" "vmss_bs_sub" {
  name ="hbkim_pub"
  location = azurerm_resource_group.vmss.location
  resource_group_name = azurerm_resource_group.vmss.name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_bastion_host" "vmss_bsh_host" {
  name = "hbkim_bsh_host"
  location = azurerm_resource_group.vmss.location
  resource_group_name = azurerm_resource_group.vmss.name

  ip_configuration {
    name = "AzureBastionHost"
    subnet_id = azurerm_subnet.bs_sub.id
    public_ip_address_id = azurerm_public_ip.vmss_bs_sub.id
  }
}