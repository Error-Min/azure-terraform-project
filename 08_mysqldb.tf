resource "azurerm_mysql_server" "mysqldb" {
  name                = "errorminmydb"
  location            = azurerm_resource_group.vmss.location
  resource_group_name = azurerm_resource_group.vmss.name

  administrator_login          = "sangmin"
  administrator_login_password = "#Rlflqhdl21"

  sku_name   = "GP_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  
  
  ssl_enforcement_enabled           = false
 
}

resource "azurerm_mysql_database" "mysqldb" {
  name                = "wordpress"
  resource_group_name = azurerm_resource_group.vmss.name
  server_name         = azurerm_mysql_server.mysqldb.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}
resource "azurerm_mysql_firewall_rule" "mysql-db-firewall" {
  name                = "mysql-db-fire"
  resource_group_name = azurerm_resource_group.vmss.name
  server_name         = azurerm_mysql_server.mysqldb.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}