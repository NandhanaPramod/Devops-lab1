# Common Variables
variable "basename" {
  description = "Base name for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "create_resource_group" {
  description = "Whether to create a new resource group"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Network Variables
variable "vnet_cidr" {
  description = "CIDR block for the virtual network"
  type        = string
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    name             = string
    address_prefixes = list(string)
    nsg_name         = string
  }))
}

variable "security_group" {
  description = "List of network security group configurations"
  type = list(object({
    name = string
  }))
}

variable "security_rules" {
  description = "List of security rules for NSGs"
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

# Monitoring Variables
variable "alert_email" {
  description = "Email address for alert notifications"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "alert_severity" {
  description = "Severity level for alerts (0-4)"
  type        = number
  default     = 1
}

variable "cpu_threshold" {
  description = "CPU usage threshold for AKS node alerts"
  type        = number
  default     = 80
}

# AKS Variables
variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.27.7"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Size of the VM for the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "enable_auto_scaling" {
  description = "Whether to enable auto scaling for the default node pool"
  type        = bool
  default     = true
}

variable "min_count" {
  description = "Minimum number of nodes for auto scaling"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum number of nodes for auto scaling"
  type        = number
  default     = 3
}

variable "max_pods" {
  description = "Maximum number of pods per node"
  type        = number
  default     = 110
}

variable "service_cidr" {
  description = "CIDR block for Kubernetes services"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address for Kubernetes DNS service"
  type        = string
  default     = "10.0.0.10"
}

variable "docker_bridge_cidr" {
  description = "CIDR block for Docker bridge"
  type        = string
  default     = "172.17.0.1/16"
}

variable "subscription_id" {
  description = "The subscription ID to use for Azure resources"
  type        = string
}

variable "spoke_vnet_name" {
  description = "Name of the spoke VNet where AKS will be deployed"
  type        = string
}

variable "spoke_vnet_resource_group" {
  description = "Resource group name of the spoke VNet"
  type        = string
}

variable "aks_subnet_name" {
  description = "Name of the subnet in spoke VNet where AKS will be deployed"
  type        = string
} 