module "postgresql_flexible_server" {
  source  = "Azure/avm-res-dbforpostgresql-flexibleserver/azurerm"
  version = "0.1.4"

  location            = var.location
  name                = var.postgresql.name
  resource_group_name = var.resource_group_name
  delegated_subnet_id = azurerm_subnet.psql.id

  server_version = var.postgresql.server_version
  sku_name       = var.postgresql.sku_name

  storage_mb                    = var.postgresql.storage_mb
  storage_tier                  = var.postgresql.storage_tier
  backup_retention_days         = var.postgresql.backup_retention_days
  geo_redundant_backup_enabled  = var.postgresql.geo_redundant_backup_enabled
  zone                          = var.postgresql.zone
  public_network_access_enabled = var.postgresql.public_network_access_enabled

  #Authentication
  administrator_login    = var.postgresql.administrator_login
  administrator_password = azurerm_key_vault_secret.postgres_user_password_kv.value

  private_dns_zone_id                     = azurerm_private_dns_zone.postgresql_pdz.id
  private_endpoints_manage_dns_zone_group = var.postgresql.private_endpoints_manage_dns_zone_group

  high_availability = var.postgresql.high_availability

  #Entra ID Authentication Configuration
  authentication = {
    active_directory_auth_enabled = var.postgresql.authentication.active_directory_auth_enabled #This enables Entra ID
    password_auth_enabled         = var.postgresql.authentication.password_auth_enabled         #Keep PostgreSQL auth also
    # tenant_id = var.tenant_id
  }
# private_endpoints = {
#     kv_private_endpoint = {
#         name = "pep-psql"
#         subnet_resource_id = azurerm_subnet.pep.id
#         private_dns_zone_resource_ids = [azurerm_private_dns_zone.postgresql_pdz.id]
#     }
# }
  #  databases = var.postgresql_databases
  enable_telemetry = var.enable_telemetry
  # ad_administrator = var.postgresql_ad_administrator
  # tags                   = local.tags
  #   depends_on = [ module.networking ]
}

# resource "time_rotating" "postgres_password_rotation" {
#   rotation_days = 365
# }

resource "random_password" "postgres_user_password" {
  length           = 22
  override_special = "_%@"
  special          = true
  upper            = true
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  min_upper        = 2

  # keepers = {
  #   rotation = time_rotating.password_rotation.id
  # }
}

resource "azurerm_key_vault_secret" "postgres_user_password_kv" {
  name            = "postgres-admin-password"
  key_vault_id    = module.keyvault.resource_id
  value           = random_password.postgres_user_password.result
  content_type    = "test/plain"
  expiration_date = null
  not_before_date = null
  # tags            = var.tags

  depends_on = [random_password.postgres_user_password]

}

resource "azurerm_private_dns_zone" "postgresql_pdz" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_resource_group.zeus_rg]
}

# Enable Microsoft Defender for Postgresql
# resource "azurerm_security_center_subscription_pricing" "postgresql_defender" {
#   tier          = "Standard"
#   resource_type = "SqlServers"  # Defender treats PostgreSQL under SQL servers category
# }

# # private_dns_zone_id    = data.azurerm_private_dns_zone.postgres_private_dns_zeus_test.id

# # resource "azurerm_role_assignment" "dns_zone_reader" {
# #   scope                = data.azurerm_private_dns_zone.postgresql_shared.id
# #   role_definition_name = "Reader"
# #   principal_id         = var.your_object_id
# # }


#Manually assign Entra Admin Using azure CLI (AAD Admin)
# resource "azurerm_postgresql_active_directory_administrator" "db_admin_roles" {
#   for_each             = var.ad_administrator

#   server_name          = module.postgresql_flexible_server.name
#   resource_group_name  = var.resource_group_name
#   tenant_id            = each.value.tenant_id
#   object_id            = each.value.object_id
#   login                = each.value.login  # Required

#   depends_on = [ module.postgresql_flexible_server ]
# }


# resource "azurerm_postgresql_active_directory_administrator" "db_admin_roles" {
#   for_each             = var.ad_administrator

#   server_name          = module.postgresql_flexible_server.name
#   resource_group_name  = var.resource_group_name
#   tenant_id            = each.value.tenant_id
#   object_id            = each.value.object_id
#   login                = each.value.login  # Required

#   depends_on = [ module.postgresql_flexible_server ]
# }
