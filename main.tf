############################
# Resource Group
############################
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

############################
# Storage Account (required for Function App)
############################
resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

############################
# Function App Plan (Consumption)
############################
resource "azurerm_service_plan" "plan" {
  name                = var.service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  os_type  = "Linux"
  sku_name = "Y1"   # Consumption Plan
}

############################
# Linux Function App (.NET Ready)
############################
resource "azurerm_linux_function_app" "func" {
  name                       = var.function_app_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.plan.id

  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key

  site_config {
    application_stack {
      dotnet_version = "8.0"       # OR 6.0 depending on your code
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME     = "dotnet"
    FUNCTIONS_EXTENSION_VERSION  = "~4"
  }
}
