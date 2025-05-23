variable "create_resource_group" {
  description = "Whether to create a new resource group"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
}

variable "basename" {
  description = "Base name for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "backwards_compatible" {
  description = "Whether to use backwards compatible naming"
  type        = bool
  default     = false
}

variable "vnet_cidr" {
  description = "Address space for the VNet"
  type        = list(string)
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
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
  default = []
}

variable "security_group" {
  description = "List of security groups"
  type = list(object({
    name = string
  }))
  default = []
}

variable "subnets" {
  description = "List of subnet configurations"
  type = list(object({
    name             = string
    address_prefixes = list(string)
    nsg_name         = string
  }))
  default = []
}

variable "ddos_name" {
  description = "Name of the DDoS protection plan"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = null
}

variable "key_vault_resource_group" {
  description = "Resource group name for the Key Vault"
  type        = string
  default     = null
} 