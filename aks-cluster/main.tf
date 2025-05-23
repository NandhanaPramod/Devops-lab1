# Locals for resource mappings
locals {
  # Resource group name logic
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : var.resource_group_name

  # Location for all resources
  location = var.location

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
}

# Data source for spoke VNet
data "azurerm_virtual_network" "spoke_vnet" {
  name                = var.spoke_vnet_name
  resource_group_name = var.spoke_vnet_resource_group
}

# Data source for spoke subnet
data "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  resource_group_name  = var.spoke_vnet_resource_group
  virtual_network_name = data.azurerm_virtual_network.spoke_vnet.name
}

# Network Security Group
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.basename}-${var.environment}-aks-nsg"
  location            = local.location
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

# Security Rules
resource "azurerm_network_security_rule" "aks_rules" {
  for_each = { for rule in var.security_rules : rule.name => rule }

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
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.basename}-${var.environment}-law"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.tags
}

# User Assigned Identity for AKS
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "${var.basename}-${var.environment}-aks-identity"
  resource_group_name = local.resource_group_name
  location            = local.location
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.basename}-${var.environment}-aks"
  location            = local.location
  resource_group_name = local.resource_group_name
  dns_prefix          = "${var.basename}-${var.environment}-aks"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.vm_size
    vnet_subnet_id  = data.azurerm_subnet.aks_subnet.id
    max_pods        = var.max_pods
    min_count       = var.min_count
    max_count       = var.max_count
  }

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
    pod_cidr          = var.docker_bridge_cidr
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  tags = local.tags
}

# Role Assignment for AKS Identity
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = data.azurerm_subnet.aks_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
} 