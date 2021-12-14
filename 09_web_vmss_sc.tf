resource "azurerm_virtual_machine_extension" "vmss_web_vm_sc" {
  name = "vmss_web_vm_sc"
  virtual_machine_id = azurerm_virtual_machine.jumpbox.id
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
  {
      "script": "${filebase64("websh.sh")}"
  }
  SETTINGS
}
#sh