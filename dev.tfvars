location            = "australiaeast"
resource_group_name = "rg-es-zeus-dev"
enable_telemetry    = false
tenant_id           = "20b372e2-8424-4837-a721-9eac52a2fa45"

#----------------------------
#Key vault generalpurpose
#----------------------------
key_vault = {
  name                           = "kv-es-zeus-0812"
  public_network_access_enabled  = true
  sku_name                       = "standard"
  soft_delete_retention_days     = 30
  purge_protection_enabled       = true
  legacy_access_policies_enabled = false
}
key_vault_network_acls = {
  bypass         = "AzureServices"
  default_action = "Allow"
  # ip_rules = ["183.87.230.179/32"]
}
principal_id_kv_cloud_team = "fe2ee5aa-826e-44d4-9d19-7832bf719b7f"
################################################################################

postgresql = {
  name                = "db-es-postgresql-server"
  server_version      = "16" #Replace by 16.8
  sku_name            = "GP_Standard_D2s_v3"
  zone                = 1
  administrator_login = "psqladmin"

  backup_retention_days                   = 7
  public_network_access_enabled           = true #Deny public access
  storage_mb                              = 262144
  storage_tier                            = "P15"
  geo_redundant_backup_enabled            = false
  private_endpoints_manage_dns_zone_group = false
  high_availability = {
    mode                      = "SameZone"
    standby_availability_zone = "1"
  }
  authentication = {
    active_directory_auth_enabled = false #This enables Entra ID
    password_auth_enabled         = true  #Keep PostgreSQL auth also
  }
}
# postgresql_databases = {
#     app_db = {
#         name = ""
#     }
#     metrics_db = {
#         name = ""
#     }
# }
# postgresql_ad_administrator = {
#     anvesh = {
#         tenant_id = ""
#         object_id = ""
#         principal_name = ""
#         principal_type = ""
#     }
# }

##########################################
#Storage account public 
storage_acc_public = {
  name                             = "storaccpublicsftp004"
  account_kind                     = "BlobStorage"
  account_tier                     = "Standard"
  access_tier                      = "Hot"
  account_replication_type         = "LRS"
  is_hns_enabled                   = true
  sftp_enabled                     = true
  public_network_access_enabled    = true
  shared_access_key_enabled        = true
  allow_nested_items_to_be_public  = true
  allowed_copy_scope               = "AAD"
  cross_tenant_replication_enabled = false
}
storage_acc_public_network_rules = {
  default_action = "Deny"  #"Deny" "Allow"
  bypass         = ["AzureServices"] #["None"] - this value for test env
  ip_rules       = []
  # virtual_network_subnet_ids = []
}
storage_account_pub_containers = [
  "comp-dyan-pub-cont",
  "compenh-pub-cont",
  "dcentral-pub-cont",
  "dicker-data-pub-cont",
  "dove-pub-cont",
  "eva-pub-cont"
]
# sftp_user_name                 = "sftpuser123"
# kv_secret_pub_ssh_key_name_dev = "sshpublickeyuser1"

#Storage Private Account configuration
storage_acc_private = {
  name                             = "stzeusprivatedev808"
  account_kind                     = "BlobStorage"
  account_tier                     = "Standard"
  access_tier                      = "Hot"
  account_replication_type         = "LRS"
  cross_tenant_replication_enabled = false
  shared_access_key_enabled        = true
  is_hns_enabled                   = false
  allowed_copy_scope               = "AAD" # or "PrivateLink"
  allow_nested_items_to_be_public  = true
  public_network_access_enabled    = true
}

# Network Rules for Private Storage Account
storage_acc_private_network_rules = {
  default_action             = "Deny"
  bypass                     = ["AzureServices"]
  ip_rules                   = ["23.45.1.0/30"]
  virtual_network_subnet_ids = []
}

# Container names to create inside Private Storage Account
storage_account_pri_containers = [
  "comp-dyan-pub-cont",
  "compenh-pub-cont",
  "dcentral-pub-cont",
  "dicker-data-pub-cont",
  "dove-pub-cont"
]
kv_secret_pri_ssh_key_name_dev = "sshprivatekeyuser1"
