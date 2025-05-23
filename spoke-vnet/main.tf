# Locals for resource mappings
locals {
  # Resource group name logic
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : var.resource_group_name

  # Location for all resources
  location = var.location

  # Log Analytics Workspace name
  log_analytics_workspace_name = "${var.basename}-${terraform.workspace}-la-workspace"

  # Monitor Resource Group name
  monitor_resource_group_name = var.backwards_compatible ? "${var.basename}-${terraform.workspace}-monitor-rg" : join("_", [var.basename, terraform.workspace])

  # Common tags for all resources
  tags = merge(
    var.default_tags,
    {
      Environment  = upper(var.environment)
      Location     = lower(var.location)
      ServiceClass = terraform.workspace == "prod" ? terraform.workspace : "non-prod"
    }
  )

  # Security rules mapping
  dynarules = { for rule in var.security_rules : rule.name => rule }
  
  # Security groups mapping
  nsg_map = { for nsg in var.security_group : nsg.name => nsg }
  
  # Subnet mapping
  subnet_map = { for subnet in var.subnets : subnet.name => subnet }
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = "${var.basename}-${var.environment}-rg"
  location = local.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.basename}-${var.environment}-vnet"
  resource_group_name = local.resource_group_name
  location            = local.location
  address_space       = var.vnet_cidr

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.this.id
    enable = true
  }
}

# Network Security Groups
resource "azurerm_network_security_group" "nsg" {
  for_each = local.nsg_map

  name                = each.value.name
  resource_group_name = local.resource_group_name
  location            = local.location
}

# Security Rules
resource "azurerm_network_security_rule" "rules" {
  for_each = local.dynarules

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = local.resource_group_name
  network_security_group_name = each.value.name
}

# Subnets
resource "azurerm_subnet" "subnet" {
  for_each = local.subnet_map

  name                 = each.value.name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes
}

# Subnet NSG Associations
resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  for_each = local.subnet_map

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.nsg_name].id
}

# DDoS Protection Plan
resource "azurerm_network_ddos_protection_plan" "this" {
  name                = var.ddos_name
  resource_group_name = local.resource_group_name
  location            = local.location
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "this" {
  name                = local.log_analytics_workspace_name
  resource_group_name = local.resource_group_name
  location            = local.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Data blocks for existing resources
data "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 0 : 1
  name  = "${var.basename}_${var.environment}"
}

data "azurerm_client_config" "this" {
  # This data source provides information about the current Azure client configuration
}

data "azurerm_client_config" "hub" {
  provider = azurerm.hub
}

data "azurerm_monitor_diagnostic_categories" "vnet" {
  resource_id = azurerm_virtual_network.vnet.id
}

data "azurerm_monitor_diagnostic_categories" "nsg" {
  for_each    = local.nsg_map
  resource_id = azurerm_network_security_group.nsg[each.key].id
}

data "azurerm_subscription" "current" {
  # This data source provides information about the current subscription
}

data "azurerm_key_vault" "kv" {
  count               = var.key_vault_name != null ? 1 : 0
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group
} 