# Variables for hub VNet peering
variable "hub_vnet_id" {
  description = "Resource ID of the hub VNet to peer with"
  type        = string
}

variable "hub_vnet_name" {
  description = "Name of the hub VNet to peer with"
  type        = string
}

variable "hub_resource_group_name" {
  description = "Resource group name of the hub VNet"
  type        = string
}

# Spoke to Hub Peering
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "${var.basename}-${var.environment}-to-${var.hub_vnet_name}-peering"
  resource_group_name          = local.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Outputs for hub VNet peering
output "spoke_vnet_id" {
  description = "Resource ID of the spoke VNet"
  value       = azurerm_virtual_network.vnet.id
}

output "spoke_vnet_name" {
  description = "Name of the spoke VNet"
  value       = azurerm_virtual_network.vnet.name
}

output "spoke_resource_group_name" {
  description = "Resource group name of the spoke VNet"
  value       = local.resource_group_name
} 