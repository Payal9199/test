data "azurerm_client_config" "current" {}

# data "azurerm_private_dns_zone" "keyvault_dns_zeus_dev" {
#     name = "privatelink.vaultcore.azure.net"
#     resource_group_name = "rg-privatezone"
#     provider = azurerm.spark-network
# }

# #fetch the postgre private DNS zone from Spark Network Network
# data "azurerm_private_dns_zone" "postgres_private_dns_zeus_test" {
#   name                = "privatelink.postgres.database.azure.com"
#   resource_group_name = "rg-privatezone" # Change as per actual RG name
#   provider            = azurerm.spark-network
# }