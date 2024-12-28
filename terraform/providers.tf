terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {

  subscription_id = "659c9195-eeff-450f-86f0-11ec1780f7bb"
  client_id       = "dfdbf619-6141-4c95-8995-86c173018340"
  client_secret    = "MYY8Q~QFnlZsO7M0anjZs5kyONFJizWZOCtLIatk"
  tenant_id       = "d3abbf87-4aaf-45e8-93ac-9eb6d1a56aa4"
  features {}

}