# Variables for spoke VNet peering
variable "spoke_vnet_id" {
  description = "Resource ID of the spoke VNet to peer with"
  type        = string
}

variable "spoke_vnet_name" {
  description = "Name of the spoke VNet to peer with"
  type        = string
}

variable "spoke_resource_group_name" {
  description = "Resource group name of the spoke VNet"
  type        = string
}

# Hub to Spoke Peering
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "${var.basename}-${var.environment}-to-${var.spoke_vnet_name}-peering"
  resource_group_name          = local.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = var.spoke_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Spoke to Hub Peering (This will be created in the spoke VNet configuration)
output "hub_vnet_id" {
  description = "Resource ID of the hub VNet"
  value       = azurerm_virtual_network.vnet.id
}

output "hub_vnet_name" {
  description = "Name of the hub VNet"
  value       = azurerm_virtual_network.vnet.name
}

output "hub_resource_group_name" {
  description = "Resource group name of the hub VNet"
  value       = local.resource_group_name
} 