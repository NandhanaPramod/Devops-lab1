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
    nsg_name         = string
  }))
}

variable "security_rules" {
  description = "List of security rules"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}

variable "security_group" {
  description = "List of security groups"
  type = list(object({
    name = string
    rule = list(string)
  }))
}

variable "routes" {
  description = "List of routes"
  type = list(object({
    name_prefix            = string
    name_postfix           = list(string)
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = string
  }))
  default = []
}

variable "ddos_name" {
  description = "Name of the DDoS protection plan"
  type        = string
  default     = null
}

variable "ddos_resource_group" {
  description = "Resource group name for DDoS protection plan"
  type        = string
  default     = null
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

variable "backwards_compatible" {
  description = "Whether to use backwards compatible naming convention for monitor resource group"
  type        = bool
  default     = false
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "key_vault_name" {
  description = "Name of the existing key vault"
  type        = string
  default     = null
}

variable "key_vault_resource_group" {
  description = "Resource group name of the existing key vault"
  type        = string
  default     = null
}

variable "hub_subscription_id" {
  description = "Subscription ID for the hub environment"
  type        = string
  default     = null
} 