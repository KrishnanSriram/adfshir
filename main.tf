module "rg" {
  source = "./resourcegroup"
  rg_name = var.rg_name
  location = var.location
}

module "storageaccount" {
  source = "./storageaccount"
  sa_name = "saeusadfshir"
  rg_name = module.rg.rg_name
  location = module.rg.location
  depends_on = [ module.rg ]
}

module "keyvault" {
  source = "./keyvault"
  vault_name = "adfshir"
  location = module.rg.location
  rg_name = module.rg.rg_name
  depends_on = [ module.rg ]
}

module "adf" {
  source = "./adf"
  location = module.rg.location
  adf_name = "adf-shirtest"
  rg_name = module.rg.rg_name
  depends_on = [ module.rg, module.storageaccount, module.keyvault ]
}

module "adf-shir" {
  source = "./adfshir"
  adf_shir_name = "selfhostedwithsa"
  adf_id = module.adf.adf_instance_id
}

module "vm" {
  source = "./winvm"
  location = module.rg.location
  rg_name = module.rg.rg_name
  sas_token = module.storageaccount.sas_token
  copy_script_url = module.storageaccount.copy_script_url
  primary_authorization_key = module.adf-shir.primary_authorization_key
  depends_on = [ module.rg, module.storageaccount, module.adf, module.adf-shir ]
}