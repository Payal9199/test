output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

# data "azurerm_storage_account" "private_account" {
#   name                = module.storage_account_private.name
#   resource_group_name = module.storage_account_private.resource_group_name
# }

# data "azurerm_storage_account_keys" "private_account_keys" {
#   name                = data.azurerm_storage_account.private_account.name
#   resource_group_name = data.azurerm_storage_account.private_account.resource_group_name
# }