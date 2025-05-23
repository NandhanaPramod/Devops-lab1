# Locals for resource mappings
locals {
  # Resource group name logic
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : var.resource_group_name

  # Location for all resources
  location = var.location

  # Log Analytics Workspace name
  log_analytics_workspace_name = "${var.basename}-${terraform.workspace}-la-workspace"

  # Common tags for all resources
  tags = merge(
    var.default_tags,
    {
      Environment  = upper(var.environment)
      Location     = lower(var.location)
      ServiceClass = terraform.workspace == "prod" ? terraform.workspace : "non-prod"
    }
  )
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = "${var.basename}-${var.environment}-rg"
  location = local.location
  tags     = local.tags
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.basename}-${var.environment}-vnet"
  resource_group_name = local.resource_group_name
  location            = local.location
  address_space       = var.vnet_cidr
  tags                = local.tags

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.this.id
    enable = true
  }
}

# Subnets
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = lookup(each.value, "service_endpoints", [])

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", null) != null ? [1] : []
    content {
      name = lookup(each.value.delegation, "name", null)
      service_delegation {
        name    = lookup(each.value.delegation.service_delegation, "name", null)
        actions = lookup(each.value.delegation.service_delegation, "actions", null)
      }
    }
  }
}

# Azure Bastion
resource "azurerm_public_ip" "bastion" {
  name                = "${var.basename}-${var.environment}-bastion-pip"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  sku                = "Standard"
  tags               = local.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${var.basename}-${var.environment}-bastion"
  resource_group_name = local.resource_group_name
  location            = local.location
  tags                = local.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnets["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

# Azure Firewall
resource "azurerm_public_ip" "firewall" {
  name                = "${var.basename}-${var.environment}-firewall-pip"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  sku                = "Standard"
  tags                = local.tags
}

resource "azurerm_firewall" "firewall" {
  name                = "${var.basename}-${var.environment}-firewall"
  resource_group_name = local.resource_group_name
  location            = local.location
  tags                = local.tags
  sku_name           = "AZFW_VNet"
  sku_tier           = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnets["AzureFirewallSubnet"].id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

# ExpressRoute Circuit
resource "azurerm_express_route_circuit" "expressroute" {
  name                  = "${var.basename}-${var.environment}-expressroute"
  resource_group_name   = local.resource_group_name
  location              = local.location
  service_provider_name = var.expressroute_provider
  peering_location      = var.expressroute_peering_location
  bandwidth_in_mbps     = var.expressroute_bandwidth
  tags                  = local.tags

  sku {
    tier   = var.expressroute_sku_tier
    family = var.expressroute_sku_family
  }
}

# ExpressRoute Gateway
resource "azurerm_public_ip" "gateway" {
  name                = "${var.basename}-${var.environment}-gateway-pip"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  sku                = "Standard"
  tags                = local.tags
}

resource "azurerm_virtual_network_gateway" "gateway" {
  name                = "${var.basename}-${var.environment}-gateway"
  resource_group_name = local.resource_group_name
  location            = local.location
  tags                = local.tags

  type     = "ExpressRoute"
  vpn_type = "RouteBased"
  sku      = var.gateway_sku

  ip_configuration {
    name                          = "default"
    subnet_id                     = azurerm_subnet.subnets["GatewaySubnet"].id
    public_ip_address_id          = azurerm_public_ip.gateway.id
    private_ip_address_allocation = "Dynamic"
  }
}

# DDoS Protection Plan
resource "azurerm_network_ddos_protection_plan" "this" {
  name                = "${var.basename}-${var.environment}-ddos"
  resource_group_name = local.resource_group_name
  location            = local.location
  tags                = local.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "this" {
  name                = local.log_analytics_workspace_name
  resource_group_name = local.resource_group_name
  location            = local.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
} 