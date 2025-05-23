terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "monitoring_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Action Group for notifications
resource "azurerm_monitor_action_group" "main" {
  name                = var.action_group_name
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  short_name          = var.action_group_short_name

  email_receiver {
    name                    = "admin"
    email_address          = var.admin_email
    use_common_alert_schema = true
  }
} 