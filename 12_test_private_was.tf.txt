resource "azurerm_lb" "was_vmss" {
  name                = "was-vmss-lb"
  location            = var.location # (2)
  resource_group_name = azurerm_resource_group.vmss.name

  frontend_ip_configuration {
    name                          = "PrivateIPAddress"
    subnet_id                     = azurerm_subnet.privatevmss.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "wasbpepool" { # 로벨 백엔드 풀
  loadbalancer_id = azurerm_lb.was_vmss.id
  name            = "WasBackEndAddressPool"
}

resource "azurerm_lb_probe" "wasvmss" { # 로벨 프로브
  resource_group_name = azurerm_resource_group.vmss.name
  loadbalancer_id     = azurerm_lb.was_vmss.id
  name                = "was-running-probe"
  port                = 8080
}

resource "azurerm_lb_rule" "waslbnatrule" { # 부하분산 규칙 추가
  resource_group_name            = azurerm_resource_group.vmss.name
  loadbalancer_id                = azurerm_lb.was_vmss.id # NAT 규칙을 생성할 LoadBalancer의 ID
  name                           = "was_ilb_rule"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port # (4) 80번 포트 외부
  backend_port                   = 8080
  backend_address_pool_id        = azurerm_lb_backend_address_pool.wasbpepool.id #백엔드 풀 추가
  frontend_ip_configuration_name = "PrivateIPAddress"                            # 규칙이 연결된 프런트엔드 IP 구성의 이름
  probe_id                       = azurerm_lb_probe.wasvmss.id                   #상태 프로브 추가
}

resource "azurerm_linux_virtual_machine_scale_set" "wasvmss" {
  name                            = "privmscaleset"
  location                        = var.location # (2)
  resource_group_name             = azurerm_resource_group.vmss.name
  sku                             = "Standard_DS1_v2" # 머신 디스크 크기 선택 및 vmss 개수 지정 
  instances                       = 2                 # vmss 가상머신 개수.
  admin_username                  = "adminuser"
  admin_password                  = "#Rlflqhdl21"
  disable_password_authentication = false
  #custom_data    = base64encode("websh.sh")

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
    lun                  = 0
    caching              = "ReadWrite"
    create_option        = "Empty"
    disk_size_gb         = 10
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.privatevmss.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.wasbpepool.id]
      primary                                = true
    }
  }

  tags = var.vmsstags
}
