variable "aks_cluster_id" {
  description = "The ID of the AKS cluster to monitor"
  type        = string
}

variable "expressroute_circuit_id" {
  description = "The ID of the ExpressRoute circuit to monitor"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "action_group_name" {
  description = "Name of the action group"
  type        = string
}

variable "action_group_short_name" {
  description = "Short name of the action group"
  type        = string
}

variable "admin_email" {
  description = "Email address for notifications"
  type        = string
} 