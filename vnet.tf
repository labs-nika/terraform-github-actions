#virtual network variables
variable "region" {
  type = string
  default = "northeurope"
}

variable "ip-prefix" {
  type = string
  default = "10.67"
}
#end virtual network variables

resource "azurerm_resource_group" "rg" {
  name     = "rg6"
  location = var.region
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.region}"
  address_space       = ["${var.ip-prefix}.0.0/17"]
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "gatewaysubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.ip-prefix}.0.0/26"]
}

resource "azurerm_subnet" "azurebastionsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.ip-prefix}.0.64/26"]
}

resource "azurerm_subnet" "azurefirewallsubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.ip-prefix}.0.128/26"]
}

resource "azurerm_subnet" "routeserversubnet" {
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.ip-prefix}.0.192/26"]
}

resource "azurerm_subnet" "default" {
  name                 = "Default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.ip-prefix}.1.0/24"]
}

resource "azurerm_subnet" "redissubnet" {
  name                 = "RedisSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.ip-prefix}.2.0/24"]
}

resource "azurerm_subnet" "mysqlsubnet" {
  name                 = "MySQLSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.ip-prefix}.3.0/24"]
}

resource "azurerm_subnet" "kafkaSubnet" {
  name                 = "KafkaSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.ip-prefix}.4.0/24"]
}

resource "azurerm_subnet" "privatelinksubnet" {
  name                 = "PrivateLinkSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.ip-prefix}.5.0/24"]
}

resource "azurerm_subnet" "aksnodesubnet" {
  name                 = "AKSNodeSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.ip-prefix}.6.0/24"]
}

resource "azurerm_subnet" "akspodsubnet" {
  name                 = "AKSPodSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.ip-prefix}.16.0/20"]
}

resource "azurerm_subnet" "agicsubnet" {
  name                 = "AGICSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.ip-prefix}.100.0/24"]
}
