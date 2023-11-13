resource "azurerm_data_factory_integration_runtime_self_hosted" "this" {
  name = var.adf_shir_name
  data_factory_id = var.adf_id
}

