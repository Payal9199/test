# resource "random_password" "postgres_admin_password" {
#   length           = 16
#   special          = true
#   override_special = "_%@"
# }

# resource "azurerm_key_vault" "kv" {
#   name                        = "kv-private-example"
#   location                    = var.location
#   resource_group_name         = var.resource_group_name
#   tenant_id                   = data.azurerm_client_config.current.tenant_id
#   sku_name                    = "standard"
#   purge_protection_enabled    = true
#   soft_delete_retention_days  = 7

#   public_network_access_enabled = false
# }

# resource "azurerm_private_endpoint" "kv_pep" {
#   name                = "pep-kv"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = azurerm_subnet.pep.id

#   private_service_connection {
#     name                           = "kv-priv-conn"
#     private_connection_resource_id = azurerm_key_vault.kv.id
#     is_manual_connection           = false
#     subresource_names              = ["vault"]
#   }
# }

# resource "azurerm_private_dns_zone" "kv_dns_zeus_dev" {
#   name = "privatelink.vaultcore.azure.net"
#   resource_group_name = var.resource_group_name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "kv_dns_link" {
#   name                  = "kv-dns-link"
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.kv_dns_zeus_dev.name
#   virtual_network_id    = azurerm_virtual_network.vnet.id
# }

# # resource "azurerm_private_dns_a_record" "kv_a_record" {
# #   name                = azurerm_key_vault.kv.name
# #   zone_name           = azurerm_private_dns_zone.kv_dns.name
# #   resource_group_name = var.resource_group_name
# #   ttl                 = 300
# #   records             = [azurerm_private_endpoint.kv_pep.private_service_connection[0].private_ip_address]
# # }

# resource "azurerm_key_vault_secret" "postgres_password" {
#   name         = "postgresAdminPassword"
#   value        = random_password.postgres_admin_password.result
#   key_vault_id = azurerm_key_vault.kv.id
# }

# resource "azurerm_postgresql_flexible_server" "psql" {
#   name                   = "psql-private-example"
#   location               = var.location
#   resource_group_name    = var.resource_group_name
#   administrator_login    = "psqladmin"
#   administrator_password = random_password.postgres_admin_password.result
#   sku_name               = "GP_Standard_D2s_v3"
#   version                = "13"
#   storage_mb             = 32768
#   delegated_subnet_id    = azurerm_subnet.psql.id
#   private_dns_zone_id    = azurerm_private_dns_zone.postgres_dns.id
#   zone                   = "1"
#   public_network_access_enabled = false


#   high_availability {
#     mode                      = "SameZone"
#     standby_availability_zone = "1"
#   }

#   depends_on = [azurerm_private_dns_zone_virtual_network_link.kv_dns_link]
# }

# resource "azurerm_private_dns_zone" "postgres_dns" {
#   name                = "privatelink.postgres.database.azure.com"
#   resource_group_name = var.resource_group_name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "postgres_dns_link" {
#   name                  = "postgres-dns-link"
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.postgres_dns.name
#   virtual_network_id    = azurerm_virtual_network.vnet.id
# }

# output "postgres_password" {
#   value     = random_password.postgres_admin_password.result
#   sensitive = true
# }

# resource "azurerm_role_assignment" "kv_secret_reader" {
#   scope                = azurerm_key_vault.kv.id
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = data.azurerm_client_config.current.object_id
# }

# resource "azurerm_role_assignment" "terraform_kv_access" {
#   scope                = azurerm_key_vault.kv.id
#   role_definition_name = "Key Vault Secrets Officer" # Use "Secrets User" for read-only
#   principal_id         = data.azurerm_client_config.current.object_id
# }
