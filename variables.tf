variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "enable_telemetry" {
  type = bool
}

variable "tenant_id" {
  type = string
}

###########################################
variable "key_vault" {
  description = "Configuration for Key Vault general settings"
  type = object({
    name                           = string
    public_network_access_enabled  = bool
    purge_protection_enabled       = bool
    sku_name                       = string
    soft_delete_retention_days     = number
    legacy_access_policies_enabled = bool
  })
}

variable "key_vault_network_acls" {
  description = "Network ACLs configuration"
  type = object({
    bypass         = string
    default_action = string
    # ip_rules       = list(string)
    # virtual_network_subnet_ids = list(string)
  })
}

variable "principal_id_kv_cloud_team" {
  type = string
}

# variable "key_vault_role_assignments" {
#   description = "Role assignments to apply to the Key Vault"
#   type = map(object({
#     role_definition_id_or_name = string
#     principal_id               = string
#     principal_type             = optional(string, "User")
#   }))
#   default = {}
# }

#################################################################

variable "postgresql" {
  description = "PostgreSQL server configuration"
  type = object({
    name                                    = string
    server_version                          = string
    sku_name                                = string
    storage_mb                              = number
    storage_tier                            = string
    backup_retention_days                   = number
    geo_redundant_backup_enabled            = bool
    zone                                    = number
    public_network_access_enabled           = bool
    administrator_login                     = string
    private_endpoints_manage_dns_zone_group = bool
    high_availability = object({
      mode                      = string
      standby_availability_zone = number
    })
    authentication = object({
      active_directory_auth_enabled = bool
      password_auth_enabled         = bool
    })
  })
}
# variable "postgresql_databases" {
#     description = "Map of databases to create"
#     type = map(object({
#       name = string
#       charset = optional(string,"UTF8")
#       collation = optional(string, "en_US.utf8")
#     }))
# }
# variable "postgresql_ad_administrator" {
#     description = "list of database administrator"
#     type = map(object({
#         tenant_id = string
#         object_id = string
#         principal_name = string
#         principal_type =string
#     }))
# }

#Storage Account - Public Configuration

variable "storage_acc_public" {
  description = "Configuration object for the public storage account."
  type = object({
    name                             = string
    account_kind                     = string
    account_tier                     = string
    access_tier                      = string
    account_replication_type         = string
    is_hns_enabled                   = bool
    sftp_enabled                     = bool
    public_network_access_enabled    = bool
    shared_access_key_enabled        = bool
    allow_nested_items_to_be_public  = bool
    allowed_copy_scope               = string
    cross_tenant_replication_enabled = bool
  })
}

variable "storage_acc_public_network_rules" {
  description = "Network rules for the public storage account."
  type = object({
    default_action = string
    bypass         = list(string)
    ip_rules       = list(string)
    # virtual_network_subnet_ids = set(string)
  })
}

# variable "st_acc_public_role_assignments" {
#   description = "Map of Role assignments of public storage account"
#   type = map(object({
#     name = string
#     principal_id = string
#     principal_type = string
#     role_definition_id = string
#     role_definition_name = string
#   }))
# }
variable "storage_account_pub_containers" {
  description = "Map of storage containers to create"
  type        = list(string)
}
# variable "sftp_user_name" {
#   description = "sftp user name"
#   type        = string
# }
# variable "kv_secret_pub_ssh_key_name_dev" {
#   description = "ssh secret public key for public storage account"
#   type        = string
# }

variable "storage_acc_private" {
  description = "Configuration object for the public storage account."
  type = object({
    name                             = string
    account_kind                     = string
    account_tier                     = string
    access_tier                      = string
    account_replication_type         = string
    is_hns_enabled                   = bool
    public_network_access_enabled    = bool
    shared_access_key_enabled        = bool
    allow_nested_items_to_be_public  = bool
    allowed_copy_scope               = string
    cross_tenant_replication_enabled = bool
  })
}

variable "storage_acc_private_network_rules" {
  description = "Network rules for the public storage account."
  type = object({
    default_action             = string
    bypass                     = list(string)
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
}

variable "storage_account_pri_containers" {
  description = "Map of storage containers to create"
  type        = list(string)
}
variable "kv_secret_pri_ssh_key_name_dev" {
  type = string
}