module "keyvault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.0"

  name                = var.key_vault.name
  enable_telemetry    = var.enable_telemetry
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id

  public_network_access_enabled = var.key_vault.public_network_access_enabled
  purge_protection_enabled      = var.key_vault.purge_protection_enabled

  sku_name                   = var.key_vault.sku_name
  soft_delete_retention_days = var.key_vault.soft_delete_retention_days

  legacy_access_policies_enabled = var.key_vault.legacy_access_policies_enabled

  network_acls = {
    bypass         = var.key_vault_network_acls.bypass
    default_action = var.key_vault_network_acls.default_action
    # ip_rules       = var.key_vault_network_acls.ip_rules
    virtual_network_subnet_ids = [
      azurerm_subnet.app.id,
      azurerm_subnet.psql.id,
      azurerm_subnet.pep.id
    ]
  }

  role_assignments = {
    #Assign the Key Vault administrator role to the Terraform service principal
    tf_sp_kv_admin = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.current.object_id
    }
    #Assign the Key Vault Secrets Officer role to the Terraform service principal
    # tf_sp_kv_secrets_user = {
    #   role_definition_id_or_name = "Key Vault Secrets User"
    #   principal_id               = data.azurerm_client_config.current.object_id
    # }
    #Assign the Key vault Reader Role to the Cloud Team AAD group
    # cloud_team_kv_reader = {
    #   role_definition_id_or_name = "Key Vault Secrets User"
    #   principal_id               = var.principal_id_kv_cloud_team
    # }
  }

  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }

  #   private_endpoints = {
  #     kv_private_endpoint = {
  #       name                            = "pep-kv-private-endpoint"
  #       subnet_resource_id              = azurerm_subnet.pep.id
  #       private_dns_zone_resource_ids   = [azurerm_private_dns_zone.kv_dns_zeus_dev.id]
  #     }
  #   }
  #    tags = var.tags
}

# resource "azurerm_private_dns_zone" "kv_dns_zeus_dev" {
#   name = "privatelink.vaultcore.azure.net"
#   resource_group_name = var.resource_group_name
# }