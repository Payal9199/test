module "psql_server" {
  source  = "Azure/avm-res-dbforpostgresql-flexibleserver/azurerm"
  version = "0.1.4"

  location            = var.location
  name                = "pslabcdefghjhgdsag"
  resource_group_name = var.resource_group_name
  delegated_subnet_id = azurerm_subnet.psql.id

  server_version = var.postgresql.server_version
  sku_name       = var.postgresql.sku_name

  storage_mb                    = var.postgresql.storage_mb
  storage_tier                  = var.postgresql.storage_tier
  backup_retention_days         = var.postgresql.backup_retention_days
  geo_redundant_backup_enabled  = var.postgresql.geo_redundant_backup_enabled
  zone                          = var.postgresql.zone
  public_network_access_enabled = true

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
private_endpoints = {
    kv_private_endpoint = {
        name = "pep-psql"
        subnet_resource_id = azurerm_subnet.pep.id
        private_dns_zone_resource_ids = [azurerm_private_dns_zone.postgresql_pdz.id]
    }
}
  #  databases = var.postgresql_databases
  enable_telemetry = var.enable_telemetry
  # ad_administrator = var.postgresql_ad_administrator
  # tags                   = local.tags
  #   depends_on = [ module.networking ]
}
