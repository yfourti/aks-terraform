terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.93.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Import the Azure Resource Group
resource "azurerm_resource_group" "k8s" {
  name     = "1-e58bc4e2-playground-sandbox"
  location =  "West US"
}