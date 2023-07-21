terraform {
  required_version = ">= 0.14.0, < 0.16.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_virtual_network" "existing" {
  name                = "<VIRTUAL_NETWORK_NAME>"
  resource_group_name = "<RESOURCE_GROUP_NAME>"
}

data "azurerm_subnet" "existing" {
  name                 = "<SUBNET_NAME>"
  resource_group_name  = "<RESOURCE_GROUP_NAME>"
  virtual_network_name = data.azurerm_virtual_network.existing.name
}

resource "azurerm_resource_group" "example" {
  name     = "IB-ProxyCheck-resources-functionapp"
  location = "Germany West Central"
}

resource "azurerm_storage_account" "example" {
  name                     = "ibproxycheckstorageaccountfunc"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "example" {
  name                = "IB-ProxyCheck-service-plan-functionapp"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "FunctionApp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_application_insights" "example" {
  name                = "IB-ProxyCheck-app-insights-functionapp"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
}

resource "azurerm_function_app" "example" {
  name                      = "IB-ProxyCheck-functionapp-gitapi"
  location                  = azurerm_resource_group.example.location
  resource_group_name       = azurerm_resource_group.example.name
  app_service_plan_id       = azurerm_app_service_plan.example.id
  storage_account_name      = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  version                   = "~3"
  vnet_subnet_id            = data.azurerm_subnet.existing.id

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.example.instrumentation_key
    FUNCTIONS_WORKER_RUNTIME       = "python"
  }
}