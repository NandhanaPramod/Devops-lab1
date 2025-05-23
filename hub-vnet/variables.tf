variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod, non-prod)"
  type        = string
}

variable "basename" {
  description = "Base name for all resources"
  type        = string
  default     = "hub"
}

variable "vnet_cidr" {
  description = "CIDR block for the virtual network"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    name             = string
    address_prefixes = list(string)
    service_endpoints = optional(list(string))
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
  }))
}

variable "create_resource_group" {
  description = "Whether to create a new resource group"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Name of the existing resource group (if create_resource_group is false)"
  type        = string
  default     = null
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ExpressRoute specific variables
variable "expressroute_provider" {
  description = "Name of the ExpressRoute service provider"
  type        = string
}

variable "expressroute_peering_location" {
  description = "Name of the peering location"
  type        = string
}

variable "expressroute_bandwidth" {
  description = "Bandwidth in Mbps of the ExpressRoute circuit"
  type        = number
  default     = 1000
}

variable "expressroute_sku_tier" {
  description = "The tier of the ExpressRoute circuit"
  type        = string
  default     = "Standard"
}

variable "expressroute_sku_family" {
  description = "The family of the ExpressRoute circuit"
  type        = string
  default     = "MeteredData"
}

variable "gateway_sku" {
  description = "The SKU of the Virtual Network Gateway"
  type        = string
  default     = "ErGw1AZ"
} 