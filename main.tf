terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.8"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }

  backend "azurerm" {
    resource_group_name  = "Nothing"
    storage_account_name = "tfstatebala2026"
    container_name       = "tfstate"
    key                  = "workstation.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_public_ip" "workstation" {
  name                = "workstation-public-ip"
  location            = "Denmark East"
  resource_group_name = "Nothing"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "null_resource" "ip_manage" {
  depends_on = [azurerm_public_ip.workstation]

  provisioner "local-exec" {
    command = "az network nic ip-config update --resource-group Nothing --nic-name workstation626 --name ipconfig1 --public-ip-address workstation-public-ip"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "az network nic ip-config update --resource-group Nothing --nic-name workstation626 --name ipconfig1 --public-ip-address null"
  }
}

resource "null_resource" "vm_manage" {
  depends_on = [null_resource.ip_manage]

  provisioner "local-exec" {
    command = "az vm start --resource-group Nothing --name workstation"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "az vm deallocate --resource-group Nothing --name workstation"
  }
}

data "azurerm_subnet" "default" {
  name                 = "default"
  virtual_network_name = "Not"
  resource_group_name  = "Nothing"
}

resource "azurerm_public_ip" "natgw" {
  name                = "natgw-public-ip"
  location            = "Denmark East"
  resource_group_name = "Nothing"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "main" {
  name                    = "workstation-natgw"
  location                = "Denmark East"
  resource_group_name     = "Nothing"
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.natgw.id
}

resource "azurerm_subnet_nat_gateway_association" "main" {
  subnet_id      = data.azurerm_subnet.default.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

output "ip" {
  value = azurerm_public_ip.workstation.ip_address
}