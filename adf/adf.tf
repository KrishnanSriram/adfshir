resource "azurerm_data_factory" "this" {
  name = var.adf_name
  location = var.location
  resource_group_name = var.rg_name
}