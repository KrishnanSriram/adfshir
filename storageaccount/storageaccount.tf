resource "random_string" "random_key_gen" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource azurerm_storage_account "this" {
  name                     = var.sa_name
  resource_group_name      = var.rg_name
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  public_network_access_enabled = true
}

# crearte BLOB container
resource azurerm_storage_container "script_container" {
  name                  = "shirscripts"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "blob"
  depends_on = [ azurerm_storage_account.this ]
}

resource "azurerm_storage_blob" "copy_script" {
  name = "gatewayInstall.ps1"
  storage_account_name = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.script_container.name
  type = "Block"
  source = "gatewayInstall.ps1"
  depends_on = [ azurerm_storage_container.script_container ]
  
}

data "azurerm_storage_account_sas" "sas_token" {
  connection_string = azurerm_storage_account.this.primary_connection_string
  https_only = true
  # signed_version = "2023-10-10"
  resource_types {
    service = true
    container = true
    object = true
  }
  services {
    blob = true
    queue = false
    table = false
    file = false
  }
  start = timestamp()
  expiry = timeadd(timestamp(), "5000m")
  permissions {
    read = true
    write = true
    delete = true
    list = true
    add = true
    create = true
    update = false
    process = false
    tag = true
    filter = true
  }
  depends_on = [ azurerm_storage_account.this ]
}