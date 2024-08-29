terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.0.1"
    }
    
  }
}

provider "azurerm" {
  # Configuration options
    features {}
    subscription_id = "b0882eda-bd5f-4992-98d9-8ea4727eeb53"
}