terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.89.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vmss" {
  name     = var.resource_group_name # (1)
  location = var.location            # (2)
  tags     = var.tags                # 1(3)
}

resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  number  = false
}