resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-es-zeus"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.10.0.0/16"]

  depends_on = [azurerm_resource_group.zeus_rg]
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]
  delegation {
    name = "delegation-app"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "psql" {
  name                 = "psql-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.3.0/24"]
  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]
  delegation {
    name = "delegation-psql"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "pep" {
  name                 = "pep-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.4.0/24"]
  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]
}

resource "azurerm_subnet" "agw" {
  name                 = "agw-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.5.0/24"]
  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]
}
