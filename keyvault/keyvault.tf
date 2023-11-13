resource "random_string" "random_key_gen" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

data "azurerm_client_config" "current" {}

locals {
  current_user_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault" "vault" {
  name                       = "kv-${var.vault_name}-${random_string.random_key_gen.result}"
  location                   = var.location
  resource_group_name        = var.rg_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = local.current_user_id
    key_permissions    = var.key_permissions
    secret_permissions = var.secret_permissions
  }
}

# If you wish to generate a random key
# resource "random_string" "azurerm_key_vault_key_name" {
#   length  = 13
#   lower   = true
#   numeric = false
#   special = false
#   upper   = false
# }

# resource "azurerm_key_vault_key" "key" {
#   name = coalesce(var.key_name, "key-${random_string.azurerm_key_vault_key_name.result}")

#   key_vault_id = azurerm_key_vault.vault.id
#   key_type     = var.key_type
#   key_size     = var.key_size
#   key_opts     = var.key_ops

#   rotation_policy {
#     automatic {
#       time_before_expiry = "P30D"
#     }

#     expire_after         = "P90D"
#     notify_before_expiry = "P29D"
#   }
# }
