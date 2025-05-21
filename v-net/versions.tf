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
  subscription_id = "e6d58439-99c2-4486-b84d-23ba28c2ce4e"
}

provider "azurerm" {
  alias           = "hub"
  features {}
  subscription_id = var.hub_subscription_id
} 