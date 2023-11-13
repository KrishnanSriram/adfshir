output "sa_name" {
  value = azurerm_storage_account.this.name
}

output "sa_script_container" {
  value = azurerm_storage_container.script_container.name
}

output "copy_script_url" {
  value = azurerm_storage_blob.copy_script.url
}

output "sas_token" {
  value = data.azurerm_storage_account_sas.sas_token.sas
}