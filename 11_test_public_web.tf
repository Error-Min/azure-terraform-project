resource "azurerm_public_ip" "wlb" {
  name                = "vmss-public-ip"
  location            = azurerm_resource_group.vmss.location
  resource_group_name = azurerm_resource_group.vmss.name
  allocation_method   = "Static" #정적 할당
  domain_name_label   = random_string.fqdn.result
  tags                = var.tags
}

resource "azurerm_lb" "vmss" {
  name                = "vmss-lb"
  location            = var.location # (2)
  resource_group_name = azurerm_resource_group.vmss.name

  frontend_ip_configuration {
    name                 = "webPublicIP"
    public_ip_address_id = azurerm_public_ip.wlb.id
  }
  tags = var.lbtags
}

resource "azurerm_lb_backend_address_pool" "bpepool" { # 로벨 백엔드 풀
  loadbalancer_id = azurerm_lb.vmss.id
  name            = "sm-web-bend"
}

resource "azurerm_lb_probe" "vmss" { # 로벨 프로브s
  resource_group_name = azurerm_resource_group.vmss.name
  loadbalancer_id     = azurerm_lb.vmss.id
  name                = "ssh-running-probe"
  port                = 80 # (4) 80번 포트 외부
}

resource "azurerm_lb_rule" "lbnatrule" { # 부하분산 규칙 추가
  resource_group_name            = azurerm_resource_group.vmss.name
  loadbalancer_id                = azurerm_lb.vmss.id # NAT 규칙을 생성할 LoadBalancer의 ID
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = 80                                         # (4) 80번 포트 외부
  backend_port                   = 80                                         # (4) 80번 포트 외부
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id #백엔드 풀 추가
  frontend_ip_configuration_name = "webPublicIP"                                 # 규칙이 연결된 프런트엔드 IP 구성의 이름
  probe_id                       = azurerm_lb_probe.vmss.id                   #상태 프로브 추가
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = "sm-wab-vmss"
  location                        = var.location # (2)
  resource_group_name             = azurerm_resource_group.vmss.name
  sku                             = "Standard_DS1_v2" # 머신 디스크 크기 선택 및 vmss 개수 지정 
  instances                       = 2                 # vmss 가상머신 개수.
  admin_username                  = "sangmin030"
  admin_password                  = "!Rlflqhdl21"
  disable_password_authentication = false
  custom_data                     = base64encode("websh.sh")


  source_image_reference {
    # VM OS 설정및 변경
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  data_disk {
    lun     = 0
    caching = "ReadWrite"
    #create_option = "Empty"
    disk_size_gb         = 10
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.vmss.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      primary                                = true
    }
  }

  extension {
    name                       = "CustomScript"
    publisher                  = "Microsoft.Azure.Extensions"
    type                       = "CustomScript"
    type_handler_version       = "2.0"
    auto_upgrade_minor_version = true

    settings = <<SETTINGS
  {
      "script": "${filebase64("websh.sh")}"
  }
  SETTINGS
  }
}
